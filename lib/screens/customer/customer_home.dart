import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_providers.dart';
import '../../providers/repair_providers.dart';
import '../../widgets/status_chip.dart';
import 'create_request_screen.dart';
import 'request_detail_screen.dart';
import 'technicians_screen.dart';

class CustomerHome extends ConsumerWidget {
  const CustomerHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requests = ref.watch(myRequestsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Repairs'),
        actions: [
          IconButton(
            tooltip: 'Technicians',
            icon: const Icon(Icons.engineering),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TechniciansScreen()),
            ),
          ),
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authRepositoryProvider).logout(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CreateRequestScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('New request'),
      ),
      body: requests.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (list) {
          if (list.isEmpty) {
            return const Center(
              child: Text(
                  'No repair requests yet.\nTap "New request" to start.',
                  textAlign: TextAlign.center),
            );
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
                    r.problemDescription,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: StatusChip(r.status),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RequestDetailScreen(requestId: r.id),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
