import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:phishing_quest/app/data/constants/environments.dart';
import 'package:phishing_quest/app/data/services/auth_service.dart';
import 'package:phishing_quest/app/data/services/telemetry_service.dart';
import 'package:phishing_quest/app/data/util/helpers/index.dart';
import 'package:phishing_quest/app/modules/initial/flow_initial/flow_initial_module.dart';
import 'package:phishing_quest/app/modules/main_shell/main_shell_module.dart';

import 'app/data/providers/pq_api_client/pq_api_client.provider.dart';
import 'app/main_getx_app.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await initProviders();

  final initialPage = getInitPage();
  FlutterNativeSplash.remove();

  runApp(
    ScreenUtilInit(
      designSize: const Size(430, 932),
      ensureScreenSize: true,
      splitScreenMode: false,
      builder: (_, __) => MainGetXApp(initialPage),
    ),
  );
}

String getInitPage() {
  final auth = Get.find<AuthService>();
  if (auth.isLoggedIn.value) {
    return MainShellModule.path;
  }
  return FlowInitialModule.path;
}

Future<void> initProviders() async {
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await GetStorage.init();

  await Helpers().setLocalMode(USE_LOCAL_ENV);
  Get.put<PqApiClient>(PqApiClient(), permanent: true);

  // Auth Service — precisa ser sincronizado antes de decidir a rota inicial
  final authService = Get.put(AuthService(), permanent: true);
  await authService.init();

  // Telemetria: reenvia o que ficou pendente da ultima execucao.
  final telemetry = Get.put(TelemetryService(), permanent: true);
  await telemetry.init();
  if (authService.isLoggedIn.value) {
    telemetry.flush();
  }

  await ScreenUtil.ensureScreenSize();
}
