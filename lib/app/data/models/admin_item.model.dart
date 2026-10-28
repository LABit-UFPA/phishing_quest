import 'package:phishing_quest/app/data/models/email_content.model.dart';

/// Item completo, visto pela curadoria (GET /admin/items).
class AdminItemModel {
  final String id;
  final String channel;
  final bool isMalicious;
  final String status;
  final String source;
  final String explanation;
  final Map<String, dynamic> content;
  final int? phishScaleCueCount;
  final String? phishScalePremiseAlignment;
  final String? difficultyEstimated;
  final DateTime? createdAt;

  AdminItemModel({
    required this.id,
    required this.channel,
    required this.isMalicious,
    required this.status,
    required this.source,
    required this.explanation,
    required this.content,
    this.phishScaleCueCount,
    this.phishScalePremiseAlignment,
    this.difficultyEstimated,
    this.createdAt,
  });

  factory AdminItemModel.fromJson(Map<String, dynamic> json) {
    final raw = json['contentJson'];
    return AdminItemModel(
      id: json['id'] ?? '',
      channel: json['channel'] ?? '',
      isMalicious: json['isMalicious'] ?? false,
      status: json['status'] ?? '',
      source: json['source'] ?? '',
      explanation: json['explanation'] ?? '',
      content: raw is Map<String, dynamic> ? raw : const {},
      phishScaleCueCount: json['phishScaleCueCount'],
      phishScalePremiseAlignment: json['phishScalePremiseAlignment'],
      difficultyEstimated: json['difficultyEstimated'],
      createdAt: DateTime.tryParse(json['createdAt'] ?? ''),
    );
  }

  bool get isEmail => channel == 'email';

  EmailContent get email => EmailContent.fromJson(content);

  /// Texto curto para a lista: assunto do e-mail ou o primeiro campo de
  /// texto dos outros canais.
  String get title {
    if (isEmail) return email.subject.isNotEmpty ? email.subject : '(sem assunto)';
    for (final key in ['text', 'title', 'caller', 'sender']) {
      final value = content[key];
      if (value is String && value.isNotEmpty) return value;
    }
    return '(sem texto)';
  }

  bool get isGeneratedByPhishForge => source.startsWith('phishforge');
}

/// Pista anotada em um item (GET /admin/items/:id/cues).
class ItemCueModel {
  final String cueId;
  final String? field;
  final String? evidence;

  ItemCueModel({required this.cueId, this.field, this.evidence});

  factory ItemCueModel.fromJson(Map<String, dynamic> json) {
    return ItemCueModel(
      cueId: json['cueId'] ?? '',
      field: json['field'],
      evidence: json['evidence'],
    );
  }
}

/// Pista da taxonomia (GET /cues).
class CueModel {
  final String id;
  final String code;
  final String labelPt;

  CueModel({required this.id, required this.code, required this.labelPt});

  factory CueModel.fromJson(Map<String, dynamic> json) {
    return CueModel(
      id: json['id'] ?? '',
      code: json['code'] ?? '',
      labelPt: json['labelPt'] ?? '',
    );
  }
}
