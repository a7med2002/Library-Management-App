import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:library_managment/Core/Constants/app_colors.dart';
import 'package:library_managment/Core/Constants/app_text_styles.dart';
import 'package:library_managment/Core/Widgets/app_logo.dart';
import 'package:library_managment/Core/Widgets/background_circles.dart';
import 'package:library_managment/features/splash/controller/splash_controller.dart';

class SplashScreen extends GetView<SplashController> {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(SplashController());
    return Scaffold(
      backgroundColor: kPrimaryColor,
      body: Stack(
        children: [
          const BackgroundCircles(),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const AppLogo(size: 130),
                const SizedBox(height: 28),
                Text(
                  'مكتبة ومطبعة دار المقداد',
                  style: AppTextStyles.displayLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  'إدارة ذكية لمدفوعاتك',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: kWhiteColor.withOpacity(0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
