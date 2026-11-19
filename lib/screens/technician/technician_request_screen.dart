import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/repair_request.dart';
import '../../providers/repair_providers.dart';
import '../../widgets/image_gallery.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/video_player_widget.dart';
import '../chat/chat_screen.dart';

class TechnicianRequestScreen extends ConsumerWidget {
  final String requestId;
  const TechnicianRequestScreen({super.key, required this.requestId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final request = ref.watch(requestProvider(requestId));

    return Scaffold(
      appBar: AppBar(title: const Text('Job Details')),
      body: request.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (r) {
          if (r == null) return const Center(child: Text('Request not found'));

          final locked = r.status == RepairStatus.cancelled ||
              r.status == RepairStatus.delivered;

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
              const SizedBox(height: 8),
              Text('Customer: ${r.customerName}'),
              if (r.status != RepairStatus.cancelled) ...[
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(
                        requestId: r.id,
                        title: 'Chat with ${r.customerName}',
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.chat),
                  label: const Text('Chat with customer'),
                ),
              ],
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
              if (locked)
                Text(
                  r.status == RepairStatus.cancelled
                      ? 'The customer cancelled this request.'
                      : 'This repair has been delivered.',
                )
              else
                DropdownButtonFormField<String>(
                  key: ValueKey(r.status),
                  initialValue:
                      RepairStatus.technicianOptions.contains(r.status)
                          ? r.status
                          : null,
                  decoration: const InputDecoration(
                    labelText: 'Update repair status',
                    border: OutlineInputBorder(),
                  ),
                  items: RepairStatus.technicianOptions
                      .map((s) => DropdownMenuItem(
                            value: s,
                            child: Text(RepairStatus.label(s)),
                          ))
                      .toList(),
                  onChanged: (s) {
                    if (s == null) return;
                    ref.read(repairRepositoryProvider).updateStatus(r.id, s);
                  },
                ),
            ],
          );
        },
      ),
    );
  }
}
