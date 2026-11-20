import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/repair_request.dart';
import '../../providers/admin_providers.dart';
import '../../widgets/status_chip.dart';

class AdminOverviewTab extends ConsumerWidget {
  const AdminOverviewTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final users = ref.watch(allUsersProvider);
    final requests = ref.watch(allRequestsProvider);

    if (users.hasError || requests.hasError) {
      return Center(child: Text('Error: ${users.error ?? requests.error}'));
    }
    if (!users.hasValue || !requests.hasValue) {
      return const Center(child: CircularProgressIndicator());
    }

    final u = users.value!;
    final r = requests.value!;
    final customers = u.where((x) => x.role == 'customer').length;
    final techs = u.where((x) => x.role == 'technician').length;
    final active = r
        .where((x) =>
            x.status != RepairStatus.completed &&
            x.status != RepairStatus.delivered &&
            x.status != RepairStatus.cancelled)
        .length;
    final done = r
        .where((x) =>
            x.status == RepairStatus.completed ||
            x.status == RepairStatus.delivered)
        .length;

    Widget stat(String label, int value, IconData icon) => Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 28),
                const SizedBox(height: 8),
                Text('$value',
                    style: Theme.of(context).textTheme.headlineMedium),
                Text(label),
              ],
            ),
          ),
        );

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.5,
          children: [
            stat('Customers', customers, Icons.people),
            stat('Technicians', techs, Icons.engineering),
            stat('Active repairs', active, Icons.build),
            stat('Completed', done, Icons.check_circle),
          ],
        ),
        const SizedBox(height: 16),
        Text('Recent activity', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        ...r.take(8).map((x) => Card(
              child: ListTile(
                title: Text('${x.categoryName} - ${x.deviceModel}'),
                subtitle: Text('By ${x.customerName}'),
                trailing: StatusChip(x.status),
              ),
            )),
      ],
    );
  }
}
