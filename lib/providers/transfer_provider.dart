import 'package:flutter/foundation.dart';
import '../models/transfer_model.dart';
import '../repositories/transfer_repository.dart';

class TransferProvider extends ChangeNotifier {
  final TransferRepository _repository = TransferRepository();

  List<TransferModel> _transfers = [];
  bool _isLoading = false;
  String? _error;

  List<TransferModel> get transfers => _transfers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadTransfers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _transfers = await _repository.getAll();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTransfer(TransferModel transfer) async {
    final created = await _repository.create(transfer);
    _transfers.insert(0, created);
    notifyListeners();
  }

  Future<void> deleteTransfer(String id) async {
    await _repository.delete(id);
    _transfers.removeWhere((t) => t.id == id);
    notifyListeners();
  }
}
