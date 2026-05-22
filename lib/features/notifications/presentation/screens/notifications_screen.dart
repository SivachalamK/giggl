import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../../services/notification_service.dart';
import '../../../../shared/models/notification_model.dart';
import '../../../../shared/widgets/states/empty_state.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: notificationsAsync.when(
        data: (data) {
          if (data.isEmpty) {
            return const EmptyState(
              title: 'No notifications',
              subtitle: 'You\'re all caught up!',
              icon: Icons.notifications_none,
            );
          }
          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (_, i) {
              final n = AppNotification.fromJson(
                Map<String, dynamic>.from(data[i]),
              );
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: n.isRead
                      ? Colors.grey.shade300
                      : Theme.of(context).colorScheme.primary,
                  child: Icon(
                    Icons.notifications,
                    color: n.isRead ? Colors.grey : Colors.white,
                    size: 20,
                  ),
                ),
                title: Text(
                  n.title,
                  style: TextStyle(
                    fontWeight:
                        n.isRead ? FontWeight.normal : FontWeight.w700,
                  ),
                ),
                subtitle: Text(n.body),
                trailing: Text(
                  timeago.format(n.createdAt),
                  style: const TextStyle(fontSize: 11),
                ),
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
