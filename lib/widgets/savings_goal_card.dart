import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/currency_formatter.dart';
import '../core/utils/date_formatter.dart';
import '../models/savings_goal_model.dart';

/// Kartu target tabungan ala contoh di spesifikasi:
/// "Beli HP Baru — Target Rp5.000.000 — Terkumpul Rp2.000.000 — 40%"
class SavingsGoalCard extends StatelessWidget {
  final SavingsGoalModel goal;
  final VoidCallback? onAddFunds;
  final VoidCallback? onDelete;

  const SavingsGoalCard({
    super.key,
    required this.goal,
    this.onAddFunds,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final percent = (goal.progress * 100).clamp(0, 100).toStringAsFixed(0);
    final color = goal.isCompleted ? AppColors.income : AppColors.primary;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(goal.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                ),
                if (goal.isCompleted)
                  const Icon(Icons.check_circle,
                      color: AppColors.income, size: 18),
                if (onDelete != null)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18),
                    onPressed: onDelete,
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
            if (goal.deadline != null) ...[
              const SizedBox(height: 2),
              Text('Target selesai: ${DateFormatter.full(goal.deadline!)}',
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 12)),
            ],
            const SizedBox(height: 8),
            Text(
              '${CurrencyFormatter.format(goal.currentAmount)} / ${CurrencyFormatter.format(goal.targetAmount)}',
              style:
                  const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: goal.progress,
                minHeight: 10,
                backgroundColor: AppColors.border,
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text('$percent%',
                    style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
                const Spacer(),
                if (!goal.isCompleted && onAddFunds != null)
                  TextButton.icon(
                    onPressed: onAddFunds,
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Tambah Dana'),
                    style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
