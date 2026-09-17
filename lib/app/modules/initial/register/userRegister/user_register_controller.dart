import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phishing_quest/app/data/controllers/base_controller.dart';
import 'package:phishing_quest/app/data/repositories/register/register_repository.dart';
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
    if (password!.length <= 4) {
      return 'Senha deve ter mais de 4 caracteres';
    }
    return null;
  }

  Future onRegister() async {
    if (registerFormKey.currentState?.validate() ?? false) {
      setLoading(true);

      try {
        final registerRepo = RegisterRepository();
        final register = await registerRepo.register(
          username: usernameController.text,
          password: passwordController.text,
          email: emailController.text,
        );
      
        if (!register.valid) {
          setLoading(false);
          return Toast.error('Não foi possível realizar o cadastro', register.reason ?? 'Tente novamente', delayed: true);
        }

        // O backend ainda não emite token no cadastro (ver issue #10 do
        // repo phishing-quest-api). Até que exista um token real para
        // autenticar, redirecionamos ao login em vez de fabricar uma
        // sessão fake — evita persistir um usuário "logado" sem
        // credencial de verdade.
        setLoading(false);
        Toast.success('Cadastro realizado', 'Faça login para continuar', delayed: true);
        Get.offAllNamed(LoginModule.path);
        return;
      } catch (_) {
        Toast.error('Erro', 'Não foi possível realizar o cadastro');
      }
      
      setLoading(false);
    }
  }

  void onLogin() {
    Get.toNamed(LoginModule.path);
  }
}