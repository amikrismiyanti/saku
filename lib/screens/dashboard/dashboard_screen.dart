import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/wallet_provider.dart';
import 'widgets/balance_card.dart';
import 'widgets/income_card.dart';
import 'widgets/expense_card.dart';
import 'widgets/recent_transactions.dart';
import 'widgets/quick_menu.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WalletProvider>().loadWallets();
      context.read<TransactionProvider>().loadTransactions();
    });
  }

  Future<void> _onRefresh() async {
    await context.read<WalletProvider>().loadWallets();
    await context.read<TransactionProvider>().loadTransactions();
  }

  @override
  Widget build(BuildContext context) {
    final walletProvider = context.watch<WalletProvider>();
    final txProvider = context.watch<TransactionProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            BalanceCard(balance: walletProvider.totalBalance),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                    child: IncomeCard(amount: txProvider.totalIncomeThisMonth)),
                const SizedBox(width: 12),
                Expanded(
                    child:
                        ExpenseCard(amount: txProvider.totalExpenseThisMonth)),
              ],
            ),
            const SizedBox(height: 24),
            const QuickMenu(),
            const SizedBox(height: 24),
            const Text('Transaksi Terbaru',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            RecentTransactions(transactions: txProvider.recent),
          ],
        ),
      ),
    );
  }
}
