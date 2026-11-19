import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/review_providers.dart';

class RatingBadge extends ConsumerWidget {
  final String technicianId;
  const RatingBadge({super.key, required this.technicianId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviews = ref.watch(technicianReviewsProvider(technicianId));
    final text = reviews.when(
      loading: () => '...',
      error: (_, __) => '-',
      data: (list) {
        if (list.isEmpty) return 'New';
        final avg = list.fold<int>(0, (sum, r) => sum + r.rating) / list.length;
        return '${avg.toStringAsFixed(1)} (${list.length})';
      },
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.star, color: Colors.amber, size: 18),
        const SizedBox(width: 2),
        Text(text),
      ],
    );
  }
}
