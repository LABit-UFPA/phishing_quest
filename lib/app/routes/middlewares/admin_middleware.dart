import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phishing_quest/app/data/services/auth_service.dart';

class AdminMiddleware extends GetMiddleware {
  @override
  int? get priority => 2;

  @override
  RouteSettings? redirect(String? route) {
    final authService = Get.find<AuthService>();
    if (!authService.canCurate) {
      return const RouteSettings(name: '/main');
    }
    return null;
  }
}
