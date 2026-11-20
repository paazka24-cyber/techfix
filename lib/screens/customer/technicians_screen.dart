import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/repair_providers.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/rating_badge.dart';
import 'technician_profile_screen.dart';

class TechniciansScreen extends ConsumerWidget {
  const TechniciansScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final technicians = ref.watch(techniciansProvider);

    return technicians.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (list) {
        if (list.isEmpty) {
          return const EmptyState(
            icon: Icons.engineering,
            title: 'No technicians yet',
            message: 'Technicians will appear here once they join.',
          );
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
                trailing: RatingBadge(technicianId: t.uid),
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
    );
  }
}
