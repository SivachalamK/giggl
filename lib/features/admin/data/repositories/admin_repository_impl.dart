import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AdminRepository {
  Future<List<Map<String, dynamic>>> getPendingSellers();
  Future<void> approveSeller(String userId);
  Future<void> rejectSeller(String userId);
  Future<List<Map<String, dynamic>>> getAllUsers({int limit = 100});
  Future<List<Map<String, dynamic>>> getComplaints();
  Future<double> getTotalRevenue();
  Future<List<Map<String, dynamic>>> getBanners();
  Future<void> createBanner(Map<String, dynamic> data);
}

class AdminRepositoryImpl implements AdminRepository {
  AdminRepositoryImpl(this._client);

  final SupabaseClient _client;

  @override
  Future<List<Map<String, dynamic>>> getPendingSellers() async {
    return List<Map<String, dynamic>>.from(
      await _client
          .from('sellers')
          .select('*, users(full_name, email, phone)')
          .eq('status', 'pending'),
    );
  }

  @override
  Future<void> approveSeller(String userId) async {
    await _client.from('sellers').update({'status': 'approved'}).eq('user_id', userId);
    await _client.from('seller_verification').update({'status': 'approved'}).eq('seller_id', userId);
  }

  @override
  Future<void> rejectSeller(String userId) async {
    await _client.from('sellers').update({'status': 'rejected'}).eq('user_id', userId);
  }

  @override
  Future<List<Map<String, dynamic>>> getAllUsers({int limit = 100}) async {
    return List<Map<String, dynamic>>.from(
      await _client.from('users').select().limit(limit),
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getComplaints() async {
    return List<Map<String, dynamic>>.from(
      await _client.from('complaints').select('*, users(full_name)').order('created_at', ascending: false),
    );
  }

  @override
  Future<double> getTotalRevenue() async {
    final data = await _client.from('payments').select('amount').eq('status', 'completed');
    return (data as List).fold<double>(0, (s, e) => s + ((e['amount'] as num?)?.toDouble() ?? 0));
  }

  @override
  Future<List<Map<String, dynamic>>> getBanners() async {
    return List<Map<String, dynamic>>.from(
      await _client.from('banners').select().eq('is_active', true).order('sort_order'),
    );
  }

  @override
  Future<void> createBanner(Map<String, dynamic> data) async {
    await _client.from('banners').insert(data);
  }
}
