import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<User?> initialize() async {
    try {
      if (_auth.currentUser != null) {
        return _auth.currentUser;
      }

      final credential = await _auth.signInAnonymously();

      debugPrint(
        'Anonymous Firebase user: ${credential.user?.uid}',
      );

      return credential.user;
    } on FirebaseAuthException catch (e) {
      debugPrint(
        'Firebase Auth Error: ${e.code} - ${e.message}',
      );
      return null;
    } catch (e) {
      debugPrint('Firebase Auth Error: $e');
      return null;
    }
  }

  static User? get currentUser => _auth.currentUser;

  static String? get userId => _auth.currentUser?.uid;
}