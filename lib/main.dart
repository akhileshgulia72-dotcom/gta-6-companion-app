import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:gta_6_comapnion_app/services/analytics_service.dart';
import 'package:gta_6_comapnion_app/services/auth_service.dart';

import 'package:gta_6_comapnion_app/splash_screen.dart';

import 'firebase_options.dart';
import 'firebase_api.dart';

int userCoins = 100;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ------------------------------------------------------------
  // ONLY Firebase initialization blocks app startup.
  // ------------------------------------------------------------

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ------------------------------------------------------------
  // START UI IMMEDIATELY
  // ------------------------------------------------------------

  runApp(const MyApp());

  // ------------------------------------------------------------
  // BACKGROUND INITIALIZATION
  // ------------------------------------------------------------

  WidgetsBinding.instance.addPostFrameCallback((_) {
    unawaited(
      _initializeBackgroundServices(),
    );
  });
}

Future<void> _initializeBackgroundServices() async {
  // Mobile Ads initialization runs after the first frame so it never delays
  // Firebase startup or the initial UI.
  try {
    await MobileAds.instance.initialize();
  } catch (e, stackTrace) {
    debugPrint('Mobile Ads initialization failed: $e');
    debugPrintStack(stackTrace: stackTrace);
  }

  // ------------------------------------------------------------
  // SHARED PREFERENCES
  // ------------------------------------------------------------

  try {
    final prefs = await SharedPreferences.getInstance();

    userCoins = prefs.getInt('coins') ?? 120;

    debugPrint(
      'Coins loaded: $userCoins',
    );
  } catch (e, stackTrace) {
    debugPrint(
      'SharedPreferences initialization failed: $e',
    );

    debugPrintStack(
      stackTrace: stackTrace,
    );
  }

  // ------------------------------------------------------------
  // AUTH
  // ------------------------------------------------------------

  try {
    await AuthService.initialize();

    debugPrint(
      'Auth initialized.',
    );
  } catch (e, stackTrace) {
    debugPrint(
      'Auth initialization failed: $e',
    );

    debugPrintStack(
      stackTrace: stackTrace,
    );
  }

  // ------------------------------------------------------------
  // ANALYTICS
  // ------------------------------------------------------------

  try {
    await AnalyticsService.appOpened();

    debugPrint(
      'Analytics initialized.',
    );
  } catch (e, stackTrace) {
    debugPrint(
      'Analytics initialization failed: $e',
    );

    debugPrintStack(
      stackTrace: stackTrace,
    );
  }

  // ------------------------------------------------------------
  // FIREBASE MESSAGING
  // ------------------------------------------------------------

  try {
    await FirebaseApi().initNotifications();

    debugPrint(
      'Notifications initialized.',
    );
  } catch (e, stackTrace) {
    debugPrint(
      'Notification initialization failed: $e',
    );

    debugPrintStack(
      stackTrace: stackTrace,
    );
  }
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

        scaffoldBackgroundColor:
            const Color(0xFF121212),

        primaryColor:
            const Color(0xFFFF4DA6),

        colorScheme: const ColorScheme.dark(
          secondary: Color(0xFF00D4FF),
        ),
      ),
    );
  }
}
