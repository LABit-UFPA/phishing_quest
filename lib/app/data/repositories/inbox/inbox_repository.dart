import 'package:phishing_quest/app/data/models/attempt_result.model.dart';
import 'package:phishing_quest/app/data/models/inbox_item.model.dart';
import 'package:phishing_quest/app/data/repositories/inbox/inbox_repository.interface.dart';
import 'package:phishing_quest/app/data/repositories/request_repository.dart';

final class InboxRepository extends RequestRepository implements IInboxRepository {
  /// A avaliacao da justificativa pelo PhishForge pode levar ate um
  /// minuto no servidor; a espera do app acompanha.
  static const Duration attemptTimeout = Duration(seconds: 90);

  /// GET /items/next-batch em modo adaptativo, so e-mail. A selecao poe
  /// primeiro as revisoes vencidas, depois os itens com pistas nao
  /// dominadas e, por fim, equilibra malicioso e legitimo. Devolve lista
  /// vazia quando nao ha mais itens para a sessao (404).
  @override
  Future<List<InboxItemModel>> nextBatch({required String sessionId, int count = 8}) async {
    final response = await client.get(url('/items/next-batch'), queryParams: {
      'sessionId': sessionId,
      'mode': 'adaptive',
      'channel': 'email',
      'count': count,
    });
    if (response.statusCode == 404) {
      return const [];
    }

    final data = dataOrThrow(response);
    final list = data is Map ? data['items'] as List? ?? const [] : const [];
    final now = DateTime.now();
    return list.asMap().entries.map((entry) {
      // Horarios decrescentes so para a caixa de entrada parecer real.
      final receivedAt = now.subtract(Duration(minutes: 17 + entry.key * 53));
      return InboxItemModel.fromJson(entry.value as Map<String, dynamic>, receivedAt: receivedAt);
    }).toList();
  }

  /// POST /items/:id/link-click: diz se o link clicado era malicioso.
  @override
  Future<bool> linkClick(String itemId) async {
    final data = dataOrThrow(await client.post(url('/items/$itemId/link-click'), null));
    return data is Map && data['malicious'] == true;
  }

  /// POST /attempts. O servidor recalcula o acerto e, na condicao
  /// formativa, avalia a justificativa.
  @override
  Future<AttemptResultModel> submitAttempt({
    required String itemId,
    required String sessionId,
    required bool verdict,
    required String action,
    required int confidence,
    required String justification,
    required int latencyMs,
    required bool clickedLink,
  }) async {
    final data = dataOrThrow(await client.post(
      url('/attempts'),
      {
        'itemId': itemId,
        'sessionId': sessionId,
        'verdict': verdict,
        'action': action,
        'confidence': confidence,
        'justification': justification,
        'latencyMs': latencyMs,
        'clickedLink': clickedLink,
      },
      receiveTimeout: attemptTimeout,
    ));
    return AttemptResultModel.fromJson(data as Map<String, dynamic>);
  }
}
