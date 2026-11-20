import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/admin_providers.dart';
import '../../providers/repair_providers.dart';

class AdminCategoriesTab extends ConsumerWidget {
  const AdminCategoriesTab({super.key});

  Future<String?> _askName(BuildContext context, {String initial = ''}) {
    final c = TextEditingController(text: initial);
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(initial.isEmpty ? 'New category' : 'Rename category'),
        content: TextField(
          controller: c,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Name'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, c.text.trim()),
              child: const Text('Save')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);
    final repo = ref.read(adminRepositoryProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Add category'),
        onPressed: () async {
          final name = await _askName(context);
          if (name != null && name.isNotEmpty) await repo.addCategory(name);
        },
      ),
      body: categories.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (list) => ListView.builder(
          padding: const EdgeInsets.only(bottom: 90),
          itemCount: list.length,
          itemBuilder: (context, i) {
            final c = list[i];
            return ListTile(
              leading: const Icon(Icons.devices),
              title: Text(c.name),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () async {
                      final name = await _askName(context, initial: c.name);
                      if (name != null && name.isNotEmpty) {
                        await repo.renameCategory(c.id, name);
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text('Delete "${c.name}"?'),
                          content: const Text(
                              'Existing requests keep their saved category name.'),
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
                      if (ok == true) await repo.deleteCategory(c.id);
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
