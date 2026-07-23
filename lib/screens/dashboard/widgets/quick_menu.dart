import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';

/// Grid menu akses cepat ke halaman yang tidak masuk bottom navigation:
/// Budget, Target Tabungan, Dompet, Transfer, Kalender.
class QuickMenu extends StatelessWidget {
  const QuickMenu({super.key});

  static const _items = [
    (icon: Icons.pie_chart_outline, label: 'Budget', route: '/budget'),
    (icon: Icons.savings_outlined, label: 'Target Tabungan', route: '/savings'),
    (
      icon: Icons.account_balance_wallet_outlined,
      label: 'Dompet',
      route: '/wallets'
    ),
    (icon: Icons.swap_horiz, label: 'Transfer', route: '/transfer'),
    (
      icon: Icons.calendar_month_outlined,
      label: 'Kalender',
      route: '/calendar'
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: _items.map((item) {
        return InkWell(
          onTap: () => context.push(item.route),
          borderRadius: BorderRadius.circular(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(item.icon, color: AppColors.primary, size: 22),
              ),
              const SizedBox(height: 6),
              Text(
                item.label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11),
                maxLines: 2,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
