import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/repair_request.dart';
import '../../providers/admin_providers.dart';
import '../../widgets/status_chip.dart';

bool matchesRequestFilter(RepairRequest r, String f) {
  switch (f) {
    case 'all':
      return true;
    case 'active':
      return r.status != RepairStatus.completed &&
          r.status != RepairStatus.delivered &&
          r.status != RepairStatus.cancelled;
    case 'done':
      return r.status == RepairStatus.completed ||
          r.status == RepairStatus.delivered;
    default:
      return r.status == f;
  }
}

class AdminRequestsTab extends ConsumerWidget {
  final ValueNotifier<String> filter;
  const AdminRequestsTab({super.key, required this.filter});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requests = ref.watch(allRequestsProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: ValueListenableBuilder<String>(
            valueListenable: filter,
            builder: (context, value, _) => DropdownButtonFormField<String>(
              key: ValueKey(value),
              initialValue: value,
              decoration: const InputDecoration(
                labelText: 'Filter',
                isDense: true,
              ),
              items: [
                const DropdownMenuItem(value: 'all', child: Text('All')),
                const DropdownMenuItem(
                    value: 'active', child: Text('Active repairs')),
                const DropdownMenuItem(
                    value: 'done', child: Text('Completed / Delivered')),
                ...[...RepairStatus.flow, RepairStatus.cancelled].map(
                  (s) => DropdownMenuItem(
                      value: s, child: Text(RepairStatus.label(s))),
                ),
              ],
              onChanged: (v) => filter.value = v ?? 'all',
            ),
          ),
        ),
        Expanded(
          child: requests.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (all) => ValueListenableBuilder<String>(
              valueListenable: filter,
              builder: (context, value, _) {
                final list =
                    all.where((r) => matchesRequestFilter(r, value)).toList();
                if (list.isEmpty) {
                  return const Center(child: Text('No requests.'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: list.length,
                  itemBuilder: (context, i) {
                    final r = list[i];
                    final d = r.createdAt;
                    return Card(
                      child: ListTile(
                        title: Text('${r.categoryName} - ${r.deviceModel}'),
                        subtitle: Text(
                          'Customer: ${r.customerName}\n'
                          'Technician: ${r.technicianId ?? "not assigned"}\n'
                          '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}',
                        ),
                        isThreeLine: true,
                        trailing: StatusChip(r.status),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
