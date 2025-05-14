import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness/core/constants/app_constants.dart';
import 'package:fitness/features/profile/models/coach_profile_model.dart';

class ConnectionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Send a connection request from Student to Coach
  Future<void> sendConnectionRequest(String coachId) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) throw Exception('No user logged in');

      final connectionId = '${currentUser.uid}_$coachId';
      await _firestore.collection(AppConstants.connectionsCollection).doc(connectionId).set({
        'connectionId': connectionId,
        'studentId': currentUser.uid,
        'coachId': coachId,
        'status': 'pending',
        'createdAt': Timestamp.now(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('ConnectionService: Error sending connection request: $e');
      throw Exception('Failed to send connection request: $e');
    }
  }

  // Disconnect Student from Coach (bidirectional)
  Future<void> disconnect(String coachId) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) throw Exception('No user logged in');

      final connectionId = '${currentUser.uid}_$coachId';
      await _firestore.collection(AppConstants.connectionsCollection).doc(connectionId).delete();
    } catch (e) {
      print('ConnectionService: Error disconnecting: $e');
      throw Exception('Failed to disconnect: $e');
    }
  }
  
  // Fetch Coach profiles with names
  Future<List<CoachProfileModel>> getCoachProfiles() async {
    try {
      final coachProfilesSnapshot =
          await _firestore.collection(AppConstants.coachProfilesCollection).get();
      final List<CoachProfileModel> coachProfiles = [];

      for (var doc in coachProfilesSnapshot.docs) {
        final userId = doc.data()['userId'] as String;
        final userDoc =
            await _firestore.collection(AppConstants.usersCollection).doc(userId).get();
        final userName = userDoc.data()?['name'] as String? ?? 'Unknown';
        coachProfiles.add(CoachProfileModel.fromMap(doc.data(), userName));
      }

      return coachProfiles;
    } catch (e) {
      print('ConnectionService: Error fetching coach profiles: $e');
      throw Exception('Failed to fetch coach profiles: $e');
    }
  }
}