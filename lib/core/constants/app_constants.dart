class AppConstants {
  AppConstants._();

  static const String appName = 'Finance Tracker';

  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
  );

  static const String defaultCurrency = 'IDR';

  static const List<String> walletTypes = [
    'cash',
    'bank',
    'e-wallet',
  ];
}

enum TransactionType {
  income,
  expense,
}

enum WalletType {
  cash,
  bank,
  eWallet,
}
