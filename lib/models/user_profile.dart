import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String displayName;
  final String email;
  final String? gender; // 'Male', 'Female', 'Other', or null
  final DateTime? dateOfBirth;
  final double? heightCm;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfile({
    required this.uid,
    required this.displayName,
    required this.email,
    this.gender,
    this.dateOfBirth,
    this.heightCm,
    required this.createdAt,
    required this.updatedAt,
  });

  UserProfile copyWith({
    String? displayName,
    String? gender,
    DateTime? dateOfBirth,
    double? heightCm,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      uid: uid,
      displayName: displayName ?? this.displayName,
      email: email,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      heightCm: heightCm ?? this.heightCm,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'displayName': displayName,
      'email': email,
      'gender': gender,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'heightCm': heightCm,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> data) {
    final createdAt = data['createdAt'];
    final updatedAt = data['updatedAt'];
    return UserProfile(
      uid: data['uid'] as String,
      displayName: (data['displayName'] ?? '') as String,
      email: (data['email'] ?? '') as String,
      gender: data['gender'] as String?,
      dateOfBirth: (data['dateOfBirth'] != null)
          ? DateTime.tryParse(data['dateOfBirth'] as String)
          : null,
      heightCm: (data['heightCm'] != null)
          ? (data['heightCm'] as num).toDouble()
          : null,
      createdAt: createdAt is Timestamp
          ? createdAt.toDate()
          : DateTime.tryParse(createdAt?.toString() ?? '') ?? DateTime.now(),
      updatedAt: updatedAt is Timestamp
          ? updatedAt.toDate()
          : DateTime.tryParse(updatedAt?.toString() ?? '') ?? DateTime.now(),
    );
  }
}


