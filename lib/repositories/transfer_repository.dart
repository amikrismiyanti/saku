import '../core/services/supabase_service.dart';
import '../models/transfer_model.dart';

/// Repository untuk transfer antar dompet.
/// Penyesuaian saldo kedua dompet (kurang di asal, tambah di tujuan)
/// ditangani otomatis oleh trigger database di supabase/migration_tahap4.sql,
/// jadi di sini cukup insert/delete baris transfer.
class TransferRepository {
  final _table = SupabaseService.client.from('transfers');

  Future<List<TransferModel>> getAll() async {
    final data = await _table.select().order('date', ascending: false);
    return (data as List).map((e) => TransferModel.fromJson(e)).toList();
  }

  Future<TransferModel> create(TransferModel transfer) async {
    final data = await _table.insert(transfer.toJson()).select().single();
    return TransferModel.fromJson(data);
  }

  Future<void> delete(String id) async {
    await _table.delete().eq('id', id);
  }
}
