import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String id; // same as the request id
  final String requestId;
  final String customerId;
  final String customerName;
  final String technicianId;
  final int rating; // 1 to 5
  final String comment;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.requestId,
    required this.customerId,
    required this.customerName,
    required this.technicianId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory Review.fromMap(Map<String, dynamic> map, String id) {
    return Review(
      id: id,
      requestId: map['requestId'] ?? id,
      customerId: map['customerId'] ?? '',
      customerName: map['customerName'] ?? '',
      technicianId: map['technicianId'] ?? '',
      rating: (map['rating'] ?? 0).toInt(),
      comment: map['comment'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'requestId': requestId,
      'customerId': customerId,
      'customerName': customerName,
      'technicianId': technicianId,
      'rating': rating,
      'comment': comment,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
