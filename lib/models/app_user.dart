import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String role; // 'customer' | 'technician' | 'admin'
  final String? profilePhoto; // nullable: may not exist yet
  final String? address;
  final DateTime createdAt;

  AppUser({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.role,
    this.profilePhoto,
    this.address,
    required this.createdAt,
  });

  // Firestore -> Dart
  factory AppUser.fromMap(Map<String, dynamic> map, String uid) {
    return AppUser(
      uid: uid,
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      role: map['role'] ?? '',
      profilePhoto: map['profilePhoto'],
      address: map['address'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  // Dart -> Firestore
  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'role': role,
      'profilePhoto': profilePhoto,
      'address': address,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
