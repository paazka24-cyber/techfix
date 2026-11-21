import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/app_notification.dart';
import '../../providers/notification_providers.dart';
import '../../widgets/empty_state.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  IconData _icon(String title) {
    final t = title.toLowerCase();
    if (t.contains('message')) return Icons.chat_bubble;
    if (t.contains('accepted')) return Icons.handshake;
    if (t.contains('completed')) return Icons.check_circle;
    if (t.contains('status')) return Icons.sync;
    if (t.contains('new repair')) return Icons.build;
    return Icons.notifications;
  }

  String _ago(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} h ago';
    if (diff.inDays < 7) return '${diff.inDays} d ago';
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = ref.watch(myNotificationsProvider);
    final repo = ref.read(notificationRepositoryProvider);
    final scheme = Theme.of(context).colorScheme;

    Widget tile(AppNotification n) {
      return Card(
        color:
            n.isRead ? null : scheme.primaryContainer.withValues(alpha: 0.35),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => repo.markRead(n.id),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(_icon(n.title),
                      color: scheme.onPrimaryContainer, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        n.title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight:
                                  n.isRead ? FontWeight.w500 : FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(n.body,
                          style: TextStyle(color: scheme.onSurfaceVariant)),
                      const SizedBox(height: 6),
                      Text(_ago(n.createdAt),
                          style: Theme.of(context).textTheme.labelSmall),
                    ],
                  ),
                ),
                if (!n.isRead)
                  Container(
                    margin: const EdgeInsets.only(top: 6, left: 8),
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Color(0xFF00C853),
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () => repo.markAllRead(notes.value ?? []),
            child: const Text('Mark all read'),
          ),
        ],
      ),
      body: notes.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (list) {
          if (list.isEmpty) {
            return const EmptyState(
              icon: Icons.notifications_none,
              title: 'All caught up',
              message: 'Updates about your repairs will appear here.',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: list.length,
            itemBuilder: (context, i) => tile(list[i]),
          );
        },
      ),
    );
  }
}
