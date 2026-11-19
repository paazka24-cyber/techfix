import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/repair_request.dart';

class RepairRepository {
  final _col = FirebaseFirestore.instance.collection('repair_requests');

  // CREATE
  Future<void> create(RepairRequest request) => _col.add(request.toMap());

  // READ (live list for one customer). Sorted in Dart to avoid needing
  // a composite Firestore index.
  Stream<List<RepairRequest>> watchCustomerRequests(String customerId) {
    return _col.where('customerId', isEqualTo: customerId).snapshots().map(
      (snap) {
        final list = snap.docs
            .map((d) => RepairRequest.fromMap(d.data(), d.id))
            .toList();
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return list;
      },
    );
  }

  // READ (live single request)
  Stream<RepairRequest?> watchRequest(String id) {
    return _col.doc(id).snapshots().map(
          (doc) =>
              doc.exists ? RepairRequest.fromMap(doc.data()!, doc.id) : null,
        );
  }

  // UPDATE (customer cancels)
  Future<void> cancel(String id) {
    return _col.doc(id).update({
      'status': RepairStatus.cancelled,
      'updatedAt': Timestamp.now(),
    });
  }
}
