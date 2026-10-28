import 'package:get/get.dart';
import 'package:phishing_quest/app/data/models/participant.model.dart';
import 'package:phishing_quest/app/data/models/user_stats.model.dart';
import 'package:phishing_quest/app/data/repositories/participant/participant_repository.dart';
import 'package:phishing_quest/app/data/repositories/ranking/ranking_repository.dart';
import 'package:phishing_quest/app/data/repositories/request_repository.dart';
import 'package:phishing_quest/app/data/services/auth_service.dart';
import 'package:phishing_quest/app/global_ui/components/toast.dart';
import 'package:phishing_quest/app/modules/consent/consent_module.dart';
import 'package:phishing_quest/app/modules/initial/flow_initial/flow_initial_module.dart';

/// Perfil: desempenho na caixa de entrada pela teoria de deteccao de
/// sinal (d', c, acuracia por pista), pontos do quiz e participacao no
/// estudo.
class ProfileController extends GetxController {
  final Rx<UserStatsModel?> stats = Rx<UserStatsModel?>(null);
  final RxBool isLoading = true.obs;
  final RxBool isWithdrawing = false.obs;
  final RxnString loadError = RxnString();

  AuthService get auth => Get.find<AuthService>();

  ParticipantModel? get participant => auth.participant.value;

  @override
  void onInit() {
    super.onInit();
    loadStats();
  }

  Future<void> loadStats() async {
    isLoading.value = true;
    loadError.value = null;
    try {
      final repo = RankingRepository();
      stats.value = await repo.getMyStats();
      final global = (await repo.getMyRanking()).global;
      await auth.refreshParticipant();
      if (global != null) {
        await auth.updateScore(global.score);
      }
    } on ApiException catch (e) {
      loadError.value = e.message;
    }
    isLoading.value = false;
  }

  Future<void> participate() async {
    await Get.toNamed(ConsentModule.path, arguments: {'popOnDone': true});
    loadStats();
  }

  /// Retira o consentimento (LGPD). A partir dai a API recusa novas
  /// tentativas na caixa de entrada.
  Future<void> withdrawConsent() async {
    final user = auth.currentUser.value;
    if (user == null || isWithdrawing.value) return;
    isWithdrawing.value = true;
    try {
      await ParticipantRepository().withdrawConsent(user.id);
      await auth.refreshParticipant();
      Toast.success('Consentimento retirado', 'Suas próximas decisões não serão registradas.');
    } on ApiException catch (e) {
      Toast.error('Não foi possível retirar', e.message);
    }
    isWithdrawing.value = false;
  }

  Future<void> logout() async {
    await auth.logout();
    Get.offAllNamed(FlowInitialModule.path);
  }
}
