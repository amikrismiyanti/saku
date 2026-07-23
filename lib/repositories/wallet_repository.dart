import '../core/services/supabase_service.dart';
import '../models/wallet_model.dart';

class WalletRepository {
  final _table = SupabaseService.client.from('wallets');

  Future<List<WalletModel>> getAll() async {
    final data = await _table.select().order('created_at');
    return (data as List).map((e) => WalletModel.fromJson(e)).toList();
  }

  Future<WalletModel> create(WalletModel wallet) async {
    final data = await _table.insert(wallet.toJson()).select().single();
    return WalletModel.fromJson(data);
  }

  Future<WalletModel> update(WalletModel wallet) async {
    final data = await _table.update(wallet.toJson()).eq('id', wallet.id).select().single();
    return WalletModel.fromJson(data);
  }

  Future<void> delete(String id) async {
    await _table.delete().eq('id', id);
  }
}
