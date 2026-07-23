// Fitur export hanya untuk Flutter Web (sesuai stack proyek ini: Web + PWA).
// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:convert';
import 'dart:html' as html;
import '../../models/transaction_model.dart';

/// Export daftar transaksi menjadi file CSV yang otomatis ter-download
/// lewat browser (dipakai dari halaman Pengaturan).
class ExportService {
  ExportService._();

  static void exportTransactionsToCsv(List<TransactionModel> transactions) {
    final buffer = StringBuffer();
    buffer.writeln(
        'Tanggal,Jenis,Kategori,Nominal,Dompet ID,Metode Pembayaran,Keterangan');

    final sorted = [...transactions]..sort((a, b) => a.date.compareTo(b.date));
    for (final t in sorted) {
      final row = [
        t.date.toIso8601String(),
        t.isIncome ? 'Pemasukan' : 'Pengeluaran',
        _escape(t.category),
        t.amount.toStringAsFixed(0),
        _escape(t.walletId),
        _escape(t.paymentMethod ?? ''),
        _escape(t.description ?? ''),
      ];
      buffer.writeln(row.join(','));
    }

    _download(buffer.toString(),
        'finance_tracker_transaksi_${DateTime.now().millisecondsSinceEpoch}.csv');
  }

  static void _download(String csvContent, String filename) {
    final bytes = utf8.encode(csvContent);
    final blob = html.Blob([bytes], 'text/csv;charset=utf-8');
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..setAttribute('download', filename)
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  static String _escape(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }
}
