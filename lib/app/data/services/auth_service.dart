import 'dart:convert';
import 'package:get/get.dart';
import 'package:phishing_quest/app/data/enumerators/storage_keys.enum.dart';
import 'package:phishing_quest/app/data/models/participant.model.dart';
import 'package:phishing_quest/app/data/models/user.model.dart';
import 'package:phishing_quest/app/data/repositories/login/login_repository.dart';
import 'package:phishing_quest/app/data/repositories/participant/participant_repository.dart';
import 'package:phishing_quest/app/data/storage/memory_storage.dart';
import 'package:phishing_quest/app/global_ui/components/toast.dart';
import 'package:phishing_quest/app/modules/initial/login/login_module.dart';

/// Sessao do usuario: JWT e perfil devolvidos por POST /users/login, e a
/// participacao no estudo (consentimento).
class AuthService extends GetxService {
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxBool isLoggedIn = false.obs;

  /// null = ainda nao consultado ou nunca consentiu.
  final Rx<ParticipantModel?> participant = Rx<ParticipantModel?>(null);

  /// Pesquisador e administrador fazem a curadoria dos itens.
  bool get canCurate => currentUser.value?.canCurate ?? false;

  bool get isActiveParticipant => participant.value?.active ?? false;

  final _tokenStore = MemoryStore(StorageKeys.USER_TOKEN);
  final _profileStore = MemoryStore(StorageKeys.PROFILE_INFO);

  bool _endingSession = false;

  Future<AuthService> init() async {
    _restoreSession();
    return this;
  }

  /// Retoma a sessao salva. Se o token tiver expirado, a primeira
  /// chamada a API devolve 401 e [onSessionExpired] leva ao login.
  void _restoreSession() {
    final token = _tokenStore.read<String>();
    final profileJson = _profileStore.read<String>();
    if (token == null || token.isEmpty || profileJson == null) {
      return;
    }
    try {
      currentUser.value = UserModel.fromJson(jsonDecode(profileJson) as Map<String, dynamic>);
      isLoggedIn.value = true;
    } catch (_) {
      _tokenStore.remove();
      _profileStore.remove();
    }
  }

  /// Autentica na API e guarda o token e o perfil. Lanca ApiException.
  Future<UserModel> login({required String email, required String password}) async {
    final result = await LoginRepository().login(email: email, password: password);
    await _tokenStore.write(result.token);
    await _saveProfile(result.user);
    isLoggedIn.value = true;
    participant.value = null;
    return result.user;
  }

  /// Consulta a participacao no estudo (GET /me/participant).
  Future<ParticipantModel?> refreshParticipant() async {
    participant.value = await ParticipantRepository().getMyParticipant();
    return participant.value;
  }

  /// Atualiza a pontuacao do ranking exibida no app.
  Future<void> updateScore(int totalScore) async {
    final user = currentUser.value;
    if (user == null || user.totalScore == totalScore) return;
    await _saveProfile(user.copyWith(totalScore: totalScore));
  }

  Future<void> _saveProfile(UserModel user) async {
    currentUser.value = user;
    await _profileStore.write(jsonEncode(user.toJson()));
  }

  Future<void> logout() async {
    await _tokenStore.remove();
    await _profileStore.remove();
    currentUser.value = null;
    participant.value = null;
    isLoggedIn.value = false;
  }

  /// Chamado pelo cliente HTTP quando a API recusa o token (401).
  void onSessionExpired() {
    if (_endingSession || !isLoggedIn.value) return;
    _endingSession = true;
    logout().then((_) {
      Get.offAllNamed(LoginModule.path);
      Toast.alert('Sessão expirada', 'Entre novamente para continuar.', delayed: true);
      _endingSession = false;
    });
  }
}
