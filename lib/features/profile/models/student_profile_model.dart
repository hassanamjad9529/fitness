import 'package:cloud_firestore/cloud_firestore.dart';

class StudentProfileModel {
  final String userId;
  final double height;
  final double weight;
  final double? bodyFatPercentage;
  final String fitnessGoals;
  final String? medicalConditions;
  final Timestamp updatedAt;
  final String? profilePicture;

  StudentProfileModel({
    required this.userId,
    required this.height,
    required this.weight,
    this.bodyFatPercentage,
    required this.fitnessGoals,
    this.medicalConditions,
    required this.updatedAt,
    this.profilePicture,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'height': height,
      'weight': weight,
      'bodyFatPercentage': bodyFatPercentage,
      'fitnessGoals': fitnessGoals,
      'medicalConditions': medicalConditions,
      'updatedAt': updatedAt,
      'profilePicture': profilePicture,
    };
  }

  factory StudentProfileModel.fromMap(Map<String, dynamic> map) {
    return StudentProfileModel(
      userId: map['userId'] ?? '',
      height: (map['height'] as num).toDouble(),
      weight: (map['weight'] as num).toDouble(),
      bodyFatPercentage: map['bodyFatPercentage']?.toDouble(),
      fitnessGoals: map['fitnessGoals'] ?? '',
      medicalConditions: map['medicalConditions'],
      updatedAt: map['updatedAt'] ?? Timestamp.now(),
      profilePicture: map['profilePicture'],
    );
  }
}