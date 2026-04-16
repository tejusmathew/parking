import '../config/supabase_config.dart';

class UserHelper {
  final supabase = SupabaseConfig.client;

  String? getCurrentUserEmail() {
    return supabase.auth.currentUser?.email;
  }
}
