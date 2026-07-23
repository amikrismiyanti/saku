import 'package:flutter/foundation.dart';
import '../core/constants/app_constants.dart';
import '../core/utils/date_formatter.dart';
import '../models/transaction_model.dart';
import '../repositories/transaction_repository.dart';

class TransactionProvider extends ChangeNotifier {
  final TransactionRepository _repository = TransactionRepository();

  List<TransactionModel> _transactions = [];
  bool _isLoading = false;
  String? _error;

  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<TransactionModel> get thisMonth {
    final now = DateTime.now();
    final start = DateFormatter.startOfMonth(now);
    final end = DateFormatter.endOfMonth(now);
    return _transactions
        .where((t) =>
            t.date.isAfter(start.subtract(const Duration(seconds: 1))) &&
            t.date.isBefore(end.add(const Duration(seconds: 1))))
        .toList();
  }

  double get totalIncomeThisMonth => thisMonth
      .where((t) => t.type == TransactionType.income)
      .fold(0, (sum, t) => sum + t.amount);

  double get totalExpenseThisMonth => thisMonth
      .where((t) => t.type == TransactionType.expense)
      .fold(0, (sum, t) => sum + t.amount);

  List<TransactionModel> get recent =>
      (_transactions.toList()..sort((a, b) => b.date.compareTo(a.date)))
          .take(5)
          .toList();

  Future<void> loadTransactions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _transactions = await _repository.getAll();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTransaction(TransactionModel tx) async {
    final created = await _repository.create(tx);
    _transactions.add(created);
    notifyListeners();
  }

  Future<void> updateTransaction(TransactionModel tx) async {
    final updated = await _repository.update(tx);
    final index = _transactions.indexWhere((t) => t.id == tx.id);
    if (index != -1) {
      _transactions[index] = updated;
      notifyListeners();
    }
  }

  Future<void> deleteTransaction(String id) async {
    await _repository.delete(id);
    _transactions.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  TransactionModel? getById(String id) {
    try {
      return _transactions.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Total pengeluaran per kategori dalam rentang [start, end) apapun —
  /// dipakai oleh BudgetProvider dan halaman Laporan.
  Map<String, double> expenseByCategoryForRange(DateTime start, DateTime end) {
    final map = <String, double>{};
    for (final t in _transactions.where((t) =>
        t.type == TransactionType.expense &&
        !t.date.isBefore(start) &&
        t.date.isBefore(end))) {
      map[t.category] = (map[t.category] ?? 0) + t.amount;
    }
    return map;
  }

  /// Total pemasukan & pengeluaran dalam rentang [start, end), untuk grafik Laporan.
  ({double income, double expense}) totalsForRange(
      DateTime start, DateTime end) {
    double income = 0;
    double expense = 0;
    for (final t in _transactions) {
      if (t.date.isBefore(start) || !t.date.isBefore(end)) continue;
      if (t.type == TransactionType.income) {
        income += t.amount;
      } else {
        expense += t.amount;
      }
    }
    return (income: income, expense: expense);
  }

  /// Total pengeluaran per kategori bulan ini, untuk pie chart dashboard/laporan.
  Map<String, double> expenseByCategoryThisMonth() {
    final now = DateTime.now();
    return expenseByCategoryForRange(
      DateFormatter.startOfMonth(now),
      DateFormatter.endOfMonth(now).add(const Duration(seconds: 1)),
    );
  }
}
