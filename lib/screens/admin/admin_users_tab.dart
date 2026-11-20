import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/admin_providers.dart';
import '../../providers/auth_providers.dart';

class AdminUsersTab extends ConsumerStatefulWidget {
  const AdminUsersTab({super.key});

  @override
  ConsumerState<AdminUsersTab> createState() => _AdminUsersTabState();
}

class _AdminUsersTabState extends ConsumerState<AdminUsersTab> {
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    final users = ref.watch(allUsersProvider);
    final myUid = ref.watch(authStateProvider).value?.uid;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'all', label: Text('All')),
              ButtonSegment(value: 'customer', label: Text('Customers')),
              ButtonSegment(value: 'technician', label: Text('Technicians')),
            ],
            selected: {_filter},
            onSelectionChanged: (s) => setState(() => _filter = s.first),
          ),
        ),
        Expanded(
          child: users.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (all) {
              final list = _filter == 'all'
                  ? all
                  : all.where((u) => u.role == _filter).toList();
              if (list.isEmpty) {
                return const Center(child: Text('No users.'));
              }
              return ListView.builder(
                itemCount: list.length,
                itemBuilder: (context, i) {
                  final u = list[i];
                  final isMe = u.uid == myUid;
                  return ListTile(
                    leading: CircleAvatar(
                      child: Text(u.fullName.isEmpty
                          ? '?'
                          : u.fullName[0].toUpperCase()),
                    ),
                    title: Text(u.fullName),
                    subtitle: Text('${u.email}\n${u.phoneNumber}'),
                    isThreeLine: true,
                    trailing: isMe
                        ? const Chip(label: Text('You (admin)'))
                        : DropdownButton<String>(
                            value: ['customer', 'technician', 'admin']
                                    .contains(u.role)
                                ? u.role
                                : 'customer',
                            underline: const SizedBox(),
                            items: const [
                              DropdownMenuItem(
                                  value: 'customer', child: Text('Customer')),
                              DropdownMenuItem(
                                  value: 'technician',
                                  child: Text('Technician')),
                              DropdownMenuItem(
                                  value: 'admin', child: Text('Admin')),
                            ],
                            onChanged: (role) async {
                              if (role == null || role == u.role) return;
                              try {
                                await ref
                                    .read(adminRepositoryProvider)
                                    .setUserRole(u.uid, role);
                              } catch (e) {
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text('Could not change role: $e')),
                                );
                              }
                            },
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
