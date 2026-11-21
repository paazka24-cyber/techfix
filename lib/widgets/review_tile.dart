import 'package:flutter/material.dart';
import '../models/review.dart';

class ReviewTile extends StatelessWidget {
  final Review review;
  const ReviewTile({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final d = review.createdAt;
    final date =
        '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: scheme.primaryContainer,
                  child: Text(
                    review.customerName.isEmpty
                        ? '?'
                        : review.customerName[0].toUpperCase(),
                    style: TextStyle(color: scheme.onPrimaryContainer),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(review.customerName,
                          style: Theme.of(context).textTheme.titleSmall),
                      Text(date, style: Theme.of(context).textTheme.labelSmall),
                    ],
                  ),
                ),
                ...List.generate(
                  5,
                  (i) => Icon(
                    i < review.rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 18,
                  ),
                ),
              ],
            ),
            if (review.comment.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(review.comment),
            ],
          ],
        ),
      ),
    );
  }
}
