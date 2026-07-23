import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../models/transaction_model.dart';

class RecentTransactions extends StatelessWidget {
  final List<TransactionModel> transactions;
  const RecentTransactions({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text('Belum ada transaksi',
              style: TextStyle(color: AppColors.textSecondary)),
        ),
      );
    }

    return Column(
      children: transactions.map((t) {
        final isIncome = t.isIncome;
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            onTap: () => context.push('/transactions/${t.id}', extra: t),
            leading: CircleAvatar(
              backgroundColor: (isIncome ? AppColors.income : AppColors.expense)
                  .withValues(alpha: 0.12),
              child: Icon(
                isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                color: isIncome ? AppColors.income : AppColors.expense,
                size: 18,
              ),
            ),
            title: Text(t.category),
            subtitle: Text(DateFormatter.short(t.date)),
            trailing: Text(
              CurrencyFormatter.formatSigned(t.amount, isIncome: isIncome),
              style: TextStyle(
                color: isIncome ? AppColors.income : AppColors.expense,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
