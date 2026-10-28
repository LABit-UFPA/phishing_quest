import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phishing_quest/app/data/controllers/base_controller.dart';
import 'package:phishing_quest/app/data/repositories/register/register_repository.dart';
import 'package:phishing_quest/app/data/repositories/request_repository.dart';
import 'package:phishing_quest/app/data/services/auth_service.dart';
import 'package:phishing_quest/app/data/services/session_router.dart';
import 'package:phishing_quest/app/global_ui/components/toast.dart';
import 'package:phishing_quest/app/modules/initial/login/login_module.dart';

class UserRegisterController extends BaseController {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> registerFormKey = GlobalKey<FormState>();

  String? validateName(String? nome) {
    if (nome?.isEmpty ?? true) {
      return 'Campo obrigatório';
    }
    if (nome!.length <= 2) {
      return 'Nome deve ter mais de 2 caracteres';
    }
    return null;
  }

  String? validateEmail(String? email) {
    if (email?.isEmpty ?? true) {
      return 'Campo obrigatório';
    }
    if (!GetUtils.isEmail(email!)) {
      return 'Formato de email inválido';
    }
    return null;
  }

  String? validatePassword(String? password) {
    if (password?.isEmpty ?? true) {
      return 'Campo obrigatório';
    }
    if (password!.length < 8) {
      return 'Senha deve ter ao menos 8 caracteres';
    }
    return null;
  }

  Future<void> onRegister() async {
    if (registerFormKey.currentState?.validate() ?? false) {
      setLoading(true);

      try {
        await RegisterRepository().register(
          username: usernameController.text.trim(),
          password: passwordController.text,
          email: emailController.text.trim(),
        );
      } on ApiException catch (e) {
        setLoading(false);
        Toast.error('Não foi possível realizar o cadastro', e.message, delayed: true);
        return;
      } catch (_) {
        setLoading(false);
        Toast.error('Erro', 'Não foi possível realizar o cadastro');
        return;
      }

      // O cadastro nao devolve token: entra com as mesmas credenciais.
      try {
        await Get.find<AuthService>().login(
          email: emailController.text.trim(),
          password: passwordController.text,
        );
        await goHomeAfterLogin();
      } catch (_) {
        Toast.success('Cadastro realizado', 'Faça login para continuar', delayed: true);
        Get.offAllNamed(LoginModule.path);
      }
      setLoading(false);
    }
  }

  void onLogin() {
    Get.toNamed(LoginModule.path);
  }
}