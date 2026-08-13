import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:gta_6_comapnion_app/services/analytics_service.dart';
import 'package:gta_6_comapnion_app/services/auth_service.dart';
import 'package:gta_6_comapnion_app/services/premium_state.dart';

import 'package:gta_6_comapnion_app/splash_screen.dart';

import 'firebase_options.dart';
import 'firebase_api.dart';

import 'package:shared_preferences/shared_preferences.dart';

int userCoins = 100;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize GTA 6 PRO system
  await premiumState.initialize();

  // =========================================================
  // TEST MODE ONLY
  // This makes the current app installation behave as PRO.
  // REMOVE THIS LINE BEFORE RELEASE / PRODUCTION BUILD.
  // =========================================================
  premiumState.enableTestPremium();

  // Firebase anonymous authentication
  await AuthService.initialize();

  // Analytics
  await AnalyticsService.appOpened();

  // Notifications
  await FirebaseApi().initNotifications();

  // Load coins
  final prefs = await SharedPreferences.getInstance();

  userCoins = prefs.getInt("coins") ?? 120;

  // Start app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      home: const SplashScreen(),

      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: const Color(0xFFFF4DA6),

        colorScheme: const ColorScheme.dark(
          secondary: Color(0xFF00D4FF),
        ),
      ),
    );
  }
}