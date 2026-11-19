import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/repair_request.dart';

class RepairRepository {
  final _col = FirebaseFirestore.instance.collection('repair_requests');

  // CREATE
  Future<void> create(RepairRequest request) => _col.add(request.toMap());

  // READ: customer's own requests
  Stream<List<RepairRequest>> watchCustomerRequests(String customerId) {
    return _col.where('customerId', isEqualTo: customerId).snapshots().map(
          (snap) => _sorted(snap),
        );
  }

  // READ: open pool for technicians (not taken, not rejected by me)
  Stream<List<RepairRequest>> watchAvailableRequests(String technicianId) {
    return _col
        .where('status', isEqualTo: RepairStatus.submitted)
        .snapshots()
        .map((snap) => _sorted(snap)
            .where((r) =>
                r.technicianId == null && !r.rejectedBy.contains(technicianId))
            .toList());
  }

  // READ: jobs assigned to this technician
  Stream<List<RepairRequest>> watchTechnicianJobs(String technicianId) {
    return _col
        .where('technicianId', isEqualTo: technicianId)
        .snapshots()
        .map((snap) => _sorted(snap));
  }

  // READ: one request, live
  Stream<RepairRequest?> watchRequest(String id) {
    return _col.doc(id).snapshots().map(
          (doc) =>
              doc.exists ? RepairRequest.fromMap(doc.data()!, doc.id) : null,
        );
  }

  // UPDATE: customer cancels
  Future<void> cancel(String id) {
    return _col.doc(id).update({
      'status': RepairStatus.cancelled,
      'updatedAt': Timestamp.now(),
    });
  }

  // UPDATE: technician accepts an open request
  Future<void> accept(String id, String technicianId) {
    return _col.doc(id).update({
      'technicianId': technicianId,
      'status': RepairStatus.assigned,
      'updatedAt': Timestamp.now(),
    });
  }

  // UPDATE: technician rejects (hides it from their own pool only)
  Future<void> reject(String id, String technicianId) {
    return _col.doc(id).update({
      'rejectedBy': FieldValue.arrayUnion([technicianId]),
      'updatedAt': Timestamp.now(),
    });
  }

  // UPDATE: technician changes the repair status
  Future<void> updateStatus(String id, String status) {
    return _col.doc(id).update({
      'status': status,
      'updatedAt': Timestamp.now(),
    });
  }

  List<RepairRequest> _sorted(QuerySnapshot<Map<String, dynamic>> snap) {
    final list =
        snap.docs.map((d) => RepairRequest.fromMap(d.data(), d.id)).toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }
}
