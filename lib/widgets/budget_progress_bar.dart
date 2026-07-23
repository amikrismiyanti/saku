import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/currency_formatter.dart';
import '../models/budget_model.dart';

/// Kartu progress budget ala contoh di spesifikasi:
/// "Makanan  Rp650.000 / Rp1.000.000  ██████░░░░ 65%"
class BudgetProgressBar extends StatelessWidget {
  final BudgetModel budget;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const BudgetProgressBar(
      {super.key, required this.budget, this.onTap, this.onDelete});

  Color get _color {
    if (budget.isOverBudget) return AppColors.danger;
    if (budget.isNearLimit) return AppColors.warning;
    return AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    final percent = (budget.progress * 100).clamp(0, 999).toStringAsFixed(0);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(budget.category,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                  if (budget.isOverBudget)
                    const Icon(Icons.error_outline,
                        color: AppColors.danger, size: 18)
                  else if (budget.isNearLimit)
                    const Icon(Icons.warning_amber_rounded,
                        color: AppColors.warning, size: 18),
                  if (onDelete != null)
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 18),
                      onPressed: onDelete,
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${CurrencyFormatter.format(budget.spent)} / ${CurrencyFormatter.format(budget.amount)}',
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: budget.progress,
                  minHeight: 10,
                  backgroundColor: AppColors.border,
                  valueColor: AlwaysStoppedAnimation(_color),
                ),
              ),
              const SizedBox(height: 4),
              Text('$percent%',
                  style: TextStyle(
                      color: _color,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}
