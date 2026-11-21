import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/repair_request.dart';
import '../../models/repair_service.dart';
import '../../providers/auth_providers.dart';
import '../../providers/notification_providers.dart';
import '../../providers/repair_providers.dart';
import '../../providers/storage_providers.dart';

class CreateRequestScreen extends ConsumerStatefulWidget {
  const CreateRequestScreen({super.key});

  @override
  ConsumerState<CreateRequestScreen> createState() =>
      _CreateRequestScreenState();
}

class _CreateRequestScreenState extends ConsumerState<CreateRequestScreen> {
  static const _maxImages = 3;
  static const _maxVideoBytes = 40 * 1024 * 1024;

  final _formKey = GlobalKey<FormState>();
  final _modelController = TextEditingController();
  final _notesController = TextEditingController();
  final _picker = ImagePicker();
  final List<XFile> _images = [];
  final List<Uint8List> _previews = [];
  XFile? _video;
  String _filter = 'All';
  RepairService? _service;
  String _turnaround = 'standard';
  bool _isLoading = false;

  int get _total =>
      (_service?.price ?? 0) +
      (_turnaround == 'express' ? expressSurcharge : 0);

  @override
  void dispose() {
    _modelController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _addImages(ImageSource source) async {
    final room = _maxImages - _images.length;
    if (room <= 0) return;

    List<XFile> picked;
    if (source == ImageSource.camera) {
      final one = await _picker.pickImage(
          source: ImageSource.camera, imageQuality: 70, maxWidth: 1280);
      picked = one == null ? [] : [one];
    } else {
      picked = await _picker.pickMultiImage(imageQuality: 70, maxWidth: 1280);
    }

    for (final f in picked.take(room)) {
      final bytes = await f.readAsBytes();
      _images.add(f);
      _previews.add(bytes);
    }
    if (mounted) setState(() {});
  }

  Future<void> _pickVideo(ImageSource source) async {
    final file = await _picker.pickVideo(
      source: source,
      maxDuration: const Duration(seconds: 60),
    );
    if (file == null) return;

    final size = await file.length();
    if (size > _maxVideoBytes) {
      _snack('Video is too large. Maximum is 40 MB.');
      return;
    }
    setState(() => _video = file);
  }

  void _removeImage(int i) {
    setState(() {
      _images.removeAt(i);
      _previews.removeAt(i);
    });
  }

  Future<void> _submit() async {
    if (_service == null) {
      _snack('Please choose a repair service');
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    final user = ref.read(appUserProvider).value;
    if (user == null) return;
    final service = _service!;

    // Match the service category to a Firestore device category
    final cats = ref.read(categoriesProvider).value ?? [];
    String categoryId = '';
    for (final c in cats) {
      if (c.name.toLowerCase() == service.category.toLowerCase()) {
        categoryId = c.id;
        break;
      }
    }

    setState(() => _isLoading = true);
    try {
      final storage = ref.read(storageServiceProvider);

      final urls = <String>[];
      for (var i = 0; i < _images.length; i++) {
        urls.add(await storage.uploadRepairImage(user.uid, _images[i], i));
      }

      String? videoUrl;
      if (_video != null) {
        videoUrl = await storage.uploadRepairVideo(user.uid, _video!);
      }

      final notes = _notesController.text.trim();
      final description =
          notes.isEmpty ? service.title : '${service.title}. $notes';

      final now = DateTime.now();
      await ref.read(repairRepositoryProvider).create(
            RepairRequest(
              customerId: user.uid,
              customerName: user.fullName,
              categoryId: categoryId,
              categoryName: service.category,
              deviceModel: _modelController.text.trim(),
              problemDescription: description,
              serviceName: service.title,
              estimatedPrice: _total,
              turnaround: _turnaround,
              imageUrls: urls,
              videoUrl: videoUrl,
              createdAt: now,
              updatedAt: now,
            ),
          );

      try {
        final techs =
            await ref.read(userRepositoryProvider).watchTechnicians().first;
        await ref.read(notifierProvider).newRequest(
              technicianIds: techs.map((t) => t.uid).toList(),
              fromUserId: user.uid,
              requestId: '',
              device: '${service.category} ${_modelController.text.trim()}',
            );
      } catch (_) {}

      if (!mounted) return;
      Navigator.pop(context);
      _snack('Booking confirmed');
    } on FirebaseException catch (e) {
      _snack('Could not submit: ${e.code}');
    } catch (e) {
      debugPrint('UPLOAD ERROR: $e');
      _snack('Upload error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _serviceTile(RepairService s) {
    final scheme = Theme.of(context).colorScheme;
    final selected = _service?.id == s.id;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => setState(() => _service = s),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: selected
                ? scheme.primaryContainer.withValues(alpha: 0.5)
                : null,
            border: Border.all(
              color: selected ? scheme.primary : scheme.outlineVariant,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.title,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(s.description,
                        style: TextStyle(color: scheme.onSurfaceVariant)),
                    const SizedBox(height: 8),
                    Text('from \$${s.price} · ${s.duration}',
                        style: Theme.of(context).textTheme.labelMedium),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Icon(
                selected ? Icons.check_circle : Icons.radio_button_unchecked,
                color: selected ? scheme.primary : scheme.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _turnaroundCard(String value, String title, String subtitle) {
    final scheme = Theme.of(context).colorScheme;
    final selected = _turnaround == value;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => setState(() => _turnaround = value),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: selected
                ? scheme.primaryContainer.withValues(alpha: 0.5)
                : null,
            border: Border.all(
              color: selected ? scheme.primary : scheme.outlineVariant,
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(subtitle, style: TextStyle(color: scheme.onSurfaceVariant)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final full = _images.length >= _maxImages;
    final visible = _filter == 'All'
        ? repairServices
        : repairServices.where((s) => s.category == _filter).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Book a repair')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Choose a service',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: serviceCategories
                    .map((c) => ChoiceChip(
                          label: Text(c),
                          selected: _filter == c,
                          onSelected: (_) => setState(() {
                            _filter = c;
                            if (_service != null &&
                                c != 'All' &&
                                _service!.category != c) {
                              _service = null;
                            }
                          }),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 14),
              ...visible.map(_serviceTile),
              const SizedBox(height: 10),
              Text('Your device',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
              TextFormField(
                controller: _modelController,
                decoration: const InputDecoration(
                  labelText: 'Brand and model',
                  hintText: 'e.g. Samsung Galaxy A54',
                  prefixIcon: Icon(Icons.smartphone_outlined),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Enter the device model'
                    : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Extra details (optional)',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 24),
              Text('Photos (${_images.length}/$_maxImages)',
                  style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              if (_previews.isNotEmpty) ...[
                SizedBox(
                  height: 100,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _previews.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, i) => Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.memory(_previews[i],
                              width: 100, height: 100, fit: BoxFit.cover),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: InkWell(
                            onTap: _isLoading ? null : () => _removeImage(i),
                            child: const CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.black54,
                              child: Icon(Icons.close,
                                  size: 14, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: (_isLoading || full)
                        ? null
                        : () => _addImages(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Gallery'),
                  ),
                  if (!kIsWeb)
                    OutlinedButton.icon(
                      onPressed: (_isLoading || full)
                          ? null
                          : () => _addImages(ImageSource.camera),
                      icon: const Icon(Icons.photo_camera),
                      label: const Text('Camera'),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              Text('Video (optional, max 40 MB)',
                  style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              if (_video != null)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.videocam),
                  title: Text(_video!.name,
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  trailing: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed:
                        _isLoading ? null : () => setState(() => _video = null),
                  ),
                ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: (_isLoading || _video != null)
                        ? null
                        : () => _pickVideo(ImageSource.gallery),
                    icon: const Icon(Icons.video_library),
                    label: const Text('Choose video'),
                  ),
                  if (!kIsWeb)
                    OutlinedButton.icon(
                      onPressed: (_isLoading || _video != null)
                          ? null
                          : () => _pickVideo(ImageSource.camera),
                      icon: const Icon(Icons.videocam),
                      label: const Text('Record'),
                    ),
                ],
              ),
              const SizedBox(height: 28),
              Text('Turnaround',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
              Row(
                children: [
                  _turnaroundCard('standard', 'Standard', 'Ready in 2 days'),
                  const SizedBox(width: 12),
                  _turnaroundCard('express', 'Express',
                      'Ready tomorrow (+\$$expressSurcharge)'),
                ],
              ),
              const SizedBox(height: 24),
              if (_service != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    'Estimated from \$$_total',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              FilledButton(
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, 56),
                  shape: const StadiumBorder(),
                ),
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Confirm booking'),
              ),
              const SizedBox(height: 10),
              Text(
                'Nothing is charged now. You approve the final price after diagnosis.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
              if (_isLoading && _video != null)
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Text('Uploading, videos can take a minute...',
                      textAlign: TextAlign.center),
                ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
