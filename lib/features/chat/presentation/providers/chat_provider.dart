import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/models/chat_message.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/repositories/chat_repository_impl.dart';

final chatRoomsProvider = FutureProvider<List<ChatRoom>>((ref) async {
  final userId = ref.watch(currentUserProvider)?.id;
  if (userId == null) return [];
  return ref.watch(chatRepositoryProvider).getRooms(userId);
});

final chatMessagesProvider = StreamProvider.family<List<ChatMessage>, String>(
  (ref, roomId) {
    return ref.watch(chatRepositoryProvider).subscribeToMessages(roomId);
  },
);

final typingProvider = StreamProvider.family<Map<String, dynamic>, String>(
  (ref, roomId) {
    return ref.watch(chatRepositoryProvider).subscribeToPresence(roomId);
  },
);

class ChatNotifier extends StateNotifier<AsyncValue<void>> {
  ChatNotifier(this._repo) : super(const AsyncValue.data(null));

  final ChatRepository _repo;

  Future<void> send(String roomId, String senderId, String content) async {
    state = const AsyncValue.loading();
    try {
      await _repo.sendMessage(
        roomId: roomId,
        senderId: senderId,
        content: content,
      );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> setTyping(String roomId, String userId, bool typing) async {
    await _repo.setTyping(roomId, userId, typing);
  }
}

final chatNotifierProvider =
    StateNotifierProvider<ChatNotifier, AsyncValue<void>>(
  (ref) => ChatNotifier(ref.watch(chatRepositoryProvider)),
);
