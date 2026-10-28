import 'package:get/get.dart';
import 'package:phishing_quest/app/modules/consent/consent_controller.dart';
import 'package:phishing_quest/app/modules/consent/consent_view.dart';
import 'package:phishing_quest/app/routes/middlewares/auth_middleware.dart';

class ConsentModule {
  static const path = '/consent';

  static GetPage page = GetPage(
    name: path,
    page: () => const ConsentView(),
    binding: BindingsBuilder(() {
      Get.lazyPut<ConsentController>(() => ConsentController());
    }),
    middlewares: [AuthMiddleware()],
  );
}
