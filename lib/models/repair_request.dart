import 'package:cloud_firestore/cloud_firestore.dart';

class RepairStatus {
  static const submitted = 'submitted';
  static const assigned = 'assigned';
  static const inReview = 'in_review';
  static const inProgress = 'in_progress';
  static const waitingForParts = 'waiting_for_parts';
  static const completed = 'completed';
  static const delivered = 'delivered';
  static const cancelled = 'cancelled';

  static const flow = [
    submitted,
    assigned,
    inReview,
    inProgress,
    waitingForParts,
    completed,
    delivered,
  ];

  // Statuses a technician may set on their own job
  static const technicianOptions = [
    inReview,
    inProgress,
    waitingForParts,
    completed,
    delivered,
  ];

  static String label(String status) {
    switch (status) {
      case submitted:
        return 'Submitted';
      case assigned:
        return 'Assigned';
      case inReview:
        return 'In Review';
      case inProgress:
        return 'In Progress';
      case waitingForParts:
        return 'Waiting for Parts';
      case completed:
        return 'Completed';
      case delivered:
        return 'Delivered';
      case cancelled:
        return 'Cancelled';
      default:
        return status;
    }
  }
}

class RepairRequest {
  final String id;
  final String customerId;
  final String customerName;
  final String? technicianId;
  final String categoryId;
  final String categoryName;
  final String deviceModel;
  final String problemDescription;
  final List<String> imageUrls;
  final List<String> rejectedBy;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  RepairRequest({
    this.id = '',
    required this.customerId,
    required this.customerName,
    this.technicianId,
    required this.categoryId,
    required this.categoryName,
    required this.deviceModel,
    required this.problemDescription,
    this.imageUrls = const [],
    this.rejectedBy = const [],
    this.status = RepairStatus.submitted,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RepairRequest.fromMap(Map<String, dynamic> map, String id) {
    return RepairRequest(
      id: id,
      customerId: map['customerId'] ?? '',
      customerName: map['customerName'] ?? '',
      technicianId: map['technicianId'],
      categoryId: map['categoryId'] ?? '',
      categoryName: map['categoryName'] ?? '',
      deviceModel: map['deviceModel'] ?? '',
      problemDescription: map['problemDescription'] ?? '',
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      rejectedBy: List<String>.from(map['rejectedBy'] ?? []),
      status: map['status'] ?? RepairStatus.submitted,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'customerId': customerId,
      'customerName': customerName,
      'technicianId': technicianId,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'deviceModel': deviceModel,
      'problemDescription': problemDescription,
      'imageUrls': imageUrls,
      'rejectedBy': rejectedBy,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
