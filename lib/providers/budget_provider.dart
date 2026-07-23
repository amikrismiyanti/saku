import 'package:flutter/foundation.dart';
import '../models/budget_model.dart';
import '../repositories/budget_repository.dart';
import 'transaction_provider.dart';

class BudgetProvider extends ChangeNotifier {
  final BudgetRepository _repository = BudgetRepository();

  List<BudgetModel> _budgets = [];
  bool _isLoading = false;
  String? _error;
  int _month = DateTime.now().month;
  int _year = DateTime.now().year;

  List<BudgetModel> get budgets => _budgets;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get month => _month;
  int get year => _year;

  /// Budget yang pengeluarannya sudah >= 80% dari limit, untuk notifikasi/badge.
  List<BudgetModel> get nearLimitOrOver =>
      _budgets.where((b) => b.isNearLimit || b.isOverBudget).toList();

  /// Muat budget untuk bulan/tahun tertentu, sekaligus hitung "spent" dari
  /// transaksi yang sudah ada di [TransactionProvider] (harus di-load duluan).
  Future<void> loadBudgets({
    required TransactionProvider transactionProvider,
    int? month,
    int? year,
  }) async {
    _month = month ?? _month;
    _year = year ?? _year;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final raw = await _repository.getByMonth(_month, _year);
      final start = DateTime(_year, _month, 1);
      final end = DateTime(_year, _month + 1, 1);
      final spentMap = transactionProvider.expenseByCategoryForRange(start, end);
      _budgets = raw.map((b) => b.copyWithSpent(spentMap[b.category] ?? 0)).toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addBudget(BudgetModel budget) async {
    final created = await _repository.create(budget);
    _budgets.add(created);
    notifyListeners();
  }

  Future<void> deleteBudget(String id) async {
    await _repository.delete(id);
    _budgets.removeWhere((b) => b.id == id);
    notifyListeners();
  }
}
