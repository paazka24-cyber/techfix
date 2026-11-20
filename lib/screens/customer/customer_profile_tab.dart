import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_providers.dart';
import '../../providers/repair_providers.dart';

class CustomerProfileTab extends ConsumerStatefulWidget {
  const CustomerProfileTab({super.key});

  @override
  ConsumerState<CustomerProfileTab> createState() => _CustomerProfileTabState();
}

class _CustomerProfileTabState extends ConsumerState<CustomerProfileTab> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final u = ref.read(appUserProvider).value;
    _nameController = TextEditingController(text: u?.fullName ?? '');
    _phoneController = TextEditingController(text: u?.phoneNumber ?? '');
    _addressController = TextEditingController(text: u?.address ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final uid = ref.read(authStateProvider).value?.uid;
    if (uid == null) return;

    setState(() => _isLoading = true);
    try {
      await ref.read(userRepositoryProvider).updateCustomerProfile(
            uid,
            fullName: _nameController.text.trim(),
            phoneNumber: _phoneController.text.trim(),
            address: _addressController.text.trim(),
          );
      ref.invalidate(appUserProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile saved')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(appUserProvider).value;
    final scheme = Theme.of(context).colorScheme;
    final name = user?.fullName ?? '';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: CircleAvatar(
                radius: 44,
                backgroundColor: scheme.primaryContainer,
                child: Text(
                  name.isEmpty ? '?' : name[0].toUpperCase(),
                  style:
                      TextStyle(fontSize: 34, color: scheme.onPrimaryContainer),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(child: Text(user?.email ?? '')),
            const SizedBox(height: 24),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full name',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Enter your name' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone number',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Enter your phone' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Address (optional)',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _isLoading ? null : _save,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save profile'),
            ),
          ],
        ),
      ),
    );
  }
}
