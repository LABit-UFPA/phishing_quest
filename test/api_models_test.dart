import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phishing_quest/app/data/enumerators/user_role.enum.dart';
import 'package:phishing_quest/app/data/models/admin_item.model.dart';
import 'package:phishing_quest/app/data/models/answer_result.model.dart';
import 'package:phishing_quest/app/data/models/attempt_result.model.dart';
import 'package:phishing_quest/app/data/models/email_content.model.dart';
import 'package:phishing_quest/app/data/models/inbox_item.model.dart';
import 'package:phishing_quest/app/data/models/participant.model.dart';
import 'package:phishing_quest/app/data/models/question.model.dart';
import 'package:phishing_quest/app/data/models/ranking_entry.model.dart';
import 'package:phishing_quest/app/data/models/user.model.dart';
import 'package:phishing_quest/app/data/models/user_stats.model.dart';
import 'package:phishing_quest/app/data/repositories/request_repository.dart';
import 'package:phishing_quest/app/data/util/ids/uuid_v4.dart';
import 'package:phishing_quest/app/modules/email_sim/email_sim_controller.dart';

// Os testes usam os formatos de resposta da phishing-quest-api
// (dto/*.go e domain/*.go).

final class _Repository extends RequestRepository {}

Response<dynamic> _response(int? status, dynamic data) =>
    Response(requestOptions: RequestOptions(path: '/x'), statusCode: status, data: data);

void main() {
  group('EmailContent', () {
    test('le o formato canonico do banco de itens', () {
      final email = EmailContent.fromJson({
        'sender': 'suporte@banc0-brasil.com',
        'sender_name': 'Banco do Brasil',
        'recipient': 'joao@empresa.com',
        'subject': 'URGENTE',
        'body': 'Clique em Confirmar.',
        'links': [
          {'text': 'Confirmar', 'href': 'http://banc0-brasil.com/x'},
        ],
      });

      expect(email.senderName, 'Banco do Brasil');
      expect(email.links.single.text, 'Confirmar');
      expect(email.links.single.href, 'http://banc0-brasil.com/x');
    });

    test('sem sender_name, deriva o nome do endereco', () {
      final email = EmailContent.fromJson({'sender': 'ti-suporte@empres4.net', 'subject': 'x', 'body': 'y'});
      expect(email.senderName, 'Ti Suporte');
      expect(email.avatarInitial, 'T');
    });

    test('aceita links como texto e descarta links sem destino', () {
      final email = EmailContent.fromJson({
        'links': [
          'https://exemplo.com',
          {'text': 'vazio', 'href': ''},
        ],
      });
      expect(email.links, hasLength(1));
      expect(email.links.single.text, 'https://exemplo.com');
    });
  });

  test('InboxItemModel le contentJson e o motivo da selecao', () {
    final item = InboxItemModel.fromJson({
      'id': 'i1',
      'channel': 'email',
      'locale': 'pt-BR',
      'contentJson': {'sender': 'a@b.com', 'subject': 'Assunto', 'body': 'Corpo'},
      'selection': 'review',
    });
    expect(item.content.subject, 'Assunto');
    expect(item.isReview, isTrue);
  });

  group('AttemptResultModel', () {
    test('condicao formativa traz a avaliacao da justificativa', () {
      final result = AttemptResultModel.fromJson({
        'id': 'a1',
        'itemId': 'i1',
        'isCorrect': true,
        'isMalicious': true,
        'condition': 'feedback_formativo',
        'clickedLink': false,
        'evaluation': {
          'score': 4,
          'feedback': 'Boa analise.',
          'strengths': ['Identificou o dominio falso'],
          'improvements': ['Mencionar a urgencia'],
          'acertoPorSorte': false,
        },
      });
      expect(result.isFormative, isTrue);
      expect(result.evaluation!.score, 4);
      expect(result.evaluation!.strengths, ['Identificou o dominio falso']);
      expect(result.evaluationError, isNull);
    });

    test('condicao binaria nao traz avaliacao', () {
      final result = AttemptResultModel.fromJson({
        'id': 'a1',
        'itemId': 'i1',
        'isCorrect': false,
        'isMalicious': false,
        'condition': 'feedback_binario',
        'clickedLink': true,
      });
      expect(result.isFormative, isFalse);
      expect(result.evaluation, isNull);
      expect(result.clickedLink, isTrue);
    });

    test('falha da avaliacao chega como evaluationError', () {
      final result = AttemptResultModel.fromJson({
        'isCorrect': true,
        'condition': 'feedback_formativo',
        'evaluationError': 'avaliacao da justificativa indisponivel no momento',
      });
      expect(result.evaluation, isNull);
      expect(result.evaluationError, isNotNull);
    });
  });

  test("UserStatsModel le d', c e a acuracia por pista", () {
    final stats = UserStatsModel.fromJson({
      'totalAttempts': 12,
      'hitRate': 0.8,
      'falseAlarmRate': 0.25,
      'accuracy': 0.75,
      'dPrime': 1.52,
      'criterion': -0.4,
      'byCue': [
        {'cueCode': 'typosquat', 'labelPt': 'Typosquatting', 'answered': 4, 'correct': 1, 'accuracy': 0.25},
      ],
    });
    expect(stats.dPrime, 1.52);
    expect(stats.byCue.single.labelPt, 'Typosquatting');
    expect(stats.criterionReading, 'Tende a marcar como phishing');
  });

  test('MyRankingModel le a posicao global e a da turma', () {
    final mine = MyRankingModel.fromJson({
      'global': {'position': 2, 'userId': 'u1', 'username': 'ana', 'totalScore': 20},
      'cohort': {'position': 1, 'userId': 'u1', 'username': 'ana', 'totalScore': 20},
      'cohortId': 'c1',
    });
    expect(mine.global!.position, 2);
    expect(mine.cohort!.position, 1);
    expect(mine.cohortId, 'c1');
    expect(MyRankingModel.fromJson({}).global, isNull);
  });

  test('QuestionModel le o e-mail de contexto', () {
    final question = QuestionModel.fromJson({
      'questionId': 'q1',
      'questionText': 'Analise o e-mail',
      'context': {'sender': 'rh@empresa-br.com', 'subject': 'Bonus', 'body': '...'},
    });
    expect(question.id, 'q1');
    expect(question.context!.subject, 'Bonus');
    expect(QuestionModel.fromJson({'questionId': 'q2', 'questionText': 'x'}).context, isNull);
  });

  test('AnswerResultModel le pointsAwarded e correctAnswerId', () {
    final result = AnswerResultModel.fromJson({
      'isCorrect': false,
      'message': 'Resposta incorreta.',
      'totalScore': 10,
      'pointsAwarded': 0,
      'correctAnswerId': 'ans-1',
    });
    expect(result.correctAnswerId, 'ans-1');
    expect(result.pointsAwarded, 0);
  });

  test('ParticipantModel le o consentimento', () {
    final participant = ParticipantModel.fromJson({
      'userId': 'u1',
      'consentedAt': '2026-10-28T12:00:00Z',
      'consentVersion': 'tcle-provisorio-2026-10',
      'condition': 'feedback_binario',
      'cohortName': 'Turma de Redes',
      'active': false,
      'withdrawnAt': '2026-10-29T12:00:00Z',
    });
    expect(participant.active, isFalse);
    expect(participant.withdrawnAt, isNotNull);
    expect(participant.cohortName, 'Turma de Redes');
  });

  test('UserModel e papeis da API', () {
    final user = UserModel.fromJson({
      'id': 'u1',
      'username': 'ana',
      'email': 'a@b.com',
      'role': 'researcher',
      'totalScore': 30,
    });
    expect(user.role, UserRole.researcher);
    expect(user.canCurate, isTrue);
    expect(UserRole.fromString('participant').canCurate, isFalse);
    expect(UserRole.fromString('desconhecido'), UserRole.participant);
  });

  test('AdminItemModel usa o assunto como titulo e reconhece o PhishForge', () {
    final item = AdminItemModel.fromJson({
      'id': 'i1',
      'channel': 'email',
      'isMalicious': true,
      'status': 'draft',
      'source': 'phishforge:11111111-2222-3333-4444-555555555555',
      'explanation': 'Urgencia e typosquatting.',
      'contentJson': {'subject': 'URGENTE: Atualizacao'},
      'phishScaleCueCount': 2,
    });
    expect(item.title, 'URGENTE: Atualizacao');
    expect(item.isGeneratedByPhishForge, isTrue);
  });

  test('as acoes da caixa de entrada sao as aceitas pela API', () {
    expect(
      InboxAction.values.map((a) => a.apiValue).toSet(),
      {'report', 'delete', 'verify_other_channel', 'reply', 'click', 'ignore'},
    );
  });

  group('RequestRepository', () {
    final repository = _Repository();

    test('devolve o corpo de uma resposta 2xx', () {
      expect(repository.dataOrThrow(_response(201, {'ok': true})), {'ok': true});
    });

    test('usa a mensagem de erro da API', () {
      expect(
        () => repository.dataOrThrow(_response(403, {'error': 'consentimento necessario'})),
        throwsA(isA<ApiException>()
            .having((e) => e.statusCode, 'statusCode', 403)
            .having((e) => e.message, 'message', 'consentimento necessario')),
      );
    });

    test('sem resposta do servidor, statusCode e nulo', () {
      expect(
        () => repository.dataOrThrow(_response(null, 'Sem conexão com a internet')),
        throwsA(isA<ApiException>()
            .having((e) => e.statusCode, 'statusCode', isNull)
            .having((e) => e.message, 'message', 'Sem conexão com a internet')),
      );
    });
  });

  test('uuidV4 gera ids distintos no formato da RFC 9562', () {
    final pattern = RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$');
    final ids = List.generate(50, (_) => uuidV4());
    expect(ids.every(pattern.hasMatch), isTrue);
    expect(ids.toSet(), hasLength(50));
  });
}
