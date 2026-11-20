import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/repair_request.dart';
import '../../providers/admin_providers.dart';
import '../../widgets/status_chip.dart';

class AdminRequestsTab extends ConsumerStatefulWidget {
  const AdminRequestsTab({super.key});

  @override
  ConsumerState<AdminRequestsTab> createState() => _AdminRequestsTabState();
}

class _AdminRequestsTabState extends ConsumerState<AdminRequestsTab> {
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    final requests = ref.watch(allRequestsProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: DropdownButtonFormField<String>(
            initialValue: _filter,
            decoration: const InputDecoration(
              labelText: 'Filter by status',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            items: [
              const DropdownMenuItem(value: 'all', child: Text('All')),
              ...[...RepairStatus.flow, RepairStatus.cancelled].map(
                (s) => DropdownMenuItem(
                    value: s, child: Text(RepairStatus.label(s))),
              ),
            ],
            onChanged: (v) => setState(() => _filter = v ?? 'all'),
          ),
        ),
        Expanded(
          child: requests.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (all) {
              final list = _filter == 'all'
                  ? all
                  : all.where((r) => r.status == _filter).toList();
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
      ],
    );
  }
}
