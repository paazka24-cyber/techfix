import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class StorageService {
  static const _cloudName = 'pp3b0usk';
  static const _uploadPreset = 'techfix_unsigned';

  Future<String> uploadRepairImage(String userId, XFile file, int index) {
    return _upload(
      resourceType: 'image',
      userId: userId,
      file: file,
      filename: '${DateTime.now().millisecondsSinceEpoch}_$index.jpg',
    );
  }

  Future<String> uploadRepairVideo(String userId, XFile file) {
    return _upload(
      resourceType: 'video',
      userId: userId,
      file: file,
      filename: '${DateTime.now().millisecondsSinceEpoch}.mp4',
    );
  }

  Future<String> _upload({
    required String resourceType,
    required String userId,
    required XFile file,
    required String filename,
  }) async {
    final bytes = await file.readAsBytes();
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$_cloudName/$resourceType/upload',
    );

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = _uploadPreset
      ..fields['folder'] = 'repair_${resourceType}s/$userId'
      ..files.add(
        http.MultipartFile.fromBytes('file', bytes, filename: filename),
      );

    final response = await request.send();
    final body = await response.stream.bytesToString();
    if (response.statusCode != 200) {
      throw Exception('Upload failed (${response.statusCode})');
    }
    return jsonDecode(body)['secure_url'] as String;
  }
}
