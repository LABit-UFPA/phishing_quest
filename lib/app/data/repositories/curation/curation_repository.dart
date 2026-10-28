import 'package:phishing_quest/app/data/models/admin_item.model.dart';
import 'package:phishing_quest/app/data/repositories/request_repository.dart';

/// Curadoria do banco de itens (rotas /admin/items, papeis pesquisador
/// e administrador).
final class CurationRepository extends RequestRepository {
  /// A geracao de e-mail passa pelo RAG e pelo LLM do PhishForge, que o
  /// servidor espera por ate 240 s.
  static const Duration generateTimeout = Duration(seconds: 270);

  /// POST /admin/items/generate. O item entra como rascunho.
  Future<AdminItemModel> generate({
    required String channel,
    required bool isMalicious,
    required String difficulty,
    String? context,
  }) async {
    final data = dataOrThrow(await client.post(
      url('/admin/items/generate'),
      {
        'channel': channel,
        'isMalicious': isMalicious,
        'difficulty': difficulty,
        if (context != null && context.trim().isNotEmpty) 'context': context.trim(),
      },
      receiveTimeout: generateTimeout,
    ));
    return AdminItemModel.fromJson(data as Map<String, dynamic>);
  }

  Future<List<AdminItemModel>> listByStatus(String status) async {
    final data = dataOrThrow(await client.get(url('/admin/items'), queryParams: {'status': status}));
    final list = data is List ? data : const [];
    return list.map((e) => AdminItemModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<ItemCueModel>> itemCues(String itemId) async {
    final data = dataOrThrow(await client.get(url('/admin/items/$itemId/cues')));
    final list = data is List ? data : const [];
    return list.map((e) => ItemCueModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<CueModel>> taxonomy() async {
    final data = dataOrThrow(await client.get(url('/cues')));
    final list = data is List ? data : const [];
    return list.map((e) => CueModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// draft -> reviewed: registra o revisor (o usuario do token).
  Future<void> review(String itemId) async => dataOrThrow(await client.post(url('/admin/items/$itemId/review'), null));

  /// reviewed -> published: o item passa a ser servido no jogo.
  Future<void> publish(String itemId) async => dataOrThrow(await client.post(url('/admin/items/$itemId/publish'), null));

  /// draft ou reviewed -> rejected: o item nunca chega ao jogo.
  Future<void> reject(String itemId) async => dataOrThrow(await client.post(url('/admin/items/$itemId/reject'), null));
}
