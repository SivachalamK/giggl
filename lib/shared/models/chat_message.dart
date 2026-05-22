import 'package:equatable/equatable.dart';

class ChatMessage extends Equatable {
  final String id;
  final String roomId;
  final String senderId;
  final String content;
  final String? imageUrl;
  final DateTime createdAt;
  final bool isRead;

  const ChatMessage({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.content,
    this.imageUrl,
    required this.createdAt,
    this.isRead = false,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      roomId: json['room_id'] as String,
      senderId: json['sender_id'] as String,
      content: json['content'] as String,
      imageUrl: json['image_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      isRead: json['is_read'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'room_id': roomId,
        'sender_id': senderId,
        'content': content,
        'image_url': imageUrl,
      };

  @override
  List<Object?> get props => [id, roomId, senderId, content, createdAt];
}

class ChatRoom extends Equatable {
  final String id;
  final String bookingId;
  final String customerId;
  final String sellerId;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final int unreadCount;

  const ChatRoom({
    required this.id,
    required this.bookingId,
    required this.customerId,
    required this.sellerId,
    this.lastMessage,
    this.lastMessageAt,
    this.unreadCount = 0,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      id: json['id'] as String,
      bookingId: json['booking_id'] as String,
      customerId: json['customer_id'] as String,
      sellerId: json['seller_id'] as String,
      lastMessage: json['last_message'] as String?,
      lastMessageAt: json['last_message_at'] != null
          ? DateTime.parse(json['last_message_at'] as String)
          : null,
      unreadCount: json['unread_count'] as int? ?? 0,
    );
  }

  @override
  List<Object?> get props => [id, bookingId];
}
