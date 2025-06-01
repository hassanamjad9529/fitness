import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitness/core/constants/app_constants.dart';
import 'package:fitness/features/dashboard/models/connection_model.dart';
import '../../profile/models/coach_profile_model.dart';

class CoachDiscoveryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<CoachProfileModel>> getAllCoaches() async {
    try {
      QuerySnapshot query =
          await _firestore
              .collection(AppConstants1.coachProfilesCollection)
              .get();
      return query.docs
          .map(
            (doc) => CoachProfileModel.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to load coaches: $e');
    }
  }

  Future<ConnectionModel?> getConnectionStatus(
    String studentId,
    String coachId,
  ) async {
    try {
      QuerySnapshot query =
          await _firestore
              .collection(AppConstants1.connectionsCollection)
              .where('studentId', isEqualTo: studentId)
              .where('coachId', isEqualTo: coachId)
              .limit(1)
              .get();
      if (query.docs.isNotEmpty) {
        return ConnectionModel.fromMap(
          query.docs.first.id,
          query.docs.first.data() as Map<String, dynamic>,
        );
      }
      return null;
    } catch (e) {
      throw Exception('Failed to load connection status: $e');
    }
  }

  Future<void> requestConnection(String studentId, String coachId) async {
    try {
      final connection = ConnectionModel(
        id: '${studentId}_$coachId',
        studentId: studentId,
        coachId: coachId,
        status: AppConstants1.connectionStatusPending,
        createdAt: Timestamp.now(),
      );
      await _firestore
          .collection(AppConstants1.connectionsCollection)
          .doc(connection.id)
          .set(connection.toMap());
    } catch (e) {
      throw Exception('Failed to send connection request: $e');
    }
  }
}
