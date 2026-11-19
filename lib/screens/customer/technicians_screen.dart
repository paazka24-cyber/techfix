import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/repair_providers.dart';
import 'technician_profile_screen.dart';

class TechniciansScreen extends ConsumerWidget {
  const TechniciansScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final technicians = ref.watch(techniciansProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Our Technicians')),
      body: technicians.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (list) {
          if (list.isEmpty) {
            return const Center(child: Text('No technicians yet.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: list.length,
            itemBuilder: (context, i) {
              final t = list[i];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(
                      t.fullName.isEmpty ? '?' : t.fullName[0].toUpperCase(),
                    ),
                  ),
                  title: Text(t.fullName),
                  subtitle: Text(
                    (t.specialization == null || t.specialization!.isEmpty)
                        ? 'General repairs'
                        : t.specialization!,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 18),
                      Text(t.reviewCount == 0
                          ? ' New'
                          : ' ${t.averageRating.toStringAsFixed(1)}'),
                    ],
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TechnicianProfileScreen(technician: t),
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
