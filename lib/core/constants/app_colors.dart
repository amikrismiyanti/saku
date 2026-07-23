// lib/core/constants/app_colors.dart
import 'package:flutter/material.dart';

/// Palet warna utama aplikasi.
class AppColors {
  AppColors._();

  // ── Brand ──────────────────────────────────────────────
  static const Color primary = Color(0xFF0F766E);
  static const Color primaryLight = Color(0xFF14B8A6);
  static const Color primaryDark = Color(0xFF115E59);

  // ── Semantic (transaksi) ──────────────────────────────
  static const Color income = Color(0xFF16A34A);
  static const Color expense = Color(0xFFDC2626);
  static const Color transfer = Color(0xFF2563EB);

  // Varian semantic khusus dark mode: sedikit lebih terang/saturasi
  // supaya tetap jelas kebaca di atas surfaceDark (0xFF1E293B).
  static const Color incomeDark = Color(0xFF22C55E);
  static const Color expenseDark = Color(0xFFF87171);
  static const Color transferDark = Color(0xFF60A5FA);

  // ── Surface & Background ──────────────────────────────
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color backgroundDark = Color(0xFF0F172A);

  // ── Teks ───────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textOnDark = Color(0xFFF1F5F9);

  // Sebelumnya textSecondary (0xFF64748B) dipakai apa adanya di dark mode
  // -> terlalu redup di atas background gelap. Dinaikkan brightness-nya.
  static const Color textSecondaryDark = Color(0xFF94A3B8);

  // ── Border ─────────────────────────────────────────────
  // Border lama (0xFFE2E8F0) adalah abu-abu SANGAT terang — kalau dipakai
  // langsung di dark mode, garis card jadi menonjol seperti outline putih.
  // Border dark harus gelap, cuma sedikit lebih terang dari surface-nya.
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderDark = Color(0xFF334155);

  // ── Status ─────────────────────────────────────────────
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);
  static const Color warningDark = Color(0xFFFBBF24);
  static const Color dangerDark = Color(0xFFF87171);

  static const List<Color> chartPalette = [
    Color(0xFF0F766E),
    Color(0xFFF59E0B),
    Color(0xFF2563EB),
    Color(0xFFDC2626),
    Color(0xFF8B5CF6),
    Color(0xFFEC4899),
    Color(0xFF16A34A),
    Color(0xFF64748B),
  ];

  // Varian chart palette untuk dark mode (dinaikkan brightness-nya sedikit
  // supaya potongan pie chart tetap kebaca di atas surfaceDark).
  static const List<Color> chartPaletteDark = [
    Color(0xFF14B8A6),
    Color(0xFFFBBF24),
    Color(0xFF60A5FA),
    Color(0xFFF87171),
    Color(0xFFA78BFA),
    Color(0xFFF472B6),
    Color(0xFF22C55E),
    Color(0xFF94A3B8),
  ];

  // ── Helper adaptif ─────────────────────────────────────
  // Dipakai di widget yang masih hardcode `AppColors.xxx` supaya otomatis
  // pilih varian light/dark berdasarkan Theme saat ini. Ganti pemanggilan
  // `AppColors.textSecondary` -> `AppColors.textSecondaryOf(context)` dst,
  // secara bertahap di widget yang sering muncul di dark mode dulu
  // (EmptyState, TransactionCard, BudgetProgressBar, dsb).
  static bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color textSecondaryOf(BuildContext context) =>
      _isDark(context) ? textSecondaryDark : textSecondary;

  static Color textPrimaryOf(BuildContext context) =>
      _isDark(context) ? textOnDark : textPrimary;

  static Color borderOf(BuildContext context) =>
      _isDark(context) ? borderDark : border;

  static Color primaryOf(BuildContext context) =>
      _isDark(context) ? primaryLight : primary;

  static Color incomeOf(BuildContext context) =>
      _isDark(context) ? incomeDark : income;

  static Color expenseOf(BuildContext context) =>
      _isDark(context) ? expenseDark : expense;

  static Color transferOf(BuildContext context) =>
      _isDark(context) ? transferDark : transfer;

  static Color warningOf(BuildContext context) =>
      _isDark(context) ? warningDark : warning;

  static Color dangerOf(BuildContext context) =>
      _isDark(context) ? dangerDark : danger;

  static List<Color> chartPaletteOf(BuildContext context) =>
      _isDark(context) ? chartPaletteDark : chartPalette;
}
