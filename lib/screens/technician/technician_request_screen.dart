import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/repair_request.dart';
import '../../providers/auth_providers.dart';
import '../../providers/notification_providers.dart';
import '../../providers/repair_providers.dart';
import '../../widgets/image_gallery.dart';
import '../../widgets/section_card.dart';
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
                      const SizedBox(height: 6),
                      Text('Customer: ${r.customerName}'),
                      if (r.status != RepairStatus.cancelled) ...[
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
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
                title: 'Repair status',
                child: locked
                    ? Text(r.status == RepairStatus.cancelled
                        ? 'The customer cancelled this request.'
                        : 'This repair has been delivered.')
                    : DropdownButtonFormField<String>(
                        key: ValueKey(r.status),
                        initialValue:
                            RepairStatus.technicianOptions.contains(r.status)
                                ? r.status
                                : null,
                        decoration: const InputDecoration(
                          labelText: 'Update repair status',
                        ),
                        items: RepairStatus.technicianOptions
                            .map((s) => DropdownMenuItem(
                                  value: s,
                                  child: Text(RepairStatus.label(s)),
                                ))
                            .toList(),
                        onChanged: (s) async {
                          if (s == null) return;
                          final me = ref.read(authStateProvider).value;
                          await ref
                              .read(repairRepositoryProvider)
                              .updateStatus(r.id, s);
                          if (me == null) return;
                          try {
                            await ref.read(notifierProvider).statusChanged(
                                  customerId: r.customerId,
                                  technicianId: me.uid,
                                  requestId: r.id,
                                  device: '${r.categoryName} ${r.deviceModel}',
                                  statusLabel: RepairStatus.label(s),
                                  completed: s == RepairStatus.completed,
                                );
                          } catch (_) {}
                        },
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
