import 'package:phishing_quest/app/data/models/email_content.model.dart';

/// Item da caixa de entrada (GET /items/next-batch). A API nao manda o
/// rotulo nem a explicacao: o acerto so vem depois da decisao.
class InboxItemModel {
  final String id;
  final String channel;

  /// Por que a selecao escolheu o item: review, adaptive ou balanced.
  final String selection;
  final EmailContent content;

  /// Horario de chegada exibido na caixa de entrada. E so cenografia:
  /// o item nao tem data de recebimento.
  final DateTime receivedAt;

  InboxItemModel({
    required this.id,
    required this.channel,
    required this.selection,
    required this.content,
    required this.receivedAt,
  });

  factory InboxItemModel.fromJson(Map<String, dynamic> json, {DateTime? receivedAt}) {
    final raw = json['contentJson'];
    return InboxItemModel(
      id: json['id'] ?? '',
      channel: json['channel'] ?? 'email',
      selection: json['selection'] ?? '',
      content: EmailContent.fromJson(raw is Map<String, dynamic> ? raw : const {}),
      receivedAt: receivedAt ?? DateTime.now(),
    );
  }

  bool get isReview => selection == 'review';
}
