import 'package:cloud_firestore/cloud_firestore.dart';

class ConnectionModel {
  final String id;
  final String studentId;
  final String coachId;
  final String status;
  final Timestamp createdAt;
  final Timestamp? acceptedAt;

  ConnectionModel({
    required this.id,
    required this.studentId,
    required this.coachId,
    required this.status,
    required this.createdAt,
    this.acceptedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'coachId': coachId,
      'status': status,
      'createdAt': createdAt,
      'acceptedAt': acceptedAt,
    };
  }

  factory ConnectionModel.fromMap(String id, Map<String, dynamic> map) {
    return ConnectionModel(
      id: id,
      studentId: map['studentId'] ?? '',
      coachId: map['coachId'] ?? '',
      status: map['status'] ?? '',
      createdAt: map['createdAt'] ?? Timestamp.now(),
      acceptedAt: map['acceptedAt'],
    );
  }
}