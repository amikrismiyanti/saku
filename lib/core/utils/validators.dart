/// Kumpulan validator sederhana untuk form transaksi/budget/target.
class Validators {
  Validators._();

  static String? required(String? value, {String field = 'Field ini'}) {
    if (value == null || value.trim().isEmpty) {
      return '$field wajib diisi';
    }
    return null;
  }

  static String? amount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nominal wajib diisi';
    }
    final cleaned = value.replaceAll(RegExp(r'[^0-9]'), '');
    final parsed = double.tryParse(cleaned);
    if (parsed == null || parsed <= 0) {
      return 'Nominal harus lebih dari 0';
    }
    return null;
  }
}
