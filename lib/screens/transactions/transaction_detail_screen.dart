import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/transaction_model.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../widgets/custom_button.dart';
import 'add_transaction_screen.dart';

class TransactionDetailScreen extends StatefulWidget {
  final String transactionId;
  final TransactionModel? transaction;

  const TransactionDetailScreen({
    super.key,
    required this.transactionId,
    this.transaction,
  });

  @override
  State<TransactionDetailScreen> createState() =>
      _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  TransactionModel? _tx;
  bool _isLoading = false;
  bool _notFound = false;

  @override
  void initState() {
    super.initState();
    _tx = widget.transaction;
    if (_tx == null) {
      // extra hilang (mis. setelah refresh browser di Web) -> ambil dari provider,
      // load ulang dari Supabase dulu kalau cache-nya masih kosong.
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _resolveTransaction());
    }
  }

  Future<void> _resolveTransaction() async {
    setState(() => _isLoading = true);
    final provider = context.read<TransactionProvider>();
    if (provider.transactions.isEmpty) {
      await provider.loadTransactions();
    }
    if (!mounted) return;
    final found = provider.getById(widget.transactionId);
    setState(() {
      _tx = found;
      _notFound = found == null;
      _isLoading = false;
    });
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final tx = _tx;
    if (tx == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Transaksi?'),
        content: const Text(
            'Transaksi ini akan dihapus permanen dan saldo dompet akan disesuaikan kembali.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child:
                const Text('Hapus', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await context.read<TransactionProvider>().deleteTransaction(tx.id);
        await context.read<WalletProvider>().loadWallets();
        if (context.mounted) {
          context.pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Transaksi dihapus')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Gagal menghapus: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Transaksi')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_notFound || _tx == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Transaksi')),
        body: const Center(child: Text('Transaksi tidak ditemukan.')),
      );
    }

    final transaction = _tx!;
    final isIncome = transaction.isIncome;
    final color = isIncome ? AppColors.income : AppColors.expense;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Transaksi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                Icon(isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                    color: color, size: 32),
                const SizedBox(height: 8),
                Text(
                  CurrencyFormatter.formatSigned(transaction.amount,
                      isIncome: isIncome),
                  style: TextStyle(
                      color: color, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(transaction.category,
                    style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _DetailRow(
              label: 'Tanggal', value: DateFormatter.full(transaction.date)),
          _DetailRow(
              label: 'Metode Pembayaran',
              value: transaction.paymentMethod ?? '-'),
          _DetailRow(
              label: 'Keterangan', value: transaction.description ?? '-'),
          const SizedBox(height: 28),
          CustomButton(
            label: 'Edit Transaksi',
            icon: Icons.edit_outlined,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) =>
                        AddTransactionScreen(transaction: transaction)),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label,
                style: const TextStyle(color: AppColors.textSecondary)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
