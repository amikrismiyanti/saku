import 'package:intl/intl.dart';

/// Helper format mata uang Rupiah, mis. 2000000 -> "Rp2.000.000".
class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  );

  static String format(num amount) {
    return _formatter.format(amount);
  }

  /// Format dengan tanda + / - di depan, untuk ditampilkan di list transaksi.
  static String formatSigned(num amount, {required bool isIncome}) {
    final sign = isIncome ? '+' : '-';
    return '$sign ${_formatter.format(amount.abs())}';
  }

  /// Parse input teks user (mis. dari TextField) menjadi angka.
  static double parse(String input) {
    final cleaned = input.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.isEmpty) return 0;
    return double.parse(cleaned);
  }
}
