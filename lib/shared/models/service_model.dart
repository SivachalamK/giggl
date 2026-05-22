import 'package:equatable/equatable.dart';

class ServiceModel extends Equatable {
  final String id;
  final String sellerId;
  final String? sellerName;
  final String categoryId;
  final String category;
  final String title;
  final String description;
  final double price;
  final String? imageUrl;
  final List<String> portfolioUrls;
  final double? rating;
  final int reviewCount;
  final double? distanceKm;
  final bool isActive;
  final Map<String, dynamic>? metadata;

  const ServiceModel({
    required this.id,
    required this.sellerId,
    this.sellerName,
    required this.categoryId,
    required this.category,
    required this.title,
    required this.description,
    required this.price,
    this.imageUrl,
    this.portfolioUrls = const [],
    this.rating,
    this.reviewCount = 0,
    this.distanceKm,
    this.isActive = true,
    this.metadata,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] as String,
      sellerId: json['seller_id'] as String,
      sellerName: json['seller_name'] as String?,
      categoryId: json['category_id'] as String? ?? '',
      category: json['category'] as String? ??
          (json['categories'] as Map?)?['name'] as String? ??
          '',
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      price: (json['price'] as num).toDouble(),
      imageUrl: json['image_url'] as String?,
      portfolioUrls: (json['portfolio_urls'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      rating: (json['rating'] as num?)?.toDouble(),
      reviewCount: json['review_count'] as int? ?? 0,
      distanceKm: (json['distance_km'] as num?)?.toDouble(),
      isActive: json['is_active'] as bool? ?? true,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'seller_id': sellerId,
        'category_id': categoryId,
        'title': title,
        'description': description,
        'price': price,
        'image_url': imageUrl,
        'portfolio_urls': portfolioUrls,
        'is_active': isActive,
        'metadata': metadata,
      };

  @override
  List<Object?> get props => [id, sellerId, title, price, category];
}
