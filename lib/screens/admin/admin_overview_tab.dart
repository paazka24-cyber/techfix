import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/admin_providers.dart';
import '../../widgets/status_chip.dart';
import 'admin_requests_tab.dart';

class AdminOverviewTab extends ConsumerWidget {
  final void Function(String roleFilter) onOpenUsers;
  final void Function(String requestFilter) onOpenRequests;
  const AdminOverviewTab({
    super.key,
    required this.onOpenUsers,
    required this.onOpenRequests,
  });

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
    final active = r.where((x) => matchesRequestFilter(x, 'active')).length;
    final done = r.where((x) => matchesRequestFilter(x, 'done')).length;

    Widget stat(String label, int value, IconData icon, VoidCallback onTap) =>
        Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
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
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          children: [
            stat('Customers', customers, Icons.people,
                () => onOpenUsers('customer')),
            stat('Technicians', techs, Icons.engineering,
                () => onOpenUsers('technician')),
            stat('Active repairs', active, Icons.build,
                () => onOpenRequests('active')),
            stat('Completed', done, Icons.check_circle,
                () => onOpenRequests('done')),
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
                onTap: () => onOpenRequests('all'),
              ),
            )),
      ],
    );
  }
}
