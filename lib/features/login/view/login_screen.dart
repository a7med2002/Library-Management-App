import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:library_managment/core/Constants/app_colors.dart';
import 'package:library_managment/core/Constants/app_text_styles.dart';
import 'package:library_managment/core/Widgets/app_logo.dart';
import 'package:library_managment/core/Widgets/background_circles.dart';
import 'package:library_managment/features/login/controller/login_controller.dart';

class LoginScreen extends GetView<LoginController> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(LoginController());
    return Scaffold(
      backgroundColor: kPrimaryColor,
      body: Column(
        children: [
          // ── Top Navy Section ──────────────────────────
          Expanded(
            flex: 5,
            child: Stack(
              children: [
                const BackgroundCircles(),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const AppLogo(size: 100),
                      const SizedBox(height: 20),
                      Text(
                        'مكتبة ومطبعة دار المقداد',
                        style: AppTextStyles.displayLarge,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Bottom White Card Section ─────────────────
          Expanded(
            flex: 4,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
              decoration: const BoxDecoration(
                color: kWhiteColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('تسجيل الدخول', style: AppTextStyles.titleMedium),
                  const SizedBox(height: 32),
                  const _GoogleSignInButton(),
                  const SizedBox(height: 16),
                  Text(
                    'للموظفين المعتمدين فقط',
                    style: AppTextStyles.caption.copyWith(
                      color: kSecondaryTextColor,
                    ),
                  ),
                  const Spacer(),
                  Text('الإصدار 1.0.0', style: AppTextStyles.caption),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Google Sign In Button ────────────────────────────────────
class _GoogleSignInButton extends GetView<LoginController> {
  const _GoogleSignInButton();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => SizedBox(
        width: double.infinity,
        height: 52,
        child: OutlinedButton(
          onPressed: controller.isLoading.value
              ? null
              : controller.signInWithGoogle,
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: kDividerColor),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: controller.isLoading.value
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: kPrimaryColor,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/images/google_logo.svg',
                      width: 22,
                      height: 22,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'تسجيل الدخول بحساب Google',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: kPrimaryTextColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
