import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/utils/date_formatter.dart';
import '../../providers/budget_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../widgets/budget_progress_bar.dart';
import '../../widgets/empty_state.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final txProvider = context.read<TransactionProvider>();
    if (txProvider.transactions.isEmpty) {
      await txProvider.loadTransactions();
    }
    if (!mounted) return;
    await context
        .read<BudgetProvider>()
        .loadBudgets(transactionProvider: txProvider);
  }

  Future<void> _confirmDelete(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Budget?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Hapus')),
        ],
      ),
    );
    if (confirmed == true) {
      await context.read<BudgetProvider>().deleteBudget(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final budgetProvider = context.watch<BudgetProvider>();
    final monthLabel = DateFormatter.monthYear(
        DateTime(budgetProvider.year, budgetProvider.month));

    return Scaffold(
      appBar: AppBar(title: const Text('Budget')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await context.push('/budget/add');
          if (mounted) _load();
        },
        icon: const Icon(Icons.add),
        label: const Text('Tambah Budget'),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: budgetProvider.isLoading && budgetProvider.budgets.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(monthLabel,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 16),
                  if (budgetProvider.budgets.isEmpty)
                    const EmptyState(
                      message:
                          'Belum ada budget bulan ini.\nTekan "Tambah Budget" untuk mulai.',
                      icon: Icons.pie_chart_outline,
                    )
                  else
                    ...budgetProvider.budgets.map(
                      (b) => BudgetProgressBar(
                        budget: b,
                        onDelete: () => _confirmDelete(b.id),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
