import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:library_managment/core/Routes/app_routes.dart';
import 'package:library_managment/core/Services/auth_service.dart';
import 'package:library_managment/core/Services/notification_service.dart';
import 'package:library_managment/core/Services/objectbox_service.dart';
import 'package:library_managment/core/Services/store_service.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _checkSession();
  }

  Future<void> _checkSession() async {
    await Future.delayed(const Duration(seconds: 2));

    try {

      final firebaseUser = FirebaseAuth.instance.currentUser;
      final localUser = ObjectBoxService.getUser();

      // ✅ لازم الاثنين يكونوا موجودين
      if (firebaseUser == null || localUser == null) {
        await _goToLogin();
        return;
      }

      // ✅ استخدم initStore مش storeId getter
      await StoreService.initStore(
        uid: firebaseUser.uid,
        email: firebaseUser.email ?? '',
      );

      await NotificationService.onUserLoggedIn();
      Get.offAllNamed(AppRoutes.main);
    } catch (e) {
      debugPrint('❌ Session Error: $e');
      await _goToLogin();
    }
  }

  Future<void> _goToLogin() async { 
    await AuthService.signOut();
    Get.offAllNamed(AppRoutes.login);
  }
}
