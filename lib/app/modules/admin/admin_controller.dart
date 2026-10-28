import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phishing_quest/app/data/enumerators/difficulty.enum.dart';
import 'package:phishing_quest/app/data/models/admin_item.model.dart';
import 'package:phishing_quest/app/data/repositories/curation/curation_repository.dart';
import 'package:phishing_quest/app/data/repositories/request_repository.dart';
import 'package:phishing_quest/app/global_ui/components/toast.dart';

/// Estados do pipeline de curadoria (domain.ItemStatus).
enum ItemStatus {
  draft('draft', 'Rascunhos'),
  reviewed('reviewed', 'Revisados'),
  published('published', 'Publicados'),
  rejected('rejected', 'Rejeitados');

  const ItemStatus(this.apiValue, this.label);

  final String apiValue;
  final String label;
}

/// Canais do banco de itens (domain.Channel). O PhishForge gera e-mail;
/// os demais canais saem do gerador por template da API.
const Map<String, String> itemChannels = {
  'email': 'E-mail',
  'sms': 'SMS',
  'whatsapp': 'WhatsApp',
  'website': 'Site',
  'phone_call': 'Ligação',
  'pix_qr': 'Pix/QR Code',
};

/// Curadoria: gerar rascunhos, revisar, publicar e rejeitar. So itens
/// publicados chegam ao jogo.
class AdminController extends GetxController {
  final CurationRepository _repository = CurationRepository();

  // Generate form
  final RxString channel = 'email'.obs;
  final RxBool isMalicious = true.obs;
  final Rx<Difficulty> selectedDifficulty = Difficulty.medium.obs;
  final TextEditingController contextController = TextEditingController();
  final RxBool isGenerating = false.obs;

  // Item lists
  final Rx<ItemStatus> status = ItemStatus.draft.obs;
  final RxList<AdminItemModel> items = <AdminItemModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxnString loadError = RxnString();
  final RxBool isActing = false.obs;
  final RxMap<String, String> cueLabels = <String, String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadItems();
    _loadTaxonomy();
  }

  @override
  void onClose() {
    contextController.dispose();
    super.onClose();
  }

  Future<void> _loadTaxonomy() async {
    try {
      final cues = await _repository.taxonomy();
      cueLabels.assignAll({for (final cue in cues) cue.id: cue.labelPt.isNotEmpty ? cue.labelPt : cue.code});
    } on ApiException {
      // Sem a taxonomia, as pistas aparecem pelo id.
    }
  }

  Future<void> loadItems() async {
    isLoading.value = true;
    loadError.value = null;
    try {
      items.assignAll(await _repository.listByStatus(status.value.apiValue));
    } on ApiException catch (e) {
      loadError.value = e.message;
    }
    isLoading.value = false;
  }

  void selectStatus(ItemStatus value) {
    if (status.value == value) return;
    status.value = value;
    loadItems();
  }

  void selectDifficulty(Difficulty d) {
    selectedDifficulty.value = d;
  }

  /// Gera um rascunho. E-mail vem do PhishForge, com pistas e atributos
  /// da Phish Scale; pode levar alguns minutos.
  Future<void> generate() async {
    if (isGenerating.value) return;
    isGenerating.value = true;
    try {
      final item = await _repository.generate(
        channel: channel.value,
        isMalicious: isMalicious.value,
        difficulty: selectedDifficulty.value.name,
        context: contextController.text,
      );
      Toast.success(
        'Rascunho criado',
        item.isGeneratedByPhishForge ? 'Gerado pelo PhishForge. Revise antes de publicar.' : 'Revise antes de publicar.',
      );
      status.value = ItemStatus.draft;
      await loadItems();
    } on ApiException catch (e) {
      Toast.error('Falha na geração', e.message);
    }
    isGenerating.value = false;
  }

  Future<List<ItemCueModel>> cuesOf(AdminItemModel item) => _repository.itemCues(item.id);

  Future<void> markReviewed(AdminItemModel item) => _act(() => _repository.review(item.id), 'Item marcado como revisado');

  Future<void> publish(AdminItemModel item) => _act(() => _repository.publish(item.id), 'Item publicado no jogo');

  Future<void> reject(AdminItemModel item) => _act(() => _repository.reject(item.id), 'Item rejeitado');

  Future<void> _act(Future<void> Function() action, String successMessage) async {
    if (isActing.value) return;
    isActing.value = true;
    try {
      await action();
      Get.back();
      Toast.success('Pronto', successMessage);
      await loadItems();
    } on ApiException catch (e) {
      Toast.error('Não foi possível concluir', e.message);
    }
    isActing.value = false;
  }
}
