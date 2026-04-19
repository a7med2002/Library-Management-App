import 'package:get/get.dart';
import 'package:library_managment/Core/Routes/app_routes.dart';
import 'package:library_managment/Core/Services/auth_service.dart';

class LoginController extends GetxController {
  final RxBool isLoading = false.obs;

  Future<void> signInWithGoogle() async {
    try {
      isLoading.value = true;
      final user = await AuthService.signInWithGoogle();
      if (user != null) {
        Get.offAllNamed(AppRoutes.main);
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل تسجيل الدخول، حاول مجدداً',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
