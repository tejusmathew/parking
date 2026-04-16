import '../config/supabase_config.dart';

class AuthService {
  final supabase = SupabaseConfig.client;
  Future<bool> signIn(String email, String password) async {
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response.user != null;
    } catch (e) {
      print(e);
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
      );
      return response.user != null;
    }
  }
}
