/// Avaliacao da justificativa pelo PhishForge (condicao formativa).
class EvaluationModel {
  final int score;
  final String feedback;
  final List<String> strengths;
  final List<String> improvements;
  final bool acertoPorSorte;

  EvaluationModel({
    required this.score,
    required this.feedback,
    this.strengths = const [],
    this.improvements = const [],
    this.acertoPorSorte = false,
  });

  factory EvaluationModel.fromJson(Map<String, dynamic> json) {
    return EvaluationModel(
      score: json['score'] ?? 0,
      feedback: json['feedback'] ?? '',
      strengths: List<String>.from(json['strengths'] ?? const []),
      improvements: List<String>.from(json['improvements'] ?? const []),
      acertoPorSorte: json['acertoPorSorte'] ?? false,
    );
  }
}

/// Resposta de POST /attempts: o acerto recalculado no servidor e, na
/// condicao formativa, a avaliacao da justificativa.
class AttemptResultModel {
  final String id;
  final String itemId;
  final bool isCorrect;
  final bool isMalicious;
  final String condition;
  final bool clickedLink;
  final EvaluationModel? evaluation;

  /// Preenchido quando a condicao e formativa mas a avaliacao falhou; a
  /// tentativa fica gravada mesmo assim.
  final String? evaluationError;

  AttemptResultModel({
    required this.id,
    required this.itemId,
    required this.isCorrect,
    required this.isMalicious,
    required this.condition,
    required this.clickedLink,
    this.evaluation,
    this.evaluationError,
  });

  static const formativeCondition = 'feedback_formativo';

  bool get isFormative => condition == formativeCondition;

  factory AttemptResultModel.fromJson(Map<String, dynamic> json) {
    final evaluation = json['evaluation'];
    final error = json['evaluationError'];
    return AttemptResultModel(
      id: json['id'] ?? '',
      itemId: json['itemId'] ?? '',
      isCorrect: json['isCorrect'] ?? false,
      isMalicious: json['isMalicious'] ?? false,
      condition: json['condition'] ?? '',
      clickedLink: json['clickedLink'] ?? false,
      evaluation: evaluation is Map<String, dynamic> ? EvaluationModel.fromJson(evaluation) : null,
      evaluationError: error is String && error.isNotEmpty ? error : null,
    );
  }
}
