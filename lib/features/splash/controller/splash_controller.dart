import 'package:get/get.dart';
import 'package:library_managment/Core/Routes/app_routes.dart';
import 'package:library_managment/Core/Services/auth_service.dart';
import 'package:library_managment/Core/Services/objectbox_service.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _checkSession();
  }

  Future<void> _checkSession() async {
    await Future.delayed(const Duration(seconds: 3));
    await ObjectBoxService.init();
    (AuthService.isLoggedIn)
        ? Get.offAllNamed(AppRoutes.main)
        : Get.offAllNamed(AppRoutes.login);
  }
}
