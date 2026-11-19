import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/repair_request.dart';
import '../../providers/repair_providers.dart';
import '../../widgets/image_gallery.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/video_player_widget.dart';

class RequestDetailScreen extends ConsumerWidget {
  final String requestId;
  const RequestDetailScreen({super.key, required this.requestId});

  Future<void> _confirmCancel(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel request?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Cancel request'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(repairRepositoryProvider).cancel(requestId);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final request = ref.watch(requestProvider(requestId));

    return Scaffold(
      appBar: AppBar(title: const Text('Repair Details')),
      body: request.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (r) {
          if (r == null) return const Center(child: Text('Request not found'));

          final canCancel = r.status == RepairStatus.submitted ||
              r.status == RepairStatus.assigned;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${r.categoryName} - ${r.deviceModel}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  StatusChip(r.status),
                ],
              ),
              const SizedBox(height: 16),
              Text('Problem', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 4),
              Text(r.problemDescription),
              const SizedBox(height: 16),
              Text('Photos', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              ImageGallery(urls: r.imageUrls),
              if (r.videoUrl != null) ...[
                const SizedBox(height: 16),
                Text('Video', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 8),
                VideoPlayerWidget(url: r.videoUrl!),
              ],
              const SizedBox(height: 24),
              Text('Progress', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              if (r.status == RepairStatus.cancelled)
                const ListTile(
                  leading: Icon(Icons.cancel, color: Colors.red),
                  title: Text('This request was cancelled'),
                )
              else
                ...RepairStatus.flow.map((s) {
                  final done = RepairStatus.flow.indexOf(s) <=
                      RepairStatus.flow.indexOf(r.status);
                  return ListTile(
                    dense: true,
                    leading: Icon(
                      done ? Icons.check_circle : Icons.radio_button_unchecked,
                      color: done ? const Color(0xFF00C853) : Colors.grey,
                    ),
                    title: Text(RepairStatus.label(s)),
                  );
                }),
              const SizedBox(height: 24),
              if (canCancel)
                OutlinedButton(
                  onPressed: () => _confirmCancel(context, ref),
                  child: const Text('Cancel request'),
                ),
            ],
          );
        },
      ),
    );
  }
}
