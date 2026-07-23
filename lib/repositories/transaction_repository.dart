import '../core/services/supabase_service.dart';
import '../models/transaction_model.dart';

class TransactionRepository {
  final _table = SupabaseService.client.from('transactions');

  Future<List<TransactionModel>> getAll({DateTime? from, DateTime? to}) async {
    var query = _table.select();
    if (from != null) {
      query = query.gte('date', from.toIso8601String());
    }
    if (to != null) {
      query = query.lte('date', to.toIso8601String());
    }
    final data = await query.order('date', ascending: false);
    return (data as List).map((e) => TransactionModel.fromJson(e)).toList();
  }

  Future<TransactionModel> create(TransactionModel tx) async {
    final data = await _table.insert(tx.toJson()).select().single();
    return TransactionModel.fromJson(data);
  }

  Future<TransactionModel> update(TransactionModel tx) async {
    final data = await _table.update(tx.toJson()).eq('id', tx.id).select().single();
    return TransactionModel.fromJson(data);
  }

  Future<void> delete(String id) async {
    await _table.delete().eq('id', id);
  }
}
