import 'package:get/get.dart';
import 'package:phishing_quest/app/data/repositories/request_repository.dart';
import 'package:phishing_quest/app/data/services/auth_service.dart';
import 'package:phishing_quest/app/global_ui/components/toast.dart';
import 'package:phishing_quest/app/modules/consent/consent_module.dart';
import 'package:phishing_quest/app/modules/email_sim/email_sim_routes.dart';
import 'package:phishing_quest/app/modules/main_shell/main_shell_module.dart';

/// Para onde ir logo depois do login: quem ainda nao participa (ou
/// retirou o consentimento) ve o termo; quem participa vai ao inicio.
/// Pesquisador e administrador vao direto ao inicio; se quiserem jogar a
/// caixa de entrada, o termo aparece antes dela.
Future<void> goHomeAfterLogin() async {
  final auth = Get.find<AuthService>();
  if (auth.canCurate) {
    Get.offAllNamed(MainShellModule.path);
    return;
  }
  try {
    await auth.refreshParticipant();
  } catch (_) {
    // Sem conseguir consultar, segue para o inicio; a caixa de entrada
    // confere o consentimento de novo antes de abrir.
    Get.offAllNamed(MainShellModule.path);
    return;
  }

  if (auth.isActiveParticipant) {
    Get.offAllNamed(MainShellModule.path);
  } else {
    Get.offAllNamed(ConsentModule.path);
  }
}

/// Abre a caixa de entrada. Cada decisao nela e registrada para a
/// pesquisa, entao so participantes com consentimento ativo entram; os
/// demais veem o termo antes.
Future<void> openInbox() async {
  final auth = Get.find<AuthService>();
  try {
    await auth.refreshParticipant();
  } on ApiException catch (e) {
    Toast.error('Não foi possível abrir a caixa de entrada', e.message);
    return;
  }

  if (auth.isActiveParticipant) {
    Get.toNamed(EmailSimRoutes.inbox);
  } else {
    Get.toNamed(ConsentModule.path, arguments: {'next': EmailSimRoutes.inbox});
  }
}
