import 'package:cloud_firestore/cloud_firestore.dart';

class CoachProfileModel {
  final String userId;
  final String name; // New field for user name
  final String qualifications;
  final int experienceYears;
  final List<String> specializations;
  final String availability;
  final double? rating;
  final Timestamp updatedAt;
  final String? profilePicture;

  CoachProfileModel({
    required this.userId,
    required this.name,
    required this.qualifications,
    required this.experienceYears,
    required this.specializations,
    required this.availability,
    this.rating,
    required this.updatedAt,
    this.profilePicture,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'qualifications': qualifications,
      'experienceYears': experienceYears,
      'specializations': specializations,
      'availability': availability,
      'rating': rating,
      'updatedAt': updatedAt,
      'profilePicture': profilePicture,
    };
  }

  factory CoachProfileModel.fromMap(Map<String, dynamic> map, String name) {
    return CoachProfileModel(
      userId: map['userId'] ?? '',
      name: name, // Populate name from users collection
      qualifications: map['qualifications'] ?? '',
      experienceYears: map['experienceYears'] ?? 0,
      specializations: List<String>.from(map['specializations'] ?? []),
      availability: map['availability'] ?? '',
      rating: map['rating']?.toDouble(),
      updatedAt: map['updatedAt'] ?? Timestamp.now(),
      profilePicture: map['profilePicture'],
    );
  }
}