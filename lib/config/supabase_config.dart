import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConfig {
  static String get supabaseUrl =>
      dotenv.env['SUPABASE_URL'] ?? 'https://okwbbfoslvfnyosdbubf.supabase.co';
  static String get supabaseAnonKey =>
      dotenv.env['SUPABASE_ANON_KEY'] ??
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9rd2JiZm9zbHZmbnlvc2RidWJmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTkwNzE5NTcsImV4cCI6MjA3NDY0Nzk1N30.hCXu8UPb6WX4imwKD_mgsmIY5HGNycgkJWUo3VfyRfw';

  static Future<void> initialize() async {
    // Load environment variables (ignore errors if .env doesn't exist)
    try {
      await dotenv.load(fileName: ".env");
    } catch (e) {
      // .env file doesn't exist, use fallback values
    }

    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      debug: true, // Set to false in production
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
  static GoTrueClient get auth => Supabase.instance.client.auth;
}
