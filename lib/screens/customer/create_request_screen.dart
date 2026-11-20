import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/device_category.dart';
import '../../models/repair_request.dart';
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
  static const _maxVideoBytes = 40 * 1024 * 1024; // 40 MB

  final _formKey = GlobalKey<FormState>();
  final _modelController = TextEditingController();
  final _problemController = TextEditingController();
  final _picker = ImagePicker();
  final List<XFile> _images = [];
  final List<Uint8List> _previews = [];
  XFile? _video;
  DeviceCategory? _category;
  bool _isLoading = false;

  @override
  void dispose() {
    _modelController.dispose();
    _problemController.dispose();
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
    if (!_formKey.currentState!.validate()) return;
    final user = ref.read(appUserProvider).value;
    if (user == null || _category == null) return;

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

      final now = DateTime.now();
      await ref.read(repairRepositoryProvider).create(
            RepairRequest(
              customerId: user.uid,
              customerName: user.fullName,
              categoryId: _category!.id,
              categoryName: _category!.name,
              deviceModel: _modelController.text.trim(),
              problemDescription: _problemController.text.trim(),
              imageUrls: urls,
              videoUrl: videoUrl,
              createdAt: now,
              updatedAt: now,
            ),
          );

      // Notify every technician about the new request
      try {
        final techs =
            await ref.read(userRepositoryProvider).watchTechnicians().first;
        await ref.read(notifierProvider).newRequest(
              technicianIds: techs.map((t) => t.uid).toList(),
              fromUserId: user.uid,
              requestId: '',
              device: '${_category!.name} ${_modelController.text.trim()}',
            );
      } catch (_) {
        // the request is saved; a failed notification must not block it
      }

      if (!mounted) return;
      Navigator.pop(context);
      _snack('Repair request submitted');
    } on FirebaseException catch (e) {
      _snack('Could not submit: ${e.code}');
    } catch (e) {
      debugPrint('UPLOAD ERROR: $e');
      _snack('Upload error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);
    final full = _images.length >= _maxImages;

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

              // ---------- Photos ----------
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Photos (${_images.length}/$_maxImages)',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              const SizedBox(height: 8),
              if (_previews.isNotEmpty)
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
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: (_isLoading || full)
                        ? null
                        : () => _addImages(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Gallery'),
                  ),
                  if (!kIsWeb) ...[
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: (_isLoading || full)
                          ? null
                          : () => _addImages(ImageSource.camera),
                      icon: const Icon(Icons.photo_camera),
                      label: const Text('Camera'),
                    ),
                  ],
                ],
              ),

              // ---------- Video ----------
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Video (optional, max 40 MB)',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
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
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: (_isLoading || _video != null)
                        ? null
                        : () => _pickVideo(ImageSource.gallery),
                    icon: const Icon(Icons.video_library),
                    label: const Text('Choose video'),
                  ),
                  if (!kIsWeb) ...[
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: (_isLoading || _video != null)
                          ? null
                          : () => _pickVideo(ImageSource.camera),
                      icon: const Icon(Icons.videocam),
                      label: const Text('Record'),
                    ),
                  ],
                ],
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
              if (_isLoading && _video != null)
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Text('Uploading, videos can take a minute...'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
