import 'package:phishing_quest/app/data/models/email_content.model.dart';

/// Questao do quiz (GET /categories/:id/questions). `context` e o
/// e-mail a analisar, quando a questao tem um.
class QuestionModel {
  final String id;
  final String questionText;
  final EmailContent? context;

  QuestionModel({
    required this.id,
    required this.questionText,
    this.context,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    final rawContext = json['context'];
    return QuestionModel(
      id: json['questionId'] ?? json['id'] ?? '',
      questionText: json['questionText'] ?? '',
      context: rawContext is Map<String, dynamic> ? EmailContent.fromJson(rawContext) : null,
    );
  }
}
