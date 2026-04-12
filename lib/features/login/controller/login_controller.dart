import 'package:get/get.dart';
import 'package:library_managment/Core/Routes/app_routes.dart';

class LoginController extends GetxController {
  final RxBool isLoading = false.obs;

  Future<void> signInWithGoogle() async {
    try {
      isLoading.value = true;
      await Future.delayed(const Duration(seconds: 2));
      Get.offAllNamed(AppRoutes.main);
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
