import 'package:phishing_quest/app/data/models/answer_result.model.dart';
import 'package:phishing_quest/app/data/repositories/game/game_repository.interface.dart';
import 'package:phishing_quest/app/data/repositories/request_repository.dart';

final class GameRepository extends RequestRepository implements IGameRepository {
  /// POST /game/answer. O usuario vem do token; a API corrige a resposta
  /// e soma 10 pontos ao ranking no primeiro acerto de cada questao.
  @override
  Future<AnswerResultModel> submitAnswer({
    required String questionId,
    required String answerId,
  }) async {
    final data = dataOrThrow(await client.post(url('/game/answer'), {
      'questionId': questionId,
      'answerId': answerId,
    }));
    return AnswerResultModel.fromJson(data as Map<String, dynamic>);
  }
}
