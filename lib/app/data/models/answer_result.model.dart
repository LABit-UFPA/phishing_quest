/// Resultado de POST /game/answer. So o primeiro acerto de cada questao
/// pontua (pointsAwarded); totalScore e a pontuacao do ranking.
class AnswerResultModel {
  final bool isCorrect;
  final String message;
  final int totalScore;
  final int pointsAwarded;
  final String correctAnswerId;

  AnswerResultModel({
    required this.isCorrect,
    required this.message,
    required this.totalScore,
    required this.pointsAwarded,
    required this.correctAnswerId,
  });

  factory AnswerResultModel.fromJson(Map<String, dynamic> json) {
    return AnswerResultModel(
      isCorrect: json['isCorrect'] ?? false,
      message: json['message'] ?? '',
      totalScore: json['totalScore'] ?? 0,
      pointsAwarded: json['pointsAwarded'] ?? 0,
      correctAnswerId: json['correctAnswerId'] ?? '',
    );
  }
}
