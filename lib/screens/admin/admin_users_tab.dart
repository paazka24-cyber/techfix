import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/app_user.dart';
import '../../providers/admin_providers.dart';
import '../../providers/auth_providers.dart';
import 'admin_user_dialog.dart';

class AdminUsersTab extends ConsumerWidget {
  final ValueNotifier<String> filter;
  const AdminUsersTab({super.key, required this.filter});

  Future<void> _delete(BuildContext context, WidgetRef ref, AppUser u) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete ${u.fullName}?'),
        content: const Text(
            'The profile is removed and the user loses access to the app. '
            'To remove the login completely, also delete it in Firebase '
            'Console > Authentication.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(adminRepositoryProvider).deleteUserProfile(u.uid);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Could not delete: $e')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final users = ref.watch(allUsersProvider);
    final myUid = ref.watch(authStateProvider).value?.uid;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.person_add),
        label: const Text('Add technician'),
        onPressed: () => showDialog(
          context: context,
          builder: (_) => const UserFormDialog(),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: ValueListenableBuilder<String>(
              valueListenable: filter,
              builder: (context, value, _) => SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'all', label: Text('All')),
                  ButtonSegment(value: 'customer', label: Text('Customers')),
                  ButtonSegment(
                      value: 'technician', label: Text('Technicians')),
                ],
                selected: {value},
                onSelectionChanged: (s) => filter.value = s.first,
              ),
            ),
          ),
          Expanded(
            child: users.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (all) => ValueListenableBuilder<String>(
                valueListenable: filter,
                builder: (context, value, _) {
                  final list = value == 'all'
                      ? all
                      : all.where((u) => u.role == value).toList();
                  if (list.isEmpty) {
                    return const Center(child: Text('No users.'));
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 90),
                    itemCount: list.length,
                    itemBuilder: (context, i) {
                      final u = list[i];
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text(u.fullName.isEmpty
                              ? '?'
                              : u.fullName[0].toUpperCase()),
                        ),
                        title: Text(u.fullName),
                        subtitle: Text(
                            '${u.role.toUpperCase()}\n${u.email}\n${u.phoneNumber}'),
                        isThreeLine: true,
                        trailing: u.role == 'admin'
                            ? Chip(
                                label: Text(u.uid == myUid ? 'You' : 'Admin'))
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    tooltip: 'Edit',
                                    icon: const Icon(Icons.edit),
                                    onPressed: () => showDialog(
                                      context: context,
                                      builder: (_) => UserFormDialog(user: u),
                                    ),
                                  ),
                                  IconButton(
                                    tooltip: 'Delete',
                                    icon: const Icon(Icons.delete),
                                    onPressed: () => _delete(context, ref, u),
                                  ),
                                ],
                              ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
