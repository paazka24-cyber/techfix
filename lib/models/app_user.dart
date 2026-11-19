import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String role; // 'customer' | 'technician' | 'admin'
  final String? profilePhoto;
  final String? address;
  final String? specialization; // technicians only
  final String? bio; // technicians only
  final double averageRating;
  final int reviewCount;
  final DateTime createdAt;

  AppUser({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.role,
    this.profilePhoto,
    this.address,
    this.specialization,
    this.bio,
    this.averageRating = 0,
    this.reviewCount = 0,
    required this.createdAt,
  });

  factory AppUser.fromMap(Map<String, dynamic> map, String uid) {
    return AppUser(
      uid: uid,
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      role: map['role'] ?? 'customer',
      profilePhoto: map['profilePhoto'],
      address: map['address'],
      specialization: map['specialization'],
      bio: map['bio'],
      averageRating: (map['averageRating'] ?? 0).toDouble(),
      reviewCount: (map['reviewCount'] ?? 0).toInt(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'role': role,
      'profilePhoto': profilePhoto,
      'address': address,
      'specialization': specialization,
      'bio': bio,
      'averageRating': averageRating,
      'reviewCount': reviewCount,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
