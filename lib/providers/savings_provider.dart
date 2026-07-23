import 'package:flutter/foundation.dart';
import '../models/savings_goal_model.dart';
import '../repositories/savings_repository.dart';

class SavingsProvider extends ChangeNotifier {
  final SavingsRepository _repository = SavingsRepository();

  List<SavingsGoalModel> _goals = [];
  bool _isLoading = false;
  String? _error;

  List<SavingsGoalModel> get goals => _goals;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<SavingsGoalModel> get ongoing =>
      _goals.where((g) => !g.isCompleted).toList();
  List<SavingsGoalModel> get completed =>
      _goals.where((g) => g.isCompleted).toList();

  Future<void> loadGoals() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _goals = await _repository.getAll();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addGoal(SavingsGoalModel goal) async {
    final created = await _repository.create(goal);
    _goals.add(created);
    notifyListeners();
  }

  Future<void> deleteGoal(String id) async {
    await _repository.delete(id);
    _goals.removeWhere((g) => g.id == id);
    notifyListeners();
  }

  /// Tambah dana ke target tabungan tertentu.
  Future<void> addFunds(SavingsGoalModel goal, double amount) async {
    final newCurrent = goal.currentAmount + amount;
    final updated = await _repository.updateProgress(
      goal.id,
      newCurrent,
      status: newCurrent >= goal.targetAmount ? 'completed' : 'ongoing',
    );
    final index = _goals.indexWhere((g) => g.id == goal.id);
    if (index != -1) {
      _goals[index] = updated;
      notifyListeners();
    }
  }
}
