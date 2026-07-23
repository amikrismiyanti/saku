import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/export_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/transaction_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _exportData(BuildContext context) async {
    final txProvider = context.read<TransactionProvider>();
    if (txProvider.transactions.isEmpty) {
      await txProvider.loadTransactions();
    }
    if (!context.mounted) return;
    if (txProvider.transactions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Belum ada transaksi untuk diexport')),
      );
      return;
    }
    ExportService.exportTransactionsToCsv(txProvider.transactions);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('File CSV sedang diunduh...')),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Keluar?'),
        content: const Text(
            'Kamu perlu login kembali untuk mengakses data keuanganmu.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child:
                const Text('Keluar', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<AuthProvider>().signOut();
      // Redirect ke /login ditangani otomatis oleh GoRouter (lihat routes.dart)
      // begitu status auth berubah.
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Akun',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0x1A0F766E),
                child: Icon(Icons.person_outline, color: AppColors.primary),
              ),
              title: Text(authProvider.currentUser?.email ?? '-'),
              subtitle: const Text('Akun yang sedang masuk'),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.logout, color: AppColors.danger),
              title: const Text('Keluar',
                  style: TextStyle(color: AppColors.danger)),
              onTap: () => _confirmLogout(context),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Tampilan',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: SegmentedButton<ThemeMode>(
                segments: const [
                  ButtonSegment(
                      value: ThemeMode.light,
                      label: Text('Terang'),
                      icon: Icon(Icons.light_mode_outlined)),
                  ButtonSegment(
                      value: ThemeMode.dark,
                      label: Text('Gelap'),
                      icon: Icon(Icons.dark_mode_outlined)),
                  ButtonSegment(
                      value: ThemeMode.system,
                      label: Text('Sistem'),
                      icon: Icon(Icons.settings_suggest_outlined)),
                ],
                selected: {themeProvider.mode},
                onSelectionChanged: (s) => themeProvider.setMode(s.first),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Data',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.file_download_outlined),
              title: const Text('Export Transaksi ke CSV'),
              subtitle:
                  const Text('Unduh seluruh riwayat transaksi (hanya di Web)'),
              onTap: () => _exportData(context),
            ),
          ),
        ],
      ),
    );
  }
}
