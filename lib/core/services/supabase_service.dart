import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/app_constants.dart';

/// Wrapper tipis di atas Supabase client.
///
/// Panggil [SupabaseService.initialize] sekali di main() sebelum runApp().
/// Setelah itu akses client lewat `SupabaseService.client` di mana saja,
/// termasuk dari repositories/.
class SupabaseService {
  SupabaseService._();

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: AppConstants.supabaseUrl,
      publishableKey: AppConstants.supabaseAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
