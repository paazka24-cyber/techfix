import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/review_providers.dart';
import '../../widgets/review_tile.dart';

class TechnicianReviewsTab extends ConsumerWidget {
  const TechnicianReviewsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviews = ref.watch(myReviewsProvider);

    return reviews.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (list) {
        if (list.isEmpty) {
          return const Center(child: Text('No reviews yet.'));
        }
        final avg = list.fold<int>(0, (s, r) => s + r.rating) / list.length;
        return ListView(
          padding: const EdgeInsets.all(12),
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.star, color: Colors.amber, size: 32),
                title: Text('${avg.toStringAsFixed(1)} average'),
                subtitle: Text('${list.length} reviews'),
              ),
            ),
            ...list.map((r) => ReviewTile(review: r)),
          ],
        );
      },
    );
  }
}
