import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:library_managment/core/Routes/app_pages.dart';
import 'package:library_managment/core/Routes/app_routes.dart';
import 'package:library_managment/core/Services/notification_service.dart';
import 'package:library_managment/core/Services/objectbox_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  await ObjectBoxService.init();

  debugPrint('✅ ObjectBox initialized: ${ObjectBoxService.isReady}');

  await NotificationService.init();

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
      getPages: AppPages.pages,
    );
  }
}
