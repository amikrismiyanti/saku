import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants/app_constants.dart';
import '../core/services/supabase_service.dart';
import '../providers/auth_provider.dart';
import '../providers/budget_provider.dart';
import '../providers/savings_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/transfer_provider.dart';
import '../providers/wallet_provider.dart';
import 'routes.dart';
import 'theme.dart';

class FinanceTrackerApp extends StatelessWidget {
  const FinanceTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => WalletProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => BudgetProvider()),
        ChangeNotifierProvider(create: (_) => SavingsProvider()),
        ChangeNotifierProvider(create: (_) => TransferProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      // _AppRoot dibuat sebagai child DI BAWAH MultiProvider supaya
      // context-nya bisa mengakses semua provider di atas lewat context.read.
      child: const _AppRoot(),
    );
  }
}

class _AppRoot extends StatefulWidget {
  const _AppRoot();

  @override
  State<_AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<_AppRoot> {
  late final StreamSubscription<AuthState> _authSubscription;

  @override
  void initState() {
    super.initState();
    // Begitu user logout (atau sesi berakhir), bersihkan semua cache data
    // di provider supaya user/akun berikutnya yang login di device yang
    // sama tidak sempat melihat sisa data akun sebelumnya.
    _authSubscription =
        SupabaseService.client.auth.onAuthStateChange.listen((data) {
      if (data.event == AuthChangeEvent.signedOut) {
        _clearAllProviderCaches();
      }
    });
  }

  void _clearAllProviderCaches() {
    if (!mounted) return;
    context.read<WalletProvider>().clear();
    context.read<TransactionProvider>().clear();
    context.read<BudgetProvider>().clear();
    context.read<SavingsProvider>().clear();
    context.read<TransferProvider>().clear();
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeProvider.mode,
      routerConfig: appRouter,
    );
  }
}
