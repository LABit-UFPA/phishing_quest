import 'package:get/get.dart';
import 'package:phishing_quest/app/data/controllers/base_controller.dart';
import 'package:phishing_quest/app/modules/initial/login/login_module.dart';
import 'package:phishing_quest/app/modules/initial/register/userRegister/user_register_module.dart';

class FlowInitialController extends BaseController {
  void onLogin() {
    Get.toNamed(LoginModule.path);
  }

  void onRegister() {
    Get.toNamed(UserRegisterModule.path);
  }
}
