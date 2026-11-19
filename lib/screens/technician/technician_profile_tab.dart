import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_providers.dart';
import '../../providers/repair_providers.dart';

class TechnicianProfileTab extends ConsumerStatefulWidget {
  const TechnicianProfileTab({super.key});

  @override
  ConsumerState<TechnicianProfileTab> createState() =>
      _TechnicianProfileTabState();
}

class _TechnicianProfileTabState extends ConsumerState<TechnicianProfileTab> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _specController;
  late final TextEditingController _bioController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final u = ref.read(appUserProvider).value;
    _nameController = TextEditingController(text: u?.fullName ?? '');
    _phoneController = TextEditingController(text: u?.phoneNumber ?? '');
    _specController = TextEditingController(text: u?.specialization ?? '');
    _bioController = TextEditingController(text: u?.bio ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _specController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final uid = ref.read(authStateProvider).value?.uid;
    if (uid == null) return;

    setState(() => _isLoading = true);
    try {
      await ref.read(userRepositoryProvider).updateTechnicianProfile(
            uid,
            fullName: _nameController.text.trim(),
            phoneNumber: _phoneController.text.trim(),
            specialization: _specController.text.trim(),
            bio: _bioController.text.trim(),
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Full name'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Enter your name' : null,
            ),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Phone number'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Enter your phone' : null,
            ),
            TextFormField(
              controller: _specController,
              decoration: const InputDecoration(
                labelText: 'Specialization',
                hintText: 'e.g. Phone screens and batteries',
              ),
            ),
            TextFormField(
              controller: _bioController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'About you',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isLoading ? null : _save,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save profile'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
