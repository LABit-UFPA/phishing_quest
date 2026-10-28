import 'package:phishing_quest/app/data/models/answer_result.model.dart';

abstract class IGameRepository {
  Future<AnswerResultModel> submitAnswer({
    required String questionId,
    required String answerId,
  });
}
