import 'package:flutter/foundation.dart';
import '../models/wallet_model.dart';
import '../repositories/wallet_repository.dart';

class WalletProvider extends ChangeNotifier {
  final WalletRepository _repository = WalletRepository();

  List<WalletModel> _wallets = [];
  bool _isLoading = false;
  String? _error;

  List<WalletModel> get wallets => _wallets;
  bool get isLoading => _isLoading;
  String? get error => _error;
  double get totalBalance => _wallets.fold(0, (sum, w) => sum + w.balance);

  Future<void> loadWallets() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _wallets = await _repository.getAll();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addWallet(WalletModel wallet) async {
    final created = await _repository.create(wallet);
    _wallets.add(created);
    notifyListeners();
  }

  Future<void> deleteWallet(String id) async {
    await _repository.delete(id);
    _wallets.removeWhere((w) => w.id == id);
    notifyListeners();
  }
}
