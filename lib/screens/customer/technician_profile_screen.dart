import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/app_user.dart';
import '../../providers/review_providers.dart';
import '../../widgets/rating_badge.dart';
import '../../widgets/review_tile.dart';

class TechnicianProfileScreen extends ConsumerWidget {
  final AppUser technician;
  const TechnicianProfileScreen({super.key, required this.technician});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = technician;
    final reviews = ref.watch(technicianReviewsProvider(t.uid));

    return Scaffold(
      appBar: AppBar(title: const Text('Technician Profile')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: CircleAvatar(
              radius: 44,
              child: Text(
                t.fullName.isEmpty ? '?' : t.fullName[0].toUpperCase(),
                style: const TextStyle(fontSize: 32),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(t.fullName,
                style: Theme.of(context).textTheme.headlineSmall),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              (t.specialization == null || t.specialization!.isEmpty)
                  ? 'General repairs'
                  : t.specialization!,
            ),
          ),
          const SizedBox(height: 12),
          Center(child: RatingBadge(technicianId: t.uid)),
          const Divider(height: 40),
          Text('About', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text((t.bio == null || t.bio!.isEmpty)
              ? 'This technician has not added a bio yet.'
              : t.bio!),
          const Divider(height: 40),
          Text('Reviews', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          reviews.when(
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Text('Error: $e'),
            data: (list) => list.isEmpty
                ? const Text('No reviews yet.')
                : Column(
                    children: list.map((r) => ReviewTile(review: r)).toList()),
          ),
        ],
      ),
    );
  }
}
