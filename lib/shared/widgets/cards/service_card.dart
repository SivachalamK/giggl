import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../models/service_model.dart';

class ServiceCard extends StatelessWidget {
  const ServiceCard({
    super.key,
    required this.service,
    this.onTap,
    this.onWishlist,
    this.isWishlisted = false,
    this.index = 0,
  });

  final ServiceModel service;
  final VoidCallback? onTap;
  final VoidCallback? onWishlist;
  final bool isWishlisted;
  final int index;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: AspectRatio(
                    aspectRatio: 16 / 10,
                    child: service.imageUrl != null
                        ? CachedNetworkImage(
                            imageUrl: service.imageUrl!,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(
                              color: colors.inputFill,
                            ),
                            errorWidget: (_, __, ___) => _placeholder(colors),
                          )
                        : _placeholder(colors),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    onPressed: onWishlist,
                    icon: Icon(
                      isWishlisted ? Icons.favorite : Icons.favorite_border,
                      color: isWishlisted ? Colors.red : Colors.white,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black26,
                    ),
                  ),
                ),
                if (service.rating != null)
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            service.rating!.toStringAsFixed(1),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    service.sellerName ?? 'Verified Seller',
                    style: TextStyle(
                      color: colors.onSurface.withValues(alpha: 0.6),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '${AppConstants.currencySymbol}${service.price.toStringAsFixed(0)}',
                        style: TextStyle(
                          color: colors.primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                      if (service.distanceKm != null)
                        Text(
                          '${service.distanceKm!.toStringAsFixed(1)} km',
                          style: TextStyle(
                            color: colors.onSurface.withValues(alpha: 0.5),
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ).animate(delay: (index * 80).ms).fadeIn().slideY(begin: 0.1, end: 0),
    );
  }

  Widget _placeholder(AppColorScheme colors) {
    return Container(
      color: colors.inputFill,
      child: Center(
        child: Text(
          AppConstants.categoryIcons[service.category] ?? '🎉',
          style: const TextStyle(fontSize: 48),
        ),
      ),
    );
  }
}
