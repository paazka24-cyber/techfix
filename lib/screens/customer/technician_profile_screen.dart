import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/app_user.dart';
import '../../providers/review_providers.dart';
import '../../widgets/rating_badge.dart';
import '../../widgets/review_tile.dart';
import '../../widgets/section_card.dart';

class TechnicianProfileScreen extends ConsumerWidget {
  final AppUser technician;
  const TechnicianProfileScreen({super.key, required this.technician});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = technician;
    final scheme = Theme.of(context).colorScheme;
    final reviews = ref.watch(technicianReviewsProvider(t.uid));

    return Scaffold(
      appBar: AppBar(title: const Text('Technician Profile')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: scheme.primaryContainer,
                    child: Text(
                      t.fullName.isEmpty ? '?' : t.fullName[0].toUpperCase(),
                      style: TextStyle(
                          fontSize: 34, color: scheme.onPrimaryContainer),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(t.fullName,
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 4),
                  Text(
                    (t.specialization == null || t.specialization!.isEmpty)
                        ? 'General repairs'
                        : t.specialization!,
                    style: TextStyle(color: scheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 10),
                  RatingBadge(technicianId: t.uid),
                ],
              ),
            ),
          ),
          SectionCard(
            title: 'About',
            child: Text((t.bio == null || t.bio!.isEmpty)
                ? 'This technician has not added a bio yet.'
                : t.bio!),
          ),
          SectionCard(
            title: 'Reviews',
            child: reviews.when(
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('Error: $e'),
              data: (list) => list.isEmpty
                  ? const Text('No reviews yet.')
                  : Column(
                      children: list.map((r) => ReviewTile(review: r)).toList(),
                    ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
