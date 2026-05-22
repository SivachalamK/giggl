import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/data/demo_data.dart';
import '../features/services/data/repositories/service_repository_impl.dart';
import '../shared/models/service_model.dart';

class RecommendationService {
  RecommendationService(this._serviceRepo);

  final ServiceRepository _serviceRepo;

  Future<List<ServiceModel>> getRecommendations({
    String? userId,
    List<String>? pastCategories,
    int limit = 10,
  }) async {
    final all = await _serviceRepo.getServices(limit: 50);
    if (all.isEmpty) return DemoData.demoServices;

    final scored = all.map((service) {
      var score = service.rating ?? 4.0;
      if (pastCategories?.contains(service.category) ?? false) {
        score += 2.0;
      }
      score += (service.reviewCount / 100).clamp(0, 1);
      return MapEntry(service, score);
    }).toList();

    scored.sort((a, b) => b.value.compareTo(a.value));
    return scored.take(limit).map((e) => e.key).toList();
  }
}

final recommendationServiceProvider = Provider<RecommendationService>(
  (ref) => RecommendationService(ref.watch(serviceRepositoryProvider)),
);

final recommendationsProvider = FutureProvider<List<ServiceModel>>((ref) async {
  return ref.watch(recommendationServiceProvider).getRecommendations();
});
