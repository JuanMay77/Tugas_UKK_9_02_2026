import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static final _supabase = Supabase.instance.client;

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final userId = response.user!.id;

      final data = await _supabase
          .from('users')
          .select('Role')
          .eq('id', userId)
          .single();

      return {
        'Role': data['Role'],
      };
    } on AuthException catch (e) {
      return {
        'error': e.message, 
      };
    } catch (_) {
      return {
        'error': 'Terjadi kesalahan, coba lagi',
      };
    }
  }
}
