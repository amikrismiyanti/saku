import 'package:flutter/material.dart';

/// Provider sederhana untuk toggle Light / Dark / System dari halaman
/// Pengaturan. Tidak dipersist ke storage — cukup untuk sesi berjalan;
/// tambahkan shared_preferences kalau mau disimpan permanen.
class ThemeProvider extends ChangeNotifier {
  ThemeMode _mode = ThemeMode.system;
  ThemeMode get mode => _mode;

  void setMode(ThemeMode mode) {
    if (_mode == mode) return;
    _mode = mode;
    notifyListeners();
  }
}
