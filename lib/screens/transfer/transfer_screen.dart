import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/transfer_model.dart';
import '../../providers/transfer_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../widgets/empty_state.dart';

/// Riwayat transfer antar dompet. Transfer TIDAK dihitung sebagai
/// pemasukan/pengeluaran karena uangnya masih tetap milik kamu,
/// hanya berpindah dompet.
class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransferProvider>().loadTransfers();
    });
  }

  String _walletName(String id, List wallets) {
    for (final w in wallets) {
      if (w.id == id) return w.name;
    }
    return '(dompet dihapus)';
  }

  Future<void> _confirmDelete(TransferModel transfer) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Transfer?'),
        content: const Text(
            'Saldo kedua dompet akan dikembalikan seperti sebelum transfer ini.'),
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
    if (confirmed == true && mounted) {
      await context.read<TransferProvider>().deleteTransfer(transfer.id);
      await context.read<WalletProvider>().loadWallets();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransferProvider>();
    final wallets = context.watch<WalletProvider>().wallets;

    return Scaffold(
      appBar: AppBar(title: const Text('Transfer Antar Dompet')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await context.push('/transfer/add');
          if (mounted) context.read<TransferProvider>().loadTransfers();
        },
        icon: const Icon(Icons.add),
        label: const Text('Transfer'),
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<TransferProvider>().loadTransfers(),
        child: provider.isLoading && provider.transfers.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : provider.transfers.isEmpty
                ? LayoutBuilder(
                    builder: (context, constraints) => SingleChildScrollView(
                      physics:
                          const AlwaysScrollableScrollPhysics(), // wajib, biar RefreshIndicator tetap bisa di-drag walau konten pendek
                      child: ConstrainedBox(
                        constraints:
                            BoxConstraints(minHeight: constraints.maxHeight),
                        child: const Center(
                          child: EmptyState(
                            message: 'Belum ada transfer antar dompet.',
                            icon: Icons.swap_horiz,
                          ),
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.transfers.length,
                    itemBuilder: (context, i) {
                      final t = provider.transfers[i];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Color(0x1A2563EB),
                            child: Icon(Icons.swap_horiz,
                                color: AppColors.transfer, size: 18),
                          ),
                          title: Text(
                              '${_walletName(t.fromWalletId, wallets)} → ${_walletName(t.toWalletId, wallets)}'),
                          subtitle: Text(DateFormatter.short(t.date) +
                              (t.description != null
                                  ? ' • ${t.description}'
                                  : '')),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(CurrencyFormatter.format(t.amount),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.transfer)),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete_outline, size: 18),
                                onPressed: () => _confirmDelete(t),
                                visualDensity: VisualDensity.compact,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
