import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fitness/core/constants/app_constants.dart';
import '../../auth/models/user_model.dart';
import '../models/connection_model.dart';
import '../models/plan_model.dart';

class DashboardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<UserModel?> getUser(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .get();
      if (doc.exists) {
        return UserModel.fromMap(userId, doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<ConnectionModel?> getActiveConnectionForStudent(String studentId) async {
    try {
      QuerySnapshot query = await _firestore
          .collection(AppConstants.connectionsCollection)
          .where('studentId', isEqualTo: studentId)
          .where('status', isEqualTo: 'accepted')
          .limit(1)
          .get();
      if (query.docs.isNotEmpty) {
        return ConnectionModel.fromMap(
            query.docs.first.id, query.docs.first.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      if (e.toString().contains('failed-precondition') && e.toString().contains('requires an index')) {
        print('Index required for getActiveConnectionForStudent: $e');
        throw Exception('Unable to load connections. Please contact support to enable required database index.');
      }
      rethrow;
    }
  }

  Future<List<ConnectionModel>> getPendingConnectionsForCoach(String coachId) async {
    try {
      QuerySnapshot query = await _firestore
          .collection(AppConstants.connectionsCollection)
          .where('coachId', isEqualTo: coachId)
          .where('status', isEqualTo: 'pending')
          .get();
      return query.docs
          .map((doc) => ConnectionModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (e.toString().contains('failed-precondition') && e.toString().contains('requires an index')) {
        print('Index required for getPendingConnectionsForCoach: $e');
        throw Exception('Unable to load pending connections. Please contact support to enable required database index.');
      }
      rethrow;
    }
  }

  Future<List<ConnectionModel>> getAcceptedConnectionsForCoach(String coachId) async {
    try {
      QuerySnapshot query = await _firestore
          .collection(AppConstants.connectionsCollection)
          .where('coachId', isEqualTo: coachId)
          .where('status', isEqualTo: 'accepted')
          .get();
      return query.docs
          .map((doc) => ConnectionModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (e.toString().contains('failed-precondition') && e.toString().contains('requires an index')) {
        print('Index required for getAcceptedConnectionsForCoach: $e');
        throw Exception('Unable to load accepted connections. Please contact support to enable required database index.');
      }
      rethrow;
    }
  }

  Future<List<ConnectionModel>> getConnectionsByStatus(String coachId, String status) async {
    try {
      QuerySnapshot query = await _firestore
          .collection(AppConstants.connectionsCollection)
          .where('coachId', isEqualTo: coachId)
          .where('status', isEqualTo: status)
          .get();
      return query.docs
          .map((doc) => ConnectionModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (e.toString().contains('failed-precondition') && e.toString().contains('requires an index')) {
        print('Index required for getConnectionsByStatus: $e');
        throw Exception('Unable to load connections. Please contact support to enable required database index.');
      }
      rethrow;
    }
  }

  Future<List<PlanModel>> getPlansForStudent(String studentId) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.plansCollection)
          .where('studentId', isEqualTo: studentId)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => PlanModel.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      print('DashboardService: Error getting plans: $e');
      throw Exception('Failed to get plans: $e');
    }
  }

  Future<PlanModel?> getLatestPlanForStudent(String studentId) async {
    try {
      print('getLatestPlanForStudent: Querying latest plan for studentId: $studentId');
      QuerySnapshot query = await _firestore
          .collection(AppConstants.plansCollection)
          .where('studentId', isEqualTo: studentId)
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();
      if (query.docs.isNotEmpty) {
        final plan = PlanModel.fromMap(
            query.docs.first.id, query.docs.first.data() as Map<String, dynamic>);
        print('getLatestPlanForStudent: Found plan ${plan.id}');
        return plan;
      }
      print('getLatestPlanForStudent: No plans found');
      return null;
    } catch (e) {
      print('getLatestPlanForStudent: Error: $e');
      if (e.toString().contains('failed-precondition') && e.toString().contains('requires an index')) {
        print('Index required for getLatestPlanForStudent: $e');
        throw Exception('Unable to load plans. Please contact support to enable required database index.');
      }
      rethrow;
    }
  }
 Future<void> createPlan({
    required String coachId,
    required String studentId,
    required String type,
    required String title,
    required String description,
    required int duration,
    required String frequency,
    required List<String> goals,
    required List<File> mediaFiles,
  }) async {
    try {
      final planId = _firestore.collection(AppConstants.plansCollection).doc().id;
      final List<Map<String, String>> media = [];

      // Upload media to Firebase Storage
      for (var file in mediaFiles) {
        final fileName = file.path.split('/').last;
        final storageRef = _storage
            .ref()
            .child('plan_media/$planId/${DateTime.now().millisecondsSinceEpoch}_$fileName');
        await storageRef.putFile(file);
        final url = await storageRef.getDownloadURL();
        final type = fileName.endsWith('.mp4') ? 'video' : 'image';
        media.add({'url': url, 'type': type});
      }

      final plan = PlanModel(
        id: planId,
        coachId: coachId,
        studentId: studentId,
        type: type,
        title: title,
        description: description,
        duration: duration,
        frequency: frequency,
        goals: goals,
        media: media,
        createdAt: Timestamp.now(),
        updatedAt: Timestamp.now(),
      );

      await _firestore
          .collection(AppConstants.plansCollection)
          .doc(planId)
          .set(plan.toMap());
    } catch (e) {
      print('DashboardService: Error creating plan: $e');
      throw Exception('Failed to create plan: $e');
    }
  }
  Future<void> updateConnectionStatus(String connectionId, String status) async {
    try {
      await _firestore
          .collection(AppConstants.connectionsCollection)
          .doc(connectionId)
          .update({
        'status': status,
        'acceptedAt': status == 'accepted' ? Timestamp.now() : null,
      });
    } catch (e) {
      rethrow;
    }
  }
}