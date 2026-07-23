import 'dart:async';
import 'package:flutter/foundation.dart';

/// Menjembatani Stream (mis. Supabase auth state changes) ke Listenable
/// yang bisa dipakai sebagai `refreshListenable` di GoRouter, supaya
/// router otomatis re-evaluate `redirect()` setiap kali status login berubah
/// (login, logout, token refresh, dll).
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
