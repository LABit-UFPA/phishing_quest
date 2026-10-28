import 'package:phishing_quest/app/data/models/attempt_result.model.dart';
import 'package:phishing_quest/app/data/models/inbox_item.model.dart';

abstract interface class IInboxRepository {
  Future<List<InboxItemModel>> nextBatch({required String sessionId, int count});
  Future<bool> linkClick(String itemId);
  Future<AttemptResultModel> submitAttempt({
    required String itemId,
    required String sessionId,
    required bool verdict,
    required String action,
    required int confidence,
    required String justification,
    required int latencyMs,
    required bool clickedLink,
  });
}
