import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../../shared/widgets/states/empty_state.dart';
import '../providers/chat_provider.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomsAsync = ref.watch(chatRoomsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: roomsAsync.when(
        data: (rooms) {
          if (rooms.isEmpty) {
            return const EmptyState(
              title: 'No conversations yet',
              subtitle: 'Book a service to start chatting',
              icon: Icons.chat_bubble_outline,
            );
          }
          return ListView.builder(
            itemCount: rooms.length,
            itemBuilder: (_, i) {
              final room = rooms[i];
              return ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text('Booking #${room.bookingId.substring(0, 8)}'),
                subtitle: Text(room.lastMessage ?? 'Start a conversation'),
                trailing: room.lastMessageAt != null
                    ? Text(
                        timeago.format(room.lastMessageAt!),
                        style: const TextStyle(fontSize: 12),
                      )
                    : null,
                onTap: () => context.push('/chat/${room.id}'),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
      ),
    );
  }
}
