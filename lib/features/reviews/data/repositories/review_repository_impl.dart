import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../auth/presentation/providers/auth_provider.dart';

class Review {
  final String id;
  final int rating;
  final String? comment;
  final String customerId;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.rating,
    this.comment,
    required this.customerId,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) => Review(
        id: json['id'] as String,
        rating: json['rating'] as int,
        comment: json['comment'] as String?,
        customerId: json['customer_id'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}

abstract class ReviewRepository {
  Future<List<Review>> getServiceReviews(String serviceId);
  Future<void> submitReview({
    required String bookingId,
    required String customerId,
    required String sellerId,
    required String serviceId,
    required int rating,
    String? comment,
  });
}

class ReviewRepositoryImpl implements ReviewRepository {
  ReviewRepositoryImpl(this._client);

  final SupabaseClient _client;

  @override
  Future<List<Review>> getServiceReviews(String serviceId) async {
    final data = await _client
        .from('reviews')
        .select()
        .eq('service_id', serviceId)
        .order('created_at', ascending: false);
    return (data as List).map((e) => Review.fromJson(e)).toList();
  }

  @override
  Future<void> submitReview({
    required String bookingId,
    required String customerId,
    required String sellerId,
    required String serviceId,
    required int rating,
    String? comment,
  }) async {
    await _client.from('reviews').insert({
      'booking_id': bookingId,
      'customer_id': customerId,
      'seller_id': sellerId,
      'service_id': serviceId,
      'rating': rating,
      'comment': comment,
    });
  }
}

final reviewRepositoryProvider = Provider<ReviewRepository>(
  (ref) => ReviewRepositoryImpl(ref.watch(supabaseClientProvider)),
);
