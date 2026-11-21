import 'package:flutter/material.dart';
import '../models/repair_request.dart';
import 'category_icon.dart';
import 'status_chip.dart';

class RequestCard extends StatelessWidget {
  final RepairRequest request;
  final VoidCallback onTap;
  final String? extraLine;

  const RequestCard({
    super.key,
    required this.request,
    required this.onTap,
    this.extraLine,
  });

  String _date(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final r = request;
    final title = r.serviceName.isNotEmpty ? r.serviceName : r.deviceModel;
    final sub = r.serviceName.isNotEmpty
        ? '${r.deviceModel} · ${r.turnaround == 'express' ? 'Express' : 'Standard'}'
        : r.problemDescription;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(categoryIcon(r.categoryName),
                    color: scheme.onPrimaryContainer),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text(
                      sub,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                    if (extraLine != null) ...[
                      const SizedBox(height: 2),
                      Text(extraLine!,
                          style: Theme.of(context).textTheme.labelMedium),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.calendar_today,
                            size: 14, color: scheme.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(_date(r.createdAt),
                            style: Theme.of(context).textTheme.labelSmall),
                        if (r.estimatedPrice > 0) ...[
                          const SizedBox(width: 10),
                          Text('from \$${r.estimatedPrice}',
                              style: Theme.of(context).textTheme.labelSmall),
                        ],
                        const Spacer(),
                        StatusChip(r.status),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
