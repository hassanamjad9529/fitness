import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_constants.dart';

class UserModel {
  final String id;
  final String email;
  final String name;
  final String role;
  final String? profilePicture;
  final Timestamp createdAt;
  final String? bio;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.profilePicture,
    required this.createdAt,
    this.bio,
  });

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'role': role,
      'profilePicture': profilePicture,
      'createdAt': createdAt,
      'bio': bio,
    };
  }

  factory UserModel.fromMap(String id, Map<String, dynamic> map) {
    return UserModel(
      id: id,
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      role: map['role'] ?? '',
      profilePicture: map['profilePicture'],
      createdAt: map['createdAt'] ?? Timestamp.now(),
      bio: map['bio'],
    );
  }
}