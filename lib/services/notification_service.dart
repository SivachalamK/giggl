import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../features/auth/presentation/providers/auth_provider.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle background message
}

class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();

  final _messaging = FirebaseMessaging.instance;
  final _local = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    await _requestPermission();
    await _initLocalNotifications();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);
    final token = await _messaging.getToken();
    if (token != null) {
      await _saveFcmToken(token);
    }
    _messaging.onTokenRefresh.listen(_saveFcmToken);
  }

  Future<void> _requestPermission() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> _initLocalNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _local.initialize(
      const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: (_) {},
    );
  }

  void _onForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification != null) {
      _showLocal(
        notification.title ?? 'Giggl',
        notification.body ?? '',
      );
    }
  }

  Future<void> _showLocal(String title, String body) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'giggl_channel',
        'Giggl Notifications',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );
    await _local.show(
      DateTime.now().millisecond,
      title,
      body,
      details,
    );
  }

  Future<void> _saveFcmToken(String token) async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;
      await Supabase.instance.client.from('users').update({
        'fcm_token': token,
      }).eq('id', userId);
    } catch (_) {}
  }
}

abstract class NotificationRepository {
  Future<List<dynamic>> getNotifications(String userId);
  Future<void> markAsRead(String id);
}

class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl(this._client);

  final SupabaseClient _client;

  @override
  Future<List<dynamic>> getNotifications(String userId) async {
    return _client
        .from('notifications')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
  }

  @override
  Future<void> markAsRead(String id) async {
    await _client.from('notifications').update({'is_read': true}).eq('id', id);
  }
}

final notificationRepositoryProvider = Provider<NotificationRepository>(
  (ref) => NotificationRepositoryImpl(ref.watch(supabaseClientProvider)),
);

final notificationsProvider = FutureProvider((ref) async {
  final userId = ref.watch(currentUserProvider)?.id;
  if (userId == null) return <dynamic>[];
  return ref.watch(notificationRepositoryProvider).getNotifications(userId);
});
