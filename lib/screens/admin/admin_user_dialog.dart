import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/app_user.dart';
import '../../providers/admin_providers.dart';

class UserFormDialog extends ConsumerStatefulWidget {
  final AppUser? user; // null = add technician
  const UserFormDialog({super.key, this.user});

  @override
  ConsumerState<UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends ConsumerState<UserFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.user?.fullName ?? '');
  late final _email = TextEditingController(text: widget.user?.email ?? '');
  late final _phone =
      TextEditingController(text: widget.user?.phoneNumber ?? '');
  late final _address = TextEditingController(text: widget.user?.address ?? '');
  late final _spec =
      TextEditingController(text: widget.user?.specialization ?? '');
  late final _bio = TextEditingController(text: widget.user?.bio ?? '');
  final _password = TextEditingController();
  bool _loading = false;

  bool get _isCreate => widget.user == null;
  bool get _isTech => _isCreate || widget.user!.role == 'technician';

  @override
  void dispose() {
    for (final c in [_name, _email, _phone, _address, _spec, _bio, _password]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final repo = ref.read(adminRepositoryProvider);
    try {
      if (_isCreate) {
        await repo.createTechnician(
          fullName: _name.text.trim(),
          email: _email.text.trim(),
          password: _password.text,
          phoneNumber: _phone.text.trim(),
          specialization: _spec.text.trim(),
        );
      } else {
        await repo.updateUser(widget.user!.uid, {
          'fullName': _name.text.trim(),
          'phoneNumber': _phone.text.trim(),
          if (_isTech) 'specialization': _spec.text.trim(),
          if (_isTech) 'bio': _bio.text.trim(),
          if (!_isTech) 'address': _address.text.trim(),
        });
      }
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(_isCreate ? 'Technician added' : 'User updated')),
      );
    } on FirebaseAuthException catch (e) {
      _error(e.code == 'email-already-in-use'
          ? 'That email is already registered.'
          : 'Could not create account: ${e.code}');
    } on FirebaseException catch (e) {
      _error('Could not save: ${e.code}');
    } catch (e) {
      _error('Could not save: $e');
    }
  }

  void _error(String msg) {
    if (!mounted) return;
    setState(() => _loading = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isCreate
          ? 'Add technician'
          : (_isTech ? 'Edit technician' : 'Edit customer')),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 4),
                TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(labelText: 'Full name'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Enter a name' : null,
                ),
                const SizedBox(height: 14),
                if (_isCreate) ...[
                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (v) => (v == null || !v.contains('@'))
                        ? 'Enter a valid email'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _password,
                    obscureText: true,
                    decoration:
                        const InputDecoration(labelText: 'Temporary password'),
                    validator: (v) => (v == null || v.length < 6)
                        ? 'At least 6 characters'
                        : null,
                  ),
                  const SizedBox(height: 14),
                ],
                TextFormField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Phone number'),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Enter a phone number'
                      : null,
                ),
                const SizedBox(height: 14),
                if (_isTech) ...[
                  TextFormField(
                    controller: _spec,
                    decoration:
                        const InputDecoration(labelText: 'Specialization'),
                  ),
                  if (!_isCreate) ...[
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _bio,
                      maxLines: 3,
                      decoration: const InputDecoration(
                          labelText: 'About', alignLabelWithHint: true),
                    ),
                  ],
                ] else
                  TextFormField(
                    controller: _address,
                    decoration: const InputDecoration(labelText: 'Address'),
                  ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _loading ? null : _save,
          child: _loading
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Save'),
        ),
      ],
    );
  }
}
