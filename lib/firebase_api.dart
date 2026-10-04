import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseApi {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotifications() async {
    final settings = await _firebaseMessaging.requestPermission();

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      debugPrint('Notification permission was denied.');
      return;
    }

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      // FCM token requests on Apple platforms require the APNs token first.
      String? apnsToken;
      for (var attempt = 0; attempt < 10; attempt++) {
        apnsToken = await _firebaseMessaging.getAPNSToken();
        if (apnsToken != null) break;
        await Future<void>.delayed(const Duration(milliseconds: 500));
      }

      if (apnsToken == null) {
        debugPrint('APNs token is not available yet; skipping FCM token request.');
        return;
      }

      await _firebaseMessaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    final token = await _firebaseMessaging.getToken();

    debugPrint('FCM TOKEN: $token');
  }
}
