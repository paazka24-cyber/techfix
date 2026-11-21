import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/repair_request.dart';
import '../../providers/repair_providers.dart';
import '../../providers/review_providers.dart';
import '../../widgets/image_gallery.dart';
import '../../widgets/review_tile.dart';
import '../../widgets/section_card.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/video_player_widget.dart';
import '../chat/chat_screen.dart';
import 'rate_technician_dialog.dart';

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
              child: const Text('Keep')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Cancel request')),
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
          final canRate = r.technicianId != null &&
              (r.status == RepairStatus.completed ||
                  r.status == RepairStatus.delivered);

          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                      if (r.technicianId != null &&
                          r.status != RepairStatus.cancelled) ...[
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChatScreen(
                                  requestId: r.id,
                                  title: 'Chat with technician',
                                ),
                              ),
                            ),
                            icon: const Icon(Icons.chat),
                            label: const Text('Chat with technician'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              SectionCard(
                title: 'Problem',
                child: Text(r.problemDescription),
              ),
              if (r.imageUrls.isNotEmpty || r.videoUrl != null)
                SectionCard(
                  title: 'Media',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (r.imageUrls.isNotEmpty)
                        ImageGallery(urls: r.imageUrls),
                      if (r.videoUrl != null) ...[
                        const SizedBox(height: 12),
                        VideoPlayerWidget(url: r.videoUrl!),
                      ],
                    ],
                  ),
                ),
              SectionCard(
                title: 'Progress',
                child: r.status == RepairStatus.cancelled
                    ? const ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.cancel, color: Colors.red),
                        title: Text('This request was cancelled'),
                      )
                    : Column(
                        children: RepairStatus.flow.map((s) {
                          final done = RepairStatus.flow.indexOf(s) <=
                              RepairStatus.flow.indexOf(r.status);
                          return ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(
                              done
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                              color:
                                  done ? const Color(0xFF00C853) : Colors.grey,
                            ),
                            title: Text(RepairStatus.label(s)),
                          );
                        }).toList(),
                      ),
              ),
              if (canRate)
                SectionCard(
                  title: 'Your review',
                  child: ref.watch(requestReviewProvider(r.id)).when(
                        loading: () => const LinearProgressIndicator(),
                        error: (e, _) => Text('Error: $e'),
                        data: (review) => review != null
                            ? ReviewTile(review: review)
                            : FilledButton.icon(
                                onPressed: () => showDialog(
                                  context: context,
                                  builder: (_) =>
                                      RateTechnicianDialog(request: r),
                                ),
                                icon: const Icon(Icons.star),
                                label: const Text('Rate technician'),
                              ),
                      ),
                ),
              if (canCancel)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: OutlinedButton(
                    onPressed: () => _confirmCancel(context, ref),
                    child: const Text('Cancel request'),
                  ),
                ),
              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }
}
