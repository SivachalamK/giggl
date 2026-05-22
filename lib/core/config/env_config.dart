import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static String get supabaseUrl =>
      dotenv.env['SUPABASE_URL'] ?? 'https://placeholder.supabase.co';

  static String get supabaseAnonKey =>
      dotenv.env['SUPABASE_ANON_KEY'] ?? 'placeholder-anon-key';

  static String get razorpayKeyId =>
      dotenv.env['RAZORPAY_KEY_ID'] ?? 'rzp_test_placeholder';

  static String get googleMapsApiKey =>
      dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';

  static String get googleWebClientId =>
      dotenv.env['GOOGLE_WEB_CLIENT_ID'] ?? '';

  static Future<void> validate() async {
    // Non-blocking validation for dev
  }
}
