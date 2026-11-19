import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/repair_request.dart';
import '../../models/review.dart';
import '../../providers/review_providers.dart';

class RateTechnicianDialog extends ConsumerStatefulWidget {
  final RepairRequest request;
  const RateTechnicianDialog({super.key, required this.request});

  @override
  ConsumerState<RateTechnicianDialog> createState() =>
      _RateTechnicianDialogState();
}

class _RateTechnicianDialogState extends ConsumerState<RateTechnicianDialog> {
  final _commentController = TextEditingController();
  int _rating = 0;
  bool _isLoading = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please choose a star rating')),
      );
      return;
    }
    final r = widget.request;
    setState(() => _isLoading = true);
    try {
      await ref.read(reviewRepositoryProvider).submit(
            Review(
              id: r.id,
              requestId: r.id,
              customerId: r.customerId,
              customerName: r.customerName,
              technicianId: r.technicianId!,
              rating: _rating,
              comment: _commentController.text.trim(),
              createdAt: DateTime.now(),
            ),
          );
      if (!mounted) return;
      Navigator.pop(context);
    } on FirebaseException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not submit review: ${e.code}')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Rate your technician'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              5,
              (i) => IconButton(
                onPressed:
                    _isLoading ? null : () => setState(() => _rating = i + 1),
                icon: Icon(
                  i < _rating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 32,
                ),
              ),
            ),
          ),
          TextField(
            controller: _commentController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Comment (optional)',
              alignLabelWithHint: true,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Later'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Submit'),
        ),
      ],
    );
  }
}
