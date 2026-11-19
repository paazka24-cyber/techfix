import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/review.dart';

class ReviewRepository {
  final _col = FirebaseFirestore.instance.collection('reviews');

  // CREATE: the doc id is the request id, so one review per request
  Future<void> submit(Review review) {
    return _col.doc(review.requestId).set(review.toMap());
  }

  // READ: the review for one request (null if none yet)
  Stream<Review?> watchForRequest(String requestId) {
    return _col.doc(requestId).snapshots().map(
          (doc) => doc.exists ? Review.fromMap(doc.data()!, doc.id) : null,
        );
  }

  // READ: all reviews of one technician (sorted in Dart, no index needed)
  Stream<List<Review>> watchForTechnician(String technicianId) {
    return _col
        .where('technicianId', isEqualTo: technicianId)
        .snapshots()
        .map((snap) {
      final list =
          snap.docs.map((d) => Review.fromMap(d.data(), d.id)).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }
}
