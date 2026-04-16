import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static Future<void> initializeSupabase() async {
    try {
      // Ensure .env is loaded
      if (!dotenv.isInitialized) {
        throw Exception(
          ".env file not loaded. Did you call dotenv.load() in main()?",
        );
      }

      final url = dotenv.env['url'];
      final anonKey = dotenv.env['anonkey'];

      if (url == null || url.isEmpty) {
        throw Exception("Missing 'url' in .env file.");
      }

      if (anonKey == null || anonKey.isEmpty) {
        throw Exception("Missing 'anonkey' in .env file.");
      }

      await Supabase.initialize(url: url, anonKey: anonKey);
    } catch (e) {
      // Re-throw with context
      throw Exception("Supabase initialization failed: $e");
    }
  }

  static SupabaseClient get client => Supabase.instance.client;
}
