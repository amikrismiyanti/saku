import '../core/services/supabase_service.dart';
import '../models/savings_goal_model.dart';

/// Ganti isi savings_repository.dart lama kamu dengan file ini
/// (menambahkan method updateProgress untuk fitur "tambah dana").
class SavingsRepository {
  final _table = SupabaseService.client.from('savings_goals');

  Future<List<SavingsGoalModel>> getAll() async {
    final data = await _table.select().order('created_at');
    return (data as List).map((e) => SavingsGoalModel.fromJson(e)).toList();
  }

  Future<SavingsGoalModel> create(SavingsGoalModel goal) async {
    final data = await _table.insert(goal.toJson()).select().single();
    return SavingsGoalModel.fromJson(data);
  }

  /// Menambah dana ke target tabungan: update current_amount & status.
  Future<SavingsGoalModel> updateProgress(
    String id,
    double currentAmount, {
    required String status,
  }) async {
    final data = await _table
        .update({'current_amount': currentAmount, 'status': status})
        .eq('id', id)
        .select()
        .single();
    return SavingsGoalModel.fromJson(data);
  }

  Future<void> delete(String id) async {
    await _table.delete().eq('id', id);
  }
}
