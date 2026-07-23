import 'package:flutter/services.dart';
import 'currency_formatter.dart';

/// TextInputFormatter yang otomatis menambahkan pemisah ribuan
/// saat user mengetik nominal, mis. "2000000" tampil sebagai "2.000.000".
class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.isEmpty) {
      return const TextEditingValue(text: '');
    }
    final value = double.parse(digitsOnly);
    final formatted = CurrencyFormatter.format(value).replaceAll('Rp', '').trim();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
