import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/device_category.dart';
import '../../models/repair_request.dart';
import '../../providers/auth_providers.dart';
import '../../providers/repair_providers.dart';

class CreateRequestScreen extends ConsumerStatefulWidget {
  const CreateRequestScreen({super.key});

  @override
  ConsumerState<CreateRequestScreen> createState() =>
      _CreateRequestScreenState();
}

class _CreateRequestScreenState extends ConsumerState<CreateRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _modelController = TextEditingController();
  final _problemController = TextEditingController();
  DeviceCategory? _category;
  bool _isLoading = false;

  @override
  void dispose() {
    _modelController.dispose();
    _problemController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final user = ref.read(appUserProvider).value;
    if (user == null || _category == null) return;

    setState(() => _isLoading = true);
    try {
      final now = DateTime.now();
      await ref.read(repairRepositoryProvider).create(
            RepairRequest(
              customerId: user.uid,
              customerName: user.fullName,
              categoryId: _category!.id,
              categoryName: _category!.name,
              deviceModel: _modelController.text.trim(),
              problemDescription: _problemController.text.trim(),
              createdAt: now,
              updatedAt: now,
            ),
          );
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Repair request submitted')),
      );
    } on FirebaseException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not submit: ${e.code}')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('New Repair Request')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              categories.when(
                loading: () => const LinearProgressIndicator(),
                error: (e, _) => Text('Could not load categories: $e'),
                data: (list) => DropdownButtonFormField<DeviceCategory>(
                  initialValue: _category,
                  decoration: const InputDecoration(labelText: 'Device type'),
                  items: list
                      .map((c) =>
                          DropdownMenuItem(value: c, child: Text(c.name)))
                      .toList(),
                  onChanged: (c) => setState(() => _category = c),
                  validator: (v) => v == null ? 'Select a device type' : null,
                ),
              ),
              TextFormField(
                controller: _modelController,
                decoration: const InputDecoration(
                  labelText: 'Brand and model',
                  hintText: 'e.g. Samsung Galaxy A54',
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Enter the device model'
                    : null,
              ),
              TextFormField(
                controller: _problemController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Describe the problem',
                  alignLabelWithHint: true,
                ),
                validator: (v) => (v == null || v.trim().length < 10)
                    ? 'Please describe the problem (at least 10 characters)'
                    : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Submit request'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
