import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/device_category.dart';

class CategoryRepository {
  final _col = FirebaseFirestore.instance.collection('device_categories');

  Stream<List<DeviceCategory>> watchCategories() {
    return _col.orderBy('name').snapshots().map(
          (snap) => snap.docs
              .map((d) => DeviceCategory.fromMap(d.data(), d.id))
              .toList(),
        );
  }

  // Adds starter categories the first time the app runs
  Future<void> seedDefaultsIfEmpty() async {
    try {
      final existing = await _col.limit(1).get();
      if (existing.docs.isNotEmpty) return;
      final batch = FirebaseFirestore.instance.batch();
      for (final name in [
        'Phone',
        'Laptop',
        'Tablet',
        'Desktop',
        'Console',
        'Other'
      ]) {
        batch.set(_col.doc(), {'name': name});
      }
      await batch.commit();
    } catch (_) {
      // seeding is best-effort
    }
  }
}
