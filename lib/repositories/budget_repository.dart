import '../core/services/supabase_service.dart';
import '../models/budget_model.dart';

class BudgetRepository {
  final _table = SupabaseService.client.from('budgets');

  Future<List<BudgetModel>> getByMonth(int month, int year) async {
    final data = await _table.select().eq('month', month).eq('year', year);
    return (data as List).map((e) => BudgetModel.fromJson(e)).toList();
  }

  Future<BudgetModel> create(BudgetModel budget) async {
    final data = await _table.insert(budget.toJson()).select().single();
    return BudgetModel.fromJson(data);
  }

  Future<void> delete(String id) async {
    await _table.delete().eq('id', id);
  }
}
