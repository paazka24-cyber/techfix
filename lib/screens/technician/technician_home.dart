import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_providers.dart';
import '../../providers/notification_providers.dart';
import '../../providers/repair_providers.dart';
import '../../widgets/image_gallery.dart';
import '../../widgets/notification_bell.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/theme_toggle_button.dart';
import 'technician_profile_tab.dart';
import 'technician_request_screen.dart';
import 'technician_reviews_tab.dart';

class TechnicianHome extends ConsumerWidget {
  const TechnicianHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Technician'),
          actions: [
            const ThemeToggleButton(),
            const NotificationBell(),
            IconButton(
              tooltip: 'Logout',
              icon: const Icon(Icons.logout),
              onPressed: () => ref.read(authRepositoryProvider).logout(),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Available'),
              Tab(text: 'My Jobs'),
              Tab(text: 'Reviews'),
              Tab(text: 'Profile'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _AvailableTab(),
            _JobsTab(),
            TechnicianReviewsTab(),
            TechnicianProfileTab(),
          ],
        ),
      ),
    );
  }
}

class _AvailableTab extends ConsumerWidget {
  const _AvailableTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requests = ref.watch(availableRequestsProvider);
    final me = ref.watch(authStateProvider).value;

    return requests.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (list) {
        if (list.isEmpty) {
          return const Center(child: Text('No open requests right now.'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: list.length,
          itemBuilder: (context, i) {
            final r = list[i];
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${r.categoryName} - ${r.deviceModel}',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text('From ${r.customerName}'),
                    const SizedBox(height: 8),
                    Text(r.problemDescription),
                    const SizedBox(height: 8),
                    ImageGallery(urls: r.imageUrls),
                    if (r.videoUrl != null) ...[
                      const SizedBox(height: 8),
                      const Row(
                        children: [
                          Icon(Icons.videocam, size: 18),
                          SizedBox(width: 6),
                          Text('Includes a video (open after accepting)'),
                        ],
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: me == null
                              ? null
                              : () => ref
                                  .read(repairRepositoryProvider)
                                  .reject(r.id, me.uid),
                          child: const Text('Reject'),
                        ),
                        const SizedBox(width: 8),
                        FilledButton(
                          onPressed: me == null
                              ? null
                              : () async {
                                  try {
                                    await ref
                                        .read(repairRepositoryProvider)
                                        .accept(r.id, me.uid);
                                  } catch (_) {
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Could not accept. Someone else may have taken it.'),
                                      ),
                                    );
                                    return;
                                  }
                                  try {
                                    await ref
                                        .read(notifierProvider)
                                        .requestAccepted(
                                          customerId: r.customerId,
                                          technicianId: me.uid,
                                          requestId: r.id,
                                          device:
                                              '${r.categoryName} ${r.deviceModel}',
                                        );
                                  } catch (_) {
                                    // accepted already; ignore notification errors
                                  }
                                },
                          child: const Text('Accept'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _JobsTab extends ConsumerWidget {
  const _JobsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobs = ref.watch(technicianJobsProvider);

    return jobs.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (list) {
        if (list.isEmpty) {
          return const Center(child: Text('You have no jobs yet.'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: list.length,
          itemBuilder: (context, i) {
            final r = list[i];
            return Card(
              child: ListTile(
                title: Text('${r.categoryName} - ${r.deviceModel}'),
                subtitle: Text(
                  '${r.customerName}\n${r.problemDescription}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                isThreeLine: true,
                trailing: StatusChip(r.status),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TechnicianRequestScreen(requestId: r.id),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
