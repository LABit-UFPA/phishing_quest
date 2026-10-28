import 'package:phishing_quest/app/data/models/answer.model.dart';
import 'package:phishing_quest/app/data/models/question.model.dart';
import 'package:phishing_quest/app/data/repositories/question/question_repository.interface.dart';
import 'package:phishing_quest/app/data/repositories/request_repository.dart';

final class QuestionRepository extends RequestRepository implements IQuestionRepository {
  /// GET /categories/:id/questions -> {categoryId, questions: [...]}.
  @override
  Future<List<QuestionModel>> getQuestionsByCategory(String categoryId) async {
    final data = dataOrThrow(await client.get(url('/categories/$categoryId/questions')));
    final list = data is Map ? data['questions'] as List? ?? const [] : const [];
    return list.map((e) => QuestionModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// GET /questions/:id/answers -> {questionId, answers: [{id, answerText}]}.
  @override
  Future<List<AnswerModel>> getAnswersByQuestion(String questionId) async {
    final data = dataOrThrow(await client.get(url('/questions/$questionId/answers')));
    final list = data is Map ? data['answers'] as List? ?? const [] : const [];
    return list.map((e) => AnswerModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}
