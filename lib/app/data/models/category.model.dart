/// Categoria do quiz (GET /categories). A API guarda so o nome; a
/// descricao e o icone sao de apresentacao e saem do nome.
class CategoryModel {
  final String id;
  final String categoryName;

  CategoryModel({required this.id, required this.categoryName});

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? '',
      categoryName: json['categoryName'] ?? '',
    );
  }

  String get _key => categoryName.toLowerCase();

  String? get description {
    if (_key.contains('corporativ')) return 'E-mails falsos que imitam comunicações de empresas';
    if (_key.contains('engenharia')) return 'Manipulação psicológica para obter informações';
    if (_key.contains('segurança') || _key.contains('seguranca')) return 'Práticas e conceitos de segurança da informação';
    return null;
  }

  String get icon {
    if (_key.contains('corporativ')) return '🏢';
    if (_key.contains('engenharia')) return '🧠';
    if (_key.contains('segurança') || _key.contains('seguranca')) return '🔒';
    return '❓';
  }
}
