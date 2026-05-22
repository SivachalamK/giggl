import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../shared/models/service_model.dart';

abstract class WishlistRepository {
  Future<List<ServiceModel>> getWishlist(String userId);
  Future<void> add(String userId, String serviceId);
  Future<void> remove(String userId, String serviceId);
  Future<bool> isWishlisted(String userId, String serviceId);
}

class WishlistRepositoryImpl implements WishlistRepository {
  WishlistRepositoryImpl(this._client);

  final SupabaseClient _client;

  @override
  Future<List<ServiceModel>> getWishlist(String userId) async {
    final data = await _client
        .from('wishlists')
        .select('services(*, categories(name), sellers(business_name))')
        .eq('user_id', userId);
    return (data as List).map((e) {
      final service = Map<String, dynamic>.from(e['services']);
      service['category'] = service['categories']?['name'] ?? '';
      service['seller_name'] = service['sellers']?['business_name'];
      return ServiceModel.fromJson(service);
    }).toList();
  }

  @override
  Future<void> add(String userId, String serviceId) async {
    await _client.from('wishlists').upsert({
      'user_id': userId,
      'service_id': serviceId,
    });
  }

  @override
  Future<void> remove(String userId, String serviceId) async {
    await _client
        .from('wishlists')
        .delete()
        .eq('user_id', userId)
        .eq('service_id', serviceId);
  }

  @override
  Future<bool> isWishlisted(String userId, String serviceId) async {
    final data = await _client
        .from('wishlists')
        .select('id')
        .eq('user_id', userId)
        .eq('service_id', serviceId)
        .maybeSingle();
    return data != null;
  }
}

final wishlistRepositoryProvider = Provider<WishlistRepository>(
  (ref) => WishlistRepositoryImpl(ref.watch(supabaseClientProvider)),
);

final wishlistProvider = FutureProvider<List<ServiceModel>>((ref) async {
  final userId = ref.watch(currentUserProvider)?.id;
  if (userId == null) return [];
  return ref.watch(wishlistRepositoryProvider).getWishlist(userId);
});
