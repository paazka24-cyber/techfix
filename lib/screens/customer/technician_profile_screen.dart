import 'package:flutter/material.dart';
import '../../models/app_user.dart';

class TechnicianProfileScreen extends StatelessWidget {
  final AppUser technician;
  const TechnicianProfileScreen({super.key, required this.technician});

  @override
  Widget build(BuildContext context) {
    final t = technician;
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star, color: Colors.amber),
              const SizedBox(width: 4),
              Text(t.reviewCount == 0
                  ? 'No reviews yet'
                  : '${t.averageRating.toStringAsFixed(1)} (${t.reviewCount} reviews)'),
            ],
          ),
          const Divider(height: 40),
          Text('About', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text((t.bio == null || t.bio!.isEmpty)
              ? 'This technician has not added a bio yet.'
              : t.bio!),
        ],
      ),
    );
  }
}
