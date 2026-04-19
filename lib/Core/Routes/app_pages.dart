import 'package:get/get.dart';
import 'package:library_managment/Core/Routes/app_routes.dart';
import 'package:library_managment/features/add%20payment/view/add_payment_screen.dart';
import 'package:library_managment/features/add%20transfer/view/add_transfer_screen.dart';
import 'package:library_managment/features/bank%20match/view/bank_matching_screen.dart';
import 'package:library_managment/features/home/view/home_screen.dart';
import 'package:library_managment/features/login/view/login_screen.dart';
import 'package:library_managment/features/main/view/main_wrapper.dart';
import 'package:library_managment/features/payment/view/payments_screen.dart';
import 'package:library_managment/features/settings/view/add_account_screen.dart';
import 'package:library_managment/features/settings/view/settings_screen.dart';
import 'package:library_managment/features/splash/view/splash_screen.dart';
import 'package:library_managment/features/today%20report/view/report_screen.dart';
import 'package:library_managment/features/transfers/view/transfers_screen.dart';

class AppPages {
  AppPages._();

  static final List<GetPage> pages = [
    GetPage(name: AppRoutes.splash, page: () => const SplashScreen()),
    GetPage(name: AppRoutes.login, page: () => const LoginScreen()),
    GetPage(name: AppRoutes.home, page: () => const HomeScreen()),
    GetPage(name: AppRoutes.main, page: () => const MainWrapper()),
    GetPage(name: AppRoutes.payments, page: () => const PaymentsScreen()),
    GetPage(name: AppRoutes.transfers, page: () => const TransfersScreen()),
    GetPage(name: AppRoutes.addPayment, page: () => const AddPaymentScreen()),
    GetPage(name: AppRoutes.addTransfer, page: () => const AddTransferScreen()),
    GetPage(name: AppRoutes.report, page: () => const ReportScreen()),
    GetPage(
      name: AppRoutes.bankMatching,
      page: () => const BankMatchingScreen(),
    ),
    GetPage(name: AppRoutes.settings, page: () => const SettingsScreen()),
    GetPage(name: AppRoutes.addAccount, page: () => const AddAccountScreen()),
  ];
}
