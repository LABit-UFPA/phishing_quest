/// Papeis da API (domain.Role): participante joga; pesquisador e
/// administrador tambem fazem a curadoria dos itens.
enum UserRole {
  participant,
  researcher,
  admin;

  static UserRole fromString(String? value) {
    return UserRole.values.firstWhere(
      (e) => e.name == value?.toLowerCase(),
      orElse: () => UserRole.participant,
    );
  }

  bool get canCurate => this == UserRole.researcher || this == UserRole.admin;

  String get label {
    switch (this) {
      case UserRole.participant:
        return 'Participante';
      case UserRole.researcher:
        return 'Pesquisador';
      case UserRole.admin:
        return 'Administrador';
    }
  }
}
