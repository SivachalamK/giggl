import 'package:supabase_flutter/supabase_flutter.dart';

abstract class SellerRepository {
  Future<Map<String, dynamic>?> getSeller(String userId);
  Future<void> updateSeller(String userId, Map<String, dynamic> data);
  Future<void> uploadPortfolio(String userId, List<String> urls);
}

class SellerRepositoryImpl implements SellerRepository {
  SellerRepositoryImpl(this._client);

  final SupabaseClient _client;

  @override
  Future<Map<String, dynamic>?> getSeller(String userId) async {
    return _client.from('sellers').select().eq('user_id', userId).maybeSingle();
  }

  @override
  Future<void> updateSeller(String userId, Map<String, dynamic> data) async {
    await _client.from('sellers').update(data).eq('user_id', userId);
  }

  @override
  Future<void> uploadPortfolio(String userId, List<String> urls) async {
    await _client.from('sellers').update({'portfolio_urls': urls}).eq('user_id', userId);
  }
}
