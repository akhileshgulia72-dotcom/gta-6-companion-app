import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuthService {
  static final SupabaseClient _supabase =
      Supabase.instance.client;

  static Future<AuthResponse> initialize() async {
    final existingUser = _supabase.auth.currentUser;

    if (existingUser != null) {
      return AuthResponse(
        session: _supabase.auth.currentSession,
        user: existingUser,
      );
    }

    return await _supabase.auth.signInAnonymously();
  }

  static String? get userId =>
      _supabase.auth.currentUser?.id;

  static User? get currentUser =>
      _supabase.auth.currentUser;
}