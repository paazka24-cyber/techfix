import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_providers.dart';
import '../../providers/repair_providers.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/notification_bell.dart';
import '../../widgets/request_card.dart';
import '../../widgets/theme_toggle_button.dart';
import 'create_request_screen.dart';
import 'request_detail_screen.dart';
import 'technicians_screen.dart';

class CustomerHome extends ConsumerWidget {
  const CustomerHome({super.key});

  void _newRequest(BuildContext context) => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CreateRequestScreen()),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requests = ref.watch(myRequestsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Repairs'),
        actions: [
          const ThemeToggleButton(),
          const NotificationBell(),
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
        onPressed: () => _newRequest(context),
        icon: const Icon(Icons.add),
        label: const Text('New request'),
      ),
      body: requests.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (list) {
          if (list.isEmpty) {
            return EmptyState(
              icon: Icons.build_circle_outlined,
              title: 'No repairs yet',
              message:
                  'Create your first request and a technician will pick it up.',
              actionLabel: 'New request',
              onAction: () => _newRequest(context),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 90),
            itemCount: list.length,
            itemBuilder: (context, i) {
              final r = list[i];
              return RequestCard(
                request: r,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RequestDetailScreen(requestId: r.id),
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
