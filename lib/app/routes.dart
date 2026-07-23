import 'package:go_router/go_router.dart';
import '../widgets/app_bottom_navigation.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/transactions/transactions_screen.dart';
import '../screens/transactions/add_transaction_screen.dart';
import '../screens/transactions/transaction_detail_screen.dart';
import '../models/transaction_model.dart';
import '../models/wallet_model.dart';
import '../screens/budget/budget_screen.dart';
import '../screens/budget/add_budget_screen.dart';
import '../screens/savings/savings_screen.dart';
import '../screens/savings/add_savings_screen.dart';
import '../screens/reports/reports_screen.dart';
import '../screens/wallets/wallets_screen.dart';
import '../screens/wallets/add_wallet_screen.dart';
import '../screens/transfer/transfer_screen.dart';
import '../screens/transfer/add_transfer_screen.dart';
import '../screens/calendar/calendar_screen.dart';
import '../screens/settings/settings_screen.dart';

/// Definisi routing aplikasi dengan go_router.
/// 5 tab utama dibungkus [AppBottomNavigation]; halaman sekunder
/// (budget, target tabungan, dompet, transfer, kalender) diakses dari Dashboard.
final GoRouter appRouter = GoRouter(
  initialLocation: '/dashboard',
  routes: [
    ShellRoute(
      builder: (context, state, child) => AppBottomNavigation(child: child),
      routes: [
        GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardScreen()),
        GoRoute(
            path: '/transactions',
            builder: (context, state) => const TransactionsScreen()),
        GoRoute(
            path: '/add',
            builder: (context, state) => const AddTransactionScreen()),
        GoRoute(
            path: '/reports',
            builder: (context, state) => const ReportsScreen()),
        GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen()),
      ],
    ),
    GoRoute(
      path: '/transactions/:id',
      builder: (context, state) {
        final tx = state.extra as TransactionModel;
        return TransactionDetailScreen(transaction: tx);
      },
    ),
    GoRoute(path: '/budget', builder: (context, state) => const BudgetScreen()),
    GoRoute(
        path: '/budget/add',
        builder: (context, state) => const AddBudgetScreen()),
    GoRoute(
        path: '/savings', builder: (context, state) => const SavingsScreen()),
    GoRoute(
        path: '/savings/add',
        builder: (context, state) => const AddSavingsScreen()),
    GoRoute(
        path: '/wallets', builder: (context, state) => const WalletsScreen()),
    GoRoute(
      path: '/wallets/add',
      builder: (context, state) {
        final wallet = state.extra as WalletModel?;
        return AddWalletScreen(wallet: wallet);
      },
    ),
    GoRoute(
        path: '/transfer', builder: (context, state) => const TransferScreen()),
    GoRoute(
        path: '/transfer/add',
        builder: (context, state) => const AddTransferScreen()),
    GoRoute(
        path: '/calendar', builder: (context, state) => const CalendarScreen()),
  ],
);
