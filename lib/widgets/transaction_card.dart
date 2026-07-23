import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/currency_formatter.dart';
import '../models/transaction_model.dart';

/// Kartu transaksi yang dipakai bersama di Dashboard & Riwayat Transaksi.
class TransactionCard extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback? onTap;

  const TransactionCard({super.key, required this.transaction, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.isIncome;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: (isIncome ? AppColors.income : AppColors.expense).withOpacity(0.12),
          child: Icon(
            isIncome ? Icons.arrow_downward : Icons.arrow_upward,
            color: isIncome ? AppColors.income : AppColors.expense,
            size: 18,
          ),
        ),
        title: Text(transaction.category, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: transaction.description != null && transaction.description!.isNotEmpty
            ? Text(transaction.description!, maxLines: 1, overflow: TextOverflow.ellipsis)
            : null,
        trailing: Text(
          CurrencyFormatter.formatSigned(transaction.amount, isIncome: isIncome),
          style: TextStyle(color: isIncome ? AppColors.income : AppColors.expense, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
