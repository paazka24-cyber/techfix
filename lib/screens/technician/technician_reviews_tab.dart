import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/review_providers.dart';
import '../../widgets/empty_state.dart';
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
          return const EmptyState(
            icon: Icons.star_border,
            title: 'No reviews yet',
            message: 'Ratings from your customers will show up here.',
          );
        }
        final avg = list.fold<int>(0, (s, r) => s + r.rating) / list.length;
        return ListView(
          padding: const EdgeInsets.all(12),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(avg.toStringAsFixed(1),
                        style: Theme.of(context)
                            .textTheme
                            .displaySmall
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: List.generate(
                            5,
                            (i) => Icon(
                              i < avg.round() ? Icons.star : Icons.star_border,
                              color: Colors.amber,
                            ),
                          ),
                        ),
                        Text('${list.length} reviews'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            ...list.map((r) => ReviewTile(review: r)),
          ],
        );
      },
    );
  }
}
