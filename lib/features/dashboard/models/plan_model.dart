import 'package:cloud_firestore/cloud_firestore.dart';

class PlanModel {
  final String id;
  final String coachId;
  final String studentId;
  final String type;
  final String title;
  final String description;
  final int duration; // in weeks
  final String frequency; // e.g., daily, weekly
  final List<String> goals; // e.g., Weight Loss, Muscle Gain
  final List<Map<String, String>> media; // {url, type: image/video}
  final Timestamp createdAt;
  final Timestamp updatedAt;

  PlanModel({
    required this.id,
    required this.coachId,
    required this.studentId,
    required this.type,
    required this.title,
    required this.description,
    required this.duration,
    required this.frequency,
    required this.goals,
    required this.media,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'coachId': coachId,
      'studentId': studentId,
      'type': type,
      'title': title,
      'description': description,
      'duration': duration,
      'frequency': frequency,
      'goals': goals,
      'media': media,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory PlanModel.fromMap(String id, Map<String, dynamic> map) {
    return PlanModel(
      id: id,
      coachId: map['coachId'] ?? '',
      studentId: map['studentId'] ?? '',
      type: map['type'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      duration: map['duration'] ?? 1,
      frequency: map['frequency'] ?? 'weekly',
      goals: List<String>.from(map['goals'] ?? []),
      media: List<Map<String, String>>.from(map['media']?.map((x) => Map<String, String>.from(x)) ?? []),
      createdAt: map['createdAt'] ?? Timestamp.now(),
      updatedAt: map['updatedAt'] ?? Timestamp.now(),
    );
  }
}