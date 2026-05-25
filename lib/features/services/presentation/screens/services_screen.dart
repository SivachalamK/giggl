import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared/widgets/cards/service_card.dart';
import '../../../../shared/widgets/loading/shimmer_loader.dart';
import '../../../../shared/widgets/states/empty_state.dart';
import '../../../../shared/widgets/states/error_state.dart';
import '../../../../services/recommendation_service.dart';
import '../providers/services_provider.dart';

class ServicesScreen extends ConsumerWidget {
  const ServicesScreen({super.key, this.category});

  final String? category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    final filter = ServicesFilter(category: category);
    final servicesAsync = ref.watch(servicesProvider(filter));

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
                child: SafeArea(
                  child: Stack(
                    children: [
                      Positioned(
                        top: -60,
                        right: -60,
                        child: Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              'Find services for\nyour next event',
                              style: TextStyle(
                                fontSize: Responsive.value(
                                  context,
                                  mobile: 28,
                                  desktop: 36,
                                ),
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                height: 1.1,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 16),
                            GestureDetector(
                              onTap: () => context.go('/search'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.1),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.search, color: colors.primary, size: 20),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Search photographers, DJs...',
                                      style: TextStyle(
                                        color: colors.onSurface.withValues(alpha: 0.4),
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: AppConstants.serviceCategories.length,
                itemBuilder: (_, i) {
                  final cat = AppConstants.serviceCategories[i];
                  final icon = AppConstants.categoryIcons[cat] ?? '🎉';
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: GestureDetector(
                      onTap: () => context.push('/services?category=$cat'),
                      child: Column(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: colors.card,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: colors.border),
                            ),
                            child: Center(
                              child: Text(icon, style: const TextStyle(fontSize: 24)),
                            ),
                          ),
                          const SizedBox(height: 6),
                          SizedBox(
                            width: 70,
                            child: Text(
                              cat.split(' ').first,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Recommended for you',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: Responsive.value(context, mobile: 16, desktop: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 200,
              child: ref.watch(recommendationsProvider).when(
                data: (recs) => ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: recs.length,
                  itemBuilder: (_, i) => SizedBox(
                    width: 160,
                    child: ServiceCard(
                      service: recs[i],
                      index: i,
                      onTap: () => context.push('/seller/${recs[i].sellerId}'),
                    ),
                  ),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ),
          ),
          SliverPadding(
            padding: Responsive.padding(context),
            sliver: servicesAsync.when(
              data: (services) {
                if (services.isEmpty) {
                  return SliverFillRemaining(
                    child: EmptyState(
                      title: 'No services found',
                      subtitle: 'Try a different category or search',
                      actionLabel: 'Explore All',
                      onAction: () => context.go('/search'),
                    ),
                  );
                }
                return SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: Responsive.columns(context),
                    childAspectRatio: 0.72,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final service = services[index];
                      return ServiceCard(
                        service: service,
                        index: index,
                        onTap: () => context.push('/seller/${service.sellerId}'),
                      );
                    },
                    childCount: services.length,
                  ),
                );
              },
              loading: () => SliverToBoxAdapter(child: ShimmerGrid(count: 6)),
              error: (e, _) => SliverFillRemaining(
                child: ErrorState(
                  message: e.toString(),
                  onRetry: () => ref.invalidate(servicesProvider(filter)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
