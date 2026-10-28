/// Desempenho em uma pista da taxonomia.
class CuePerformance {
  final String cueCode;
  final String labelPt;
  final int answered;
  final int correct;

  /// Fracao de 0 a 1.
  final double accuracy;

  CuePerformance({
    required this.cueCode,
    required this.labelPt,
    required this.answered,
    required this.correct,
    required this.accuracy,
  });

  factory CuePerformance.fromJson(Map<String, dynamic> json) {
    return CuePerformance(
      cueCode: json['cueCode'] ?? '',
      labelPt: json['labelPt'] ?? '',
      answered: json['answered'] ?? 0,
      correct: json['correct'] ?? 0,
      accuracy: (json['accuracy'] ?? 0).toDouble(),
    );
  }
}

/// Desempenho na caixa de entrada pela teoria de deteccao de sinal
/// (GET /me/stats). As taxas vem como fracao de 0 a 1.
class UserStatsModel {
  final int totalAttempts;
  final double hitRate;
  final double falseAlarmRate;
  final double accuracy;
  final double dPrime;
  final double criterion;
  final List<CuePerformance> byCue;

  UserStatsModel({
    required this.totalAttempts,
    required this.hitRate,
    required this.falseAlarmRate,
    required this.accuracy,
    required this.dPrime,
    required this.criterion,
    this.byCue = const [],
  });

  factory UserStatsModel.fromJson(Map<String, dynamic> json) {
    return UserStatsModel(
      totalAttempts: json['totalAttempts'] ?? 0,
      hitRate: (json['hitRate'] ?? 0).toDouble(),
      falseAlarmRate: (json['falseAlarmRate'] ?? 0).toDouble(),
      accuracy: (json['accuracy'] ?? 0).toDouble(),
      dPrime: (json['dPrime'] ?? 0).toDouble(),
      criterion: (json['criterion'] ?? 0).toDouble(),
      byCue: (json['byCue'] as List? ?? const []).map((e) => CuePerformance.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  /// Leitura do criterio c para o jogador: negativo = tende a dizer
  /// "e phishing"; positivo = tende a dizer "e legitimo".
  String get criterionReading {
    if (totalAttempts == 0) return 'Sem decisões ainda';
    if (criterion < -0.25) return 'Tende a marcar como phishing';
    if (criterion > 0.25) return 'Tende a marcar como legítimo';
    return 'Sem viés marcado';
  }
}
