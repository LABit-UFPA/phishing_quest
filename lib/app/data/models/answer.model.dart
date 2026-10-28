/// Alternativa de uma questao (GET /questions/:id/answers). A API nao
/// manda o gabarito: o acerto vem de POST /game/answer.
class AnswerModel {
  final String id;
  final String answerText;

  AnswerModel({required this.id, required this.answerText});

  factory AnswerModel.fromJson(Map<String, dynamic> json) {
    return AnswerModel(
      id: json['id'] ?? '',
      answerText: json['answerText'] ?? '',
    );
  }
}
