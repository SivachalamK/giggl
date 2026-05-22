import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/responsive.dart';
import '../../../../shared/widgets/cards/service_card.dart';
import '../../../../shared/widgets/states/empty_state.dart';
import '../../data/repositories/wishlist_repository_impl.dart';

class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wishlistAsync = ref.watch(wishlistProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Wishlist')),
      body: wishlistAsync.when(
        data: (services) {
          if (services.isEmpty) {
            return const EmptyState(
              title: 'Your wishlist is empty',
              subtitle: 'Save services you love',
              icon: Icons.favorite_border,
            );
          }
          return GridView.builder(
            padding: Responsive.padding(context),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: Responsive.columns(context),
              childAspectRatio: 0.72,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: services.length,
            itemBuilder: (_, i) => ServiceCard(
              service: services[i],
              isWishlisted: true,
              index: i,
              onTap: () => context.push('/seller/${services[i].sellerId}'),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
      ),
    );
  }
}
