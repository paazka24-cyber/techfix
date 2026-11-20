import 'package:flutter_riverpod/flutter_riverpod.dart' hide Notifier;
import '../models/app_notification.dart';
import '../repositories/notification_repository.dart';
import '../services/messaging_service.dart';
import '../services/notifier.dart';
import 'auth_providers.dart';

final notificationRepositoryProvider =
    Provider<NotificationRepository>((ref) => NotificationRepository());

final messagingServiceProvider =
    Provider<MessagingService>((ref) => MessagingService());

final notifierProvider = Provider<Notifier>(
    (ref) => Notifier(ref.watch(notificationRepositoryProvider)));

final myNotificationsProvider = StreamProvider<List<AppNotification>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value([]);
  return ref.watch(notificationRepositoryProvider).watchMine(user.uid);
});

final unreadCountProvider = Provider<int>((ref) {
  final list = ref.watch(myNotificationsProvider).value ?? [];
  return list.where((n) => !n.isRead).length;
});
