import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:library_managment/Core/Routes/app_routes.dart';
import 'package:library_managment/features/add%20payment/view/add_payment_screen.dart';
import 'package:library_managment/features/add%20transfer/view/add_transfer_screen.dart';
import 'package:library_managment/features/bank%20match/view/bank_matching_screen.dart';
import 'package:library_managment/features/home/view/home_screen.dart';
import 'package:library_managment/features/login/view/login_screen.dart';
import 'package:library_managment/features/main/view/main_wrapper.dart';
import 'package:library_managment/features/payment/view/payments_screen.dart';
import 'package:library_managment/features/settings/view/settings_screen.dart';
import 'package:library_managment/features/splash/view/splash_screen.dart';
import 'package:library_managment/features/today%20report/view/report_screen.dart';
import 'package:library_managment/features/transfers/view/transfers_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'مكتبة ومطبعة دار المقداد',
      //------------ Set the default locale to Arabic------------
      locale: const Locale('ar'),
      fallbackLocale: const Locale('ar'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ar')],
      builder: (context, child) {
        return Directionality(textDirection: TextDirection.rtl, child: child!);
      },
      // --------------------Font type----------------------------
      theme: ThemeData(fontFamily: 'Tajawal'),
      // ---------------------------------------------------------
      initialRoute: AppRoutes.splash,
      getPages: [
        GetPage(name: AppRoutes.splash, page: () => const SplashScreen()),
        GetPage(name: AppRoutes.login, page: () => const LoginScreen()),
        GetPage(name: AppRoutes.home, page: () => const HomeScreen()),
        GetPage(name: AppRoutes.main, page: () => const MainWrapper()),
        GetPage(name: AppRoutes.payments, page: () => const PaymentsScreen()),
        GetPage(name: AppRoutes.transfers, page: () => const TransfersScreen()),
        GetPage(
          name: AppRoutes.addPayment,
          page: () => const AddPaymentScreen(),
        ),
        GetPage(
          name: AppRoutes.addTransfer,
          page: () => const AddTransferScreen(),
        ),
        GetPage(name: AppRoutes.report, page: () => const ReportScreen()),
        GetPage(
          name: AppRoutes.bankMatching,
          page: () => const BankMatchingScreen(),
        ),
        GetPage(
          name: AppRoutes.settings,
          page: () => const SettingsScreen(),
        ),
      ],
    );
  }
}
