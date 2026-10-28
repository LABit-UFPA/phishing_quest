/// Participacao do usuario no estudo (GET /me/participant).
class ParticipantModel {
  final String userId;
  final DateTime? consentedAt;
  final String consentVersion;

  /// Condicao experimental sorteada pelo servidor. O app so a usa para
  /// decidir o feedback; ela nao e exibida ao participante.
  final String condition;
  final String? cohortId;
  final String? cohortName;
  final bool active;
  final DateTime? withdrawnAt;

  ParticipantModel({
    required this.userId,
    required this.consentVersion,
    required this.condition,
    required this.active,
    this.consentedAt,
    this.cohortId,
    this.cohortName,
    this.withdrawnAt,
  });

  factory ParticipantModel.fromJson(Map<String, dynamic> json) {
    return ParticipantModel(
      userId: json['userId'] ?? '',
      consentedAt: DateTime.tryParse(json['consentedAt'] ?? ''),
      consentVersion: json['consentVersion'] ?? '',
      condition: json['condition'] ?? '',
      cohortId: json['cohortId'],
      cohortName: json['cohortName'],
      active: json['active'] ?? false,
      withdrawnAt: DateTime.tryParse(json['withdrawnAt'] ?? ''),
    );
  }
}
