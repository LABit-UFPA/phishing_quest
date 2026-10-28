/// Linha do ranking (GET /rankings): pontos do quiz.
class RankingEntryModel {
  final String userId;
  final String username;
  final int score;
  final int position;

  RankingEntryModel({
    required this.userId,
    required this.username,
    required this.score,
    required this.position,
  });

  factory RankingEntryModel.fromJson(Map<String, dynamic> json) {
    return RankingEntryModel(
      userId: json['userId'] ?? '',
      username: json['username'] ?? '',
      score: json['totalScore'] ?? 0,
      position: json['position'] ?? 0,
    );
  }
}

/// Posicao do usuario no ranking global e no da turma (GET /me/ranking).
class MyRankingModel {
  final RankingEntryModel? global;
  final RankingEntryModel? cohort;
  final String? cohortId;

  MyRankingModel({this.global, this.cohort, this.cohortId});

  factory MyRankingModel.fromJson(Map<String, dynamic> json) {
    final global = json['global'];
    final cohort = json['cohort'];
    return MyRankingModel(
      global: global is Map<String, dynamic> ? RankingEntryModel.fromJson(global) : null,
      cohort: cohort is Map<String, dynamic> ? RankingEntryModel.fromJson(cohort) : null,
      cohortId: json['cohortId'],
    );
  }
}
