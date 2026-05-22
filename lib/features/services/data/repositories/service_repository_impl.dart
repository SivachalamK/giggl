import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/data/demo_data.dart';
import '../../../../shared/models/service_model.dart';

abstract class ServiceRepository {
  Future<List<ServiceModel>> getServices({
    String? category,
    String? search,
    double? lat,
    double? lng,
    int limit = 20,
    int offset = 0,
  });
  Future<ServiceModel?> getServiceById(String id);
  Future<List<ServiceModel>> getSellerServices(String sellerId);
  Future<ServiceModel> createService(Map<String, dynamic> data);
  Future<ServiceModel> updateService(String id, Map<String, dynamic> data);
  Future<void> deleteService(String id);
  Future<List<String>> getCategories();
}

class ServiceRepositoryImpl implements ServiceRepository {
  ServiceRepositoryImpl(this._client);

  final SupabaseClient _client;

  @override
  Future<List<ServiceModel>> getServices({
    String? category,
    String? search,
    double? lat,
    double? lng,
    int limit = 20,
    int offset = 0,
  }) async {
    var query = _client
        .from('services')
        .select('*, categories(name), sellers(business_name)')
        .eq('is_active', true);

    if (category != null && category.isNotEmpty) {
      query = query.eq('category_id', category);
    }

    if (search != null && search.isNotEmpty) {
      query = query.ilike('title', '%$search%');
    }

    try {
      final data = await query
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return (data as List).map((e) {
      final map = Map<String, dynamic>.from(e);
      map['category'] = map['categories']?['name'] ?? '';
      map['seller_name'] = map['sellers']?['business_name'];
      return ServiceModel.fromJson(map);
      }).toList();
    } catch (_) {
      return DemoData.demoServices;
    }
  }

  @override
  Future<ServiceModel?> getServiceById(String id) async {
    try {
      final data = await _client
          .from('services')
          .select('*, categories(name), sellers(business_name)')
          .eq('id', id)
          .maybeSingle();
      if (data == null) {
        return _demoServiceById(id);
      }
      final map = Map<String, dynamic>.from(data);
      map['category'] = map['categories']?['name'] ?? '';
      map['seller_name'] = map['sellers']?['business_name'];
      return ServiceModel.fromJson(map);
    } catch (_) {
      return _demoServiceById(id);
    }
  }

  ServiceModel? _demoServiceById(String id) {
    for (final s in DemoData.demoServices) {
      if (s.id == id) return s;
    }
    return null;
  }

  @override
  Future<List<ServiceModel>> getSellerServices(String sellerId) async {
    try {
      final data = await _client
          .from('services')
          .select('*, categories(name)')
          .eq('seller_id', sellerId)
          .order('created_at', ascending: false);
      return (data as List).map((e) {
        final map = Map<String, dynamic>.from(e);
        map['category'] = map['categories']?['name'] ?? '';
        return ServiceModel.fromJson(map);
      }).toList();
    } catch (_) {
      return DemoData.demoServices
          .where((s) => s.sellerId == sellerId)
          .toList();
    }
  }

  @override
  Future<ServiceModel> createService(Map<String, dynamic> data) async {
    final result =
        await _client.from('services').insert(data).select().single();
    return ServiceModel.fromJson(result);
  }

  @override
  Future<ServiceModel> updateService(
    String id,
    Map<String, dynamic> data,
  ) async {
    final result = await _client
        .from('services')
        .update(data)
        .eq('id', id)
        .select()
        .single();
    return ServiceModel.fromJson(result);
  }

  @override
  Future<void> deleteService(String id) async {
    await _client.from('services').update({'is_active': false}).eq('id', id);
  }

  @override
  Future<List<String>> getCategories() async {
    try {
      final data = await _client.from('categories').select('name').order('name');
      return (data as List).map((e) => e['name'] as String).toList();
    } catch (_) {
      return DemoData.demoServices.map((s) => s.category).toSet().toList();
    }
  }
}

final serviceRepositoryProvider = Provider<ServiceRepository>(
  (ref) => ServiceRepositoryImpl(ref.watch(supabaseClientProvider)),
);
