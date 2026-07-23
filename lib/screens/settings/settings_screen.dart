import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/export_service.dart';
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

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
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
          const SizedBox(height: 24),
          const Text('Tentang',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.info_outline),
              title: Text(AppConstants.appName),
              subtitle: const Text(
                  'Aplikasi keuangan pribadi — Flutter Web + Supabase + PWA'),
            ),
          ),
        ],
      ),
    );
  }
}
