import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phishing_quest/app/data/constants/consent_term.dart';
import 'package:phishing_quest/app/data/repositories/participant/participant_repository.dart';
import 'package:phishing_quest/app/data/repositories/request_repository.dart';
import 'package:phishing_quest/app/data/services/auth_service.dart';
import 'package:phishing_quest/app/global_ui/components/toast.dart';
import 'package:phishing_quest/app/modules/main_shell/main_shell_module.dart';

/// Tela do termo de consentimento. Argumentos opcionais:
/// `next` - rota aberta depois do aceite (ex.: a caixa de entrada);
/// `popOnDone` - volta para a tela anterior (ex.: o perfil).
/// Sem argumentos, o aceite e a recusa levam ao inicio.
class ConsentController extends GetxController {
  final TextEditingController cohortCodeController = TextEditingController();
  final RxBool hasReadTerm = false.obs;
  final RxBool isSubmitting = false.obs;

  late final String? nextRoute;
  late final bool popOnDone;

  bool get canGoBack => nextRoute != null || popOnDone;

  AuthService get _auth => Get.find<AuthService>();

  /// Quem ja participou e retirou o consentimento ve o aviso de retorno.
  bool get isReturning => _auth.participant.value != null && !_auth.isActiveParticipant;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    nextRoute = args is Map ? args['next'] as String? : null;
    popOnDone = args is Map && args['popOnDone'] == true;
  }

  @override
  void onClose() {
    cohortCodeController.dispose();
    super.onClose();
  }

  Future<void> accept() async {
    if (!hasReadTerm.value || isSubmitting.value) return;
    isSubmitting.value = true;
    try {
      await ParticipantRepository().registerConsent(
        consentVersion: consentTermVersion,
        cohortCode: cohortCodeController.text,
      );
      await _auth.refreshParticipant();
      Toast.success('Participação registrada', 'Obrigado por participar da pesquisa.', delayed: true);
      _continue();
    } on ApiException catch (e) {
      final message = e.statusCode == 400 && cohortCodeController.text.trim().isNotEmpty
          ? 'Código de turma não encontrado. Confira com quem aplicou o estudo ou deixe em branco.'
          : e.message;
      Toast.error('Não foi possível registrar', message);
    } finally {
      isSubmitting.value = false;
    }
  }

  void decline() {
    if (canGoBack) {
      Get.back();
    } else {
      Get.offAllNamed(MainShellModule.path);
    }
  }

  void _continue() {
    if (nextRoute != null) {
      Get.offNamed(nextRoute!);
    } else if (popOnDone) {
      Get.back();
    } else {
      Get.offAllNamed(MainShellModule.path);
    }
  }
}
