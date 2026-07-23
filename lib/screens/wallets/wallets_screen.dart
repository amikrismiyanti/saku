import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/wallet_model.dart';
import '../../providers/wallet_provider.dart';
import '../../widgets/empty_state.dart';

class WalletsScreen extends StatefulWidget {
  const WalletsScreen({super.key});

  @override
  State<WalletsScreen> createState() => _WalletsScreenState();
}

class _WalletsScreenState extends State<WalletsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<WalletProvider>();
      if (provider.wallets.isEmpty) provider.loadWallets();
    });
  }

  IconData _iconFor(String type) {
    switch (type) {
      case 'bank':
        return Icons.account_balance_outlined;
      case 'e-wallet':
        return Icons.credit_card_outlined;
      default:
        return Icons.payments_outlined;
    }
  }

  Future<void> _confirmDelete(WalletModel wallet) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Dompet?'),
        content: Text(
            'Dompet "${wallet.name}" akan dihapus. Transaksi yang terkait dengan dompet ini sebaiknya dipindahkan/dihapus dulu.'),
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
      try {
        await context.read<WalletProvider>().deleteWallet(wallet.id);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menghapus: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WalletProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dompet'),
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_horiz),
            tooltip: 'Transfer Antar Dompet',
            onPressed: () => context.push('/transfer'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await context.push('/wallets/add');
          if (mounted) context.read<WalletProvider>().loadWallets();
        },
        icon: const Icon(Icons.add),
        label: const Text('Tambah Dompet'),
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<WalletProvider>().loadWallets(),
        child: provider.isLoading && provider.wallets.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : provider.wallets.isEmpty
                ? LayoutBuilder(
                    builder: (context, constraints) => SingleChildScrollView(
                      physics:
                          const AlwaysScrollableScrollPhysics(), // wajib, biar RefreshIndicator tetap bisa di-drag walau konten pendek
                      child: ConstrainedBox(
                        constraints:
                            BoxConstraints(minHeight: constraints.maxHeight),
                        child: const Center(
                          child: EmptyState(
                            message:
                                'Belum ada dompet.\nTekan "Tambah Dompet" untuk mulai.',
                            icon: Icons.account_balance_wallet_outlined,
                          ),
                        ),
                      ),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Card(
                        color: AppColors.primary.withValues(alpha: 0.06),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              const Text('Total Saldo',
                                  style:
                                      TextStyle(fontWeight: FontWeight.w600)),
                              const Spacer(),
                              Text(
                                CurrencyFormatter.format(provider.totalBalance),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...provider.wallets.map(
                        (w) => Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  AppColors.primary.withValues(alpha: 0.1),
                              child: Icon(_iconFor(w.type),
                                  color: AppColors.primary, size: 20),
                            ),
                            title: Text(w.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                            subtitle: Text(w.type),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(CurrencyFormatter.format(w.balance),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline,
                                      size: 18),
                                  onPressed: () => _confirmDelete(w),
                                  visualDensity: VisualDensity.compact,
                                ),
                              ],
                            ),
                            onTap: () async {
                              await context.push('/wallets/add', extra: w);
                              if (mounted)
                                context.read<WalletProvider>().loadWallets();
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}
