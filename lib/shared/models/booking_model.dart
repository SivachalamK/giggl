import 'package:equatable/equatable.dart';

import '../../core/constants/app_constants.dart';

class BookingModel extends Equatable {
  final String id;
  final String customerId;
  final String sellerId;
  final String serviceId;
  final String? serviceTitle;
  final String? sellerName;
  final DateTime eventDate;
  final String? eventLocation;
  final String? notes;
  final double totalAmount;
  final double advanceAmount;
  final double paidAmount;
  final BookingStatus status;
  final PaymentStatus paymentStatus;
  final String? chatRoomId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const BookingModel({
    required this.id,
    required this.customerId,
    required this.sellerId,
    required this.serviceId,
    this.serviceTitle,
    this.sellerName,
    required this.eventDate,
    this.eventLocation,
    this.notes,
    required this.totalAmount,
    required this.advanceAmount,
    this.paidAmount = 0,
    this.status = BookingStatus.pending,
    this.paymentStatus = PaymentStatus.pending,
    this.chatRoomId,
    required this.createdAt,
    this.updatedAt,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] as String,
      customerId: json['customer_id'] as String,
      sellerId: json['seller_id'] as String,
      serviceId: json['service_id'] as String,
      serviceTitle: json['service_title'] as String?,
      sellerName: json['seller_name'] as String?,
      eventDate: DateTime.parse(json['event_date'] as String),
      eventLocation: json['event_location'] as String?,
      notes: json['notes'] as String?,
      totalAmount: (json['total_amount'] as num).toDouble(),
      advanceAmount: (json['advance_amount'] as num).toDouble(),
      paidAmount: (json['paid_amount'] as num?)?.toDouble() ?? 0,
      status: BookingStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => BookingStatus.pending,
      ),
      paymentStatus: PaymentStatus.values.firstWhere(
        (e) => e.name == json['payment_status'],
        orElse: () => PaymentStatus.pending,
      ),
      chatRoomId: json['chat_room_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'customer_id': customerId,
        'seller_id': sellerId,
        'service_id': serviceId,
        'event_date': eventDate.toIso8601String(),
        'event_location': eventLocation,
        'notes': notes,
        'total_amount': totalAmount,
        'advance_amount': advanceAmount,
        'paid_amount': paidAmount,
        'status': status.name,
        'payment_status': paymentStatus.name,
      };

  double get remainingAmount => totalAmount - paidAmount;

  @override
  List<Object?> get props => [id, status, paymentStatus, eventDate];
}
