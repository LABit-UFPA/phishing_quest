import 'package:phishing_quest/app/data/models/answer.model.dart';
import 'package:phishing_quest/app/data/models/question.model.dart';

abstract class IQuestionRepository {
  Future<List<QuestionModel>> getQuestionsByCategory(String categoryId);
  Future<List<AnswerModel>> getAnswersByQuestion(String questionId);
}
