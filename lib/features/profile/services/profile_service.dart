import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fitness/core/constants/app_constants.dart';
import '../models/student_profile_model.dart';
import '../models/coach_profile_model.dart';

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> createStudentProfile(StudentProfileModel profile) async {
    try {
      await _firestore
          .collection(AppConstants.studentProfilesCollection)
          .doc(profile.userId)
          .set(profile.toMap());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> createCoachProfile(CoachProfileModel profile) async {
    try {
      await _firestore
          .collection(AppConstants.coachProfilesCollection)
          .doc(profile.userId)
          .set(profile.toMap());
    } catch (e) {
      rethrow;
    }
  }

  Future<StudentProfileModel?> getStudentProfile(String userId) async {
    try {
      DocumentSnapshot doc =
          await _firestore
              .collection(AppConstants.studentProfilesCollection)
              .doc(userId)
              .get();
      if (doc.exists) {
        return StudentProfileModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<CoachProfileModel?> getCoachProfile(String userId) async {
    try {
      DocumentSnapshot doc =
          await _firestore
              .collection(AppConstants.coachProfilesCollection)
              .doc(userId)
              .get();
      if (doc.exists) {
        return CoachProfileModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateStudentProfile(StudentProfileModel profile) async {
    try {
      await _firestore
          .collection(AppConstants.studentProfilesCollection)
          .doc(profile.userId)
          .update(profile.toMap());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateCoachProfile(CoachProfileModel profile) async {
    try {
      await _firestore
          .collection(AppConstants.coachProfilesCollection)
          .doc(profile.userId)
          .update(profile.toMap());
    } catch (e) {
      rethrow;
    }
  }

  Future<String?> uploadProfilePicture(String userId, File image) async {
    try {
      final ref = _storage.ref().child('profile_pictures/$userId.jpg');
      await ref.putFile(image);
      return await ref.getDownloadURL();
    } catch (e) {
      rethrow;
    }
  }
}
