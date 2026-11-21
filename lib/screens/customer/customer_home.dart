import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_providers.dart';
import '../../providers/repair_providers.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/notification_bell.dart';
import '../../widgets/request_card.dart';
import '../../widgets/theme_toggle_button.dart';
import 'create_request_screen.dart';
import 'customer_profile_tab.dart';
import 'request_detail_screen.dart';
import 'technicians_screen.dart';

class CustomerHome extends ConsumerStatefulWidget {
  const CustomerHome({super.key});

  @override
  ConsumerState<CustomerHome> createState() => _CustomerHomeState();
}

class _CustomerHomeState extends ConsumerState<CustomerHome> {
  int _index = 0;

  static const _titles = ['My Repairs', 'Technicians', 'My Profile'];

  void _newRequest() => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CreateRequestScreen()),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(_titles[_index]),
        actions: [
          const ThemeToggleButton(),
          const NotificationBell(),
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authRepositoryProvider).logout(),
          ),
        ],
      ),
      floatingActionButton: _index == 0
          ? FloatingActionButton.extended(
              onPressed: _newRequest,
              icon: const Icon(Icons.add),
              label: const Text('New request'),
            )
          : null,
      body: IndexedStack(
        index: _index,
        children: [
          _RepairsList(onNew: _newRequest),
          const TechniciansScreen(),
          const CustomerProfileTab(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.build_outlined),
            selectedIcon: Icon(Icons.build),
            label: 'Repairs',
          ),
          NavigationDestination(
            icon: Icon(Icons.engineering_outlined),
            selectedIcon: Icon(Icons.engineering),
            label: 'Technicians',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _RepairsList extends ConsumerWidget {
  final VoidCallback onNew;
  const _RepairsList({required this.onNew});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requests = ref.watch(myRequestsProvider);

    return requests.when(
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
            onAction: onNew,
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
    );
  }
}
