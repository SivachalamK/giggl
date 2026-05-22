import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../shared/models/chat_message.dart';

abstract class ChatRepository {
  Future<List<ChatRoom>> getRooms(String userId);
  Future<List<ChatMessage>> getMessages(String roomId, {int limit = 50});
  Future<ChatMessage> sendMessage({
    required String roomId,
    required String senderId,
    required String content,
    String? imageUrl,
  });
  Stream<List<ChatMessage>> subscribeToMessages(String roomId);
  Future<void> markAsRead(String roomId, String userId);
  Future<void> setTyping(String roomId, String userId, bool isTyping);
  Stream<Map<String, dynamic>> subscribeToPresence(String roomId);
}

class ChatRepositoryImpl implements ChatRepository {
  ChatRepositoryImpl(this._client);

  final SupabaseClient _client;

  @override
  Future<List<ChatRoom>> getRooms(String userId) async {
    final data = await _client
        .from('chats')
        .select()
        .or('customer_id.eq.$userId,seller_id.eq.$userId')
        .order('last_message_at', ascending: false);
    return (data as List).map((e) => ChatRoom.fromJson(e)).toList();
  }

  @override
  Future<List<ChatMessage>> getMessages(String roomId, {int limit = 50}) async {
    final data = await _client
        .from('chat_messages')
        .select()
        .eq('room_id', roomId)
        .order('created_at', ascending: true)
        .limit(limit);
    return (data as List).map((e) => ChatMessage.fromJson(e)).toList();
  }

  @override
  Future<ChatMessage> sendMessage({
    required String roomId,
    required String senderId,
    required String content,
    String? imageUrl,
  }) async {
    final result = await _client.from('chat_messages').insert({
      'room_id': roomId,
      'sender_id': senderId,
      'content': content,
      'image_url': imageUrl,
    }).select().single();

    await _client.from('chats').update({
      'last_message': content,
      'last_message_at': DateTime.now().toIso8601String(),
    }).eq('id', roomId);

    return ChatMessage.fromJson(result);
  }

  @override
  Stream<List<ChatMessage>> subscribeToMessages(String roomId) {
    return _client
        .from('chat_messages')
        .stream(primaryKey: ['id'])
        .eq('room_id', roomId)
        .order('created_at')
        .map((data) => data.map((e) => ChatMessage.fromJson(e)).toList());
  }

  @override
  Future<void> markAsRead(String roomId, String userId) async {
    await _client
        .from('chat_messages')
        .update({'is_read': true})
        .eq('room_id', roomId)
        .neq('sender_id', userId);
  }

  @override
  Future<void> setTyping(String roomId, String userId, bool isTyping) async {
    await _client.from('chat_typing').upsert({
      'room_id': roomId,
      'user_id': userId,
      'is_typing': isTyping,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  @override
  Stream<Map<String, dynamic>> subscribeToPresence(String roomId) {
    return _client
        .from('chat_typing')
        .stream(primaryKey: ['room_id', 'user_id'])
        .eq('room_id', roomId)
        .map((data) {
      if (data.isEmpty) return {};
      return data.first;
    });
  }
}

final chatRepositoryProvider = Provider<ChatRepository>(
  (ref) => ChatRepositoryImpl(ref.watch(supabaseClientProvider)),
);
