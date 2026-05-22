import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared/widgets/cards/service_card.dart';
import '../providers/services_provider.dart';

class SellerProfileScreen extends ConsumerWidget {
  const SellerProfileScreen({super.key, required this.sellerId});

  final String sellerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesAsync = ref.watch(
      sellerServicesProvider(sellerId),
    );

    return Scaffold(
      body: servicesAsync.when(
        data: (services) {
          final sellerName =
              services.isNotEmpty ? services.first.sellerName : 'Seller';
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(sellerName ?? 'Seller'),
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: AppColors.primaryGradient,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: Responsive.padding(context),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.verified, color: AppColors.success),
                          const SizedBox(width: 8),
                          const Text('Verified Seller'),
                          const Spacer(),
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: 18),
                              Text(
                                ' ${services.isNotEmpty && services.first.rating != null ? services.first.rating!.toStringAsFixed(1) : '4.8'}',
                                style: const TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Services',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: Responsive.padding(context),
                sliver: SliverGrid(
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
                        onTap: () => context.push('/booking/${service.id}'),
                      );
                    },
                    childCount: services.length,
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
      ),
    );
  }
}
