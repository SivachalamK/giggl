import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/models/service_model.dart';
import '../../data/repositories/service_repository_impl.dart';

final servicesProvider = FutureProvider.family<List<ServiceModel>, ServicesFilter>(
  (ref, filter) async {
    final repo = ref.watch(serviceRepositoryProvider);
    return repo.getServices(
      category: filter.category,
      search: filter.search,
      lat: filter.lat,
      lng: filter.lng,
    );
  },
);

final serviceDetailProvider = FutureProvider.family<ServiceModel?, String>(
  (ref, id) async {
    return ref.watch(serviceRepositoryProvider).getServiceById(id);
  },
);

final categoriesProvider = FutureProvider<List<String>>((ref) async {
  return ref.watch(serviceRepositoryProvider).getCategories();
});

final sellerServicesProvider =
    FutureProvider.family<List<ServiceModel>, String>((ref, sellerId) async {
  return ref.watch(serviceRepositoryProvider).getSellerServices(sellerId);
});

class ServicesFilter {
  final String? category;
  final String? search;
  final double? lat;
  final double? lng;

  const ServicesFilter({this.category, this.search, this.lat, this.lng});

  @override
  bool operator ==(Object other) =>
      other is ServicesFilter &&
      category == other.category &&
      search == other.search;

  @override
  int get hashCode => Object.hash(category, search);
}

final servicesFilterProvider = StateProvider<ServicesFilter>(
  (ref) => const ServicesFilter(),
);
