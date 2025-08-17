import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:url_strategy/url_strategy.dart';
import 'app/app_theme.dart';

import 'app/routes/app_pages.dart';
import 'app/controllers/auth_controller.dart';
import 'firebase_options.dart'; // Import the generated file

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure URL strategy for web
  setPathUrlStrategy();

  // Initialize Firebase with the generated options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Supabase (for authentication)
  await Supabase.initialize(
    url: 'https://qpobjystpqtmhffdjrol.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFwb2JqeXN0cHF0bWhmZmRqcm9sIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTUxMDk2NzIsImV4cCI6MjA3MDY4NTY3Mn0.F_-5Myzq4ITOHpIcS2LAqdO5THyMyPKHu5nlhKsRGtQ',
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final AuthController authController = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Treasure Hunt',
      initialRoute: AppPages.initial,
      getPages: AppPages.pages,
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      defaultTransition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}
