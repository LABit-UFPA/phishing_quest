import 'package:get/get.dart';
import 'package:phishing_quest/app/data/models/attempt_result.model.dart';
import 'package:phishing_quest/app/data/models/email_content.model.dart';
import 'package:phishing_quest/app/data/models/inbox_item.model.dart';
import 'package:phishing_quest/app/data/repositories/inbox/inbox_repository.dart';
import 'package:phishing_quest/app/data/repositories/request_repository.dart';
import 'package:phishing_quest/app/data/services/auth_service.dart';
import 'package:phishing_quest/app/data/services/telemetry_service.dart';
import 'package:phishing_quest/app/data/util/ids/uuid_v4.dart';
import 'package:phishing_quest/app/global_ui/components/toast.dart';
import 'package:phishing_quest/app/modules/consent/consent_module.dart';
import 'package:phishing_quest/app/modules/email_sim/email_sim_routes.dart';

/// Acoes que o jogador pode informar junto com o veredito
/// (domain.AttemptAction na API).
enum InboxAction {
  report('report', 'Reportar como phishing'),
  delete('delete', 'Apagar'),
  verifyOtherChannel('verify_other_channel', 'Verificar por outro canal'),
  reply('reply', 'Responder'),
  click('click', 'Clicar no link'),
  ignore('ignore', 'Ignorar');

  const InboxAction(this.apiValue, this.label);

  final String apiValue;
  final String label;
}

/// Decisao do jogador sobre uma mensagem.
typedef InboxDecision = ({bool verdict, InboxAction action, int confidence, String justification});

/// Caixa de entrada simulada. Os itens vem da selecao adaptativa da API
/// (GET /items/next-batch) e cada decisao vira uma tentativa
/// (POST /attempts), com latencia e clique. O acerto vem do servidor.
class EmailSimController extends GetxController {
  static const int pointsPerCorrect = 10;
  static const int maliciousClickPenalty = 5;

  final InboxRepository _repository;
  final TelemetryService _telemetry;

  EmailSimController({InboxRepository? repository, TelemetryService? telemetry})
      : _repository = repository ?? InboxRepository(),
        _telemetry = telemetry ?? Get.find<TelemetryService>();

  /// Sessao da caixa de entrada: a API nao repete, na mesma sessao, item
  /// ja respondido.
  final String sessionId = uuidV4();

  final RxList<InboxItemModel> inbox = <InboxItemModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxnString loadError = RxnString();
  final RxBool isSubmitting = false.obs;

  final RxMap<String, AttemptResultModel> results = <String, AttemptResultModel>{}.obs;
  final RxMap<String, bool> verdicts = <String, bool>{}.obs;

  /// Itens em que o jogador clicou em algum link (vai em clickedLink).
  final RxSet<String> clickedLinks = <String>{}.obs;

  /// Itens em que o clique foi em link malicioso (ja descontado).
  final RxSet<String> maliciousClicks = <String>{}.obs;

  final RxInt totalScore = 0.obs;

  final Map<String, DateTime> _openedAt = {};

  int get evaluatedCount => results.length;
  bool get allEvaluated => inbox.isNotEmpty && evaluatedCount >= inbox.length;

  bool isEvaluated(String itemId) => results.containsKey(itemId);
  bool? wasCorrect(String itemId) => results[itemId]?.isCorrect;

  InboxItemModel? itemById(String itemId) => inbox.firstWhereOrNull((i) => i.id == itemId);

  @override
  void onInit() {
    super.onInit();
    _telemetry.track('inbox_session_started', sessionId: sessionId);
    loadInbox();
  }

  @override
  void onClose() {
    _telemetry.flush();
    super.onClose();
  }

  /// Carrega um lote novo na mesma sessao. A API deixa de fora o que ja
  /// foi respondido nela.
  Future<void> loadInbox() async {
    isLoading.value = true;
    loadError.value = null;
    try {
      final items = await _repository.nextBatch(sessionId: sessionId);
      inbox.assignAll(items);
      results.clear();
      verdicts.clear();
      clickedLinks.clear();
      maliciousClicks.clear();
      _openedAt.clear();
    } on ApiException catch (e) {
      loadError.value = e.message;
    }
    isLoading.value = false;
  }

  void openItem(InboxItemModel item) {
    if (!_openedAt.containsKey(item.id)) {
      _openedAt[item.id] = DateTime.now();
      _telemetry.track('inbox_item_opened', sessionId: sessionId, payload: {
        'itemId': item.id,
        'selection': item.selection,
      });
    }
    Get.toNamed(EmailSimRoutes.detail, arguments: {'itemId': item.id});
  }

  /// Registra o clique e pergunta a API se o link era malicioso. So o
  /// primeiro clique malicioso de cada mensagem desconta pontos.
  /// Devolve null quando nao foi possivel consultar.
  Future<bool?> onLinkTapped(InboxItemModel item, EmailLink link) async {
    clickedLinks.add(item.id);
    _telemetry.track('inbox_link_clicked', sessionId: sessionId, payload: {
      'itemId': item.id,
      'href': link.href,
    });

    try {
      final malicious = await _repository.linkClick(item.id);
      if (malicious && maliciousClicks.add(item.id)) {
        totalScore.value -= maliciousClickPenalty;
      }
      return malicious;
    } on ApiException {
      return null;
    }
  }

  /// Envia a decisao. Devolve o resultado da API, ou null se a tentativa
  /// nao foi registrada.
  Future<AttemptResultModel?> submitDecision(InboxItemModel item, InboxDecision decision) async {
    if (isSubmitting.value || isEvaluated(item.id)) return null;
    isSubmitting.value = true;

    final openedAt = _openedAt[item.id] ?? DateTime.now();
    final latencyMs = DateTime.now().difference(openedAt).inMilliseconds;

    try {
      final result = await _repository.submitAttempt(
        itemId: item.id,
        sessionId: sessionId,
        verdict: decision.verdict,
        action: decision.action.apiValue,
        confidence: decision.confidence,
        justification: decision.justification,
        latencyMs: latencyMs,
        clickedLink: clickedLinks.contains(item.id),
      );
      results[item.id] = result;
      verdicts[item.id] = decision.verdict;
      if (result.isCorrect) {
        totalScore.value += pointsPerCorrect;
      }
      _telemetry.track('inbox_decision_submitted', sessionId: sessionId, payload: {
        'itemId': item.id,
        'latencyMs': latencyMs,
      });
      return result;
    } on ApiException catch (e) {
      if (e.isForbidden) {
        // Consentimento retirado (ou nunca dado): a API recusa tentativas.
        await Get.find<AuthService>().refreshParticipant().catchError((_) => null);
        Toast.alert('Consentimento necessário', 'Aceite o termo para registrar suas decisões.');
        Get.until((route) => route.settings.name == EmailSimRoutes.inbox);
        Get.offNamed(ConsentModule.path, arguments: {'next': EmailSimRoutes.inbox});
      } else {
        Toast.error('Decisão não registrada', e.message);
      }
      return null;
    } finally {
      isSubmitting.value = false;
    }
  }

  int pointsFor(String itemId) {
    var points = (results[itemId]?.isCorrect ?? false) ? pointsPerCorrect : 0;
    if (maliciousClicks.contains(itemId)) points -= maliciousClickPenalty;
    return points;
  }

  void finishSimulation() {
    _telemetry.track('inbox_session_finished', sessionId: sessionId, payload: {
      'evaluated': evaluatedCount,
      'correct': results.values.where((r) => r.isCorrect).length,
    });
    _telemetry.flush();
    Get.toNamed(EmailSimRoutes.result);
  }

  /// Nova rodada na mesma sessao (chamado pela tela de resultado).
  Future<void> nextRound() async {
    Get.until((route) => route.settings.name == EmailSimRoutes.inbox);
    await loadInbox();
  }
}
