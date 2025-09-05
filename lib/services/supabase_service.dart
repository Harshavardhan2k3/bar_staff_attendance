import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseService get instance => _instance ??= SupabaseService._();

  SupabaseService._();

  static const String supabaseUrl =
      String.fromEnvironment('https://bsrilanxohmuwvqsftih.supabase.co', defaultValue: '');
  static const String supabaseAnonKey =
      String.fromEnvironment('eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJzcmlsYW54b2htdXd2cXNmdGloIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTcwNDk4NDcsImV4cCI6MjA3MjYyNTg0N30.Wqlp6n983-4XHaOFBwG6PaCEIJMpFdom6XVCmfZFYIw', defaultValue: '');

  // Initialize Supabase - call this in main()
  static Future<void> initialize() async {
    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      throw Exception(
          'SUPABASE_URL and SUPABASE_ANON_KEY must be defined using --dart-define.');
    }

    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  // Get Supabase client
  SupabaseClient get client => Supabase.instance.client;
}
