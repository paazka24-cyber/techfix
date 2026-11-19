import 'package:flutter/material.dart';
import '../models/repair_request.dart';

class StatusChip extends StatelessWidget {
  final String status;
  const StatusChip(this.status, {super.key});

  Color _color() {
    switch (status) {
      case RepairStatus.submitted:
        return Colors.blueGrey;
      case RepairStatus.assigned:
      case RepairStatus.inReview:
        return Colors.blue;
      case RepairStatus.inProgress:
        return Colors.orange;
      case RepairStatus.waitingForParts:
        return Colors.deepOrange;
      case RepairStatus.completed:
      case RepairStatus.delivered:
        return const Color(0xFF00C853);
      case RepairStatus.cancelled:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(
        RepairStatus.label(status),
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: _color(),
      visualDensity: VisualDensity.compact,
      side: BorderSide.none,
    );
  }
}
