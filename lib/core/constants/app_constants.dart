/// Konstanta umum aplikasi.
class AppConstants {
  AppConstants._();

  static const String appName = 'Finance Tracker';

  // Ganti sesuai project Supabase kamu.
  // Jangan commit key asli — pakai --dart-define atau file .env.
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://rbjfjyiofvxhxxibwgwr.supabase.co',
  );
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJiamZqeWlvZnZ4aHh4aWJ3Z3dyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODQ3ODk0MjgsImV4cCI6MjEwMDM2NTQyOH0.m07Y-5aupeQphVYNbxs8alMqkrGWa0fKkw6CEd7ofy0',
  );

  static const String defaultCurrency = 'IDR';

  static const List<String> walletTypes = ['cash', 'bank', 'e-wallet'];
}

enum TransactionType { income, expense }

enum WalletType { cash, bank, eWallet }
