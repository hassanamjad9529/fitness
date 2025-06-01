import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness/core/constants/app_constants.dart';
import 'package:get/get.dart';
import '../../auth/models/user_model.dart';
import '../../auth/services/auth_service.dart';
import '../models/student_profile_model.dart';
import '../models/coach_profile_model.dart';
import '../services/profile_service.dart';

class ProfileController extends GetxController {
  final ProfileService _profileService = ProfileService();
  final AuthService _authService = AuthService();
  final RxBool isLoading = false.obs;
  final RxList<String> selectedSpecializations = <String>[].obs;
  final RxString selectedFitnessGoal = ''.obs;

  final Rx<UserModel?> user = Rx<UserModel?>(null);
  final Rx<StudentProfileModel?> studentProfile = Rx<StudentProfileModel?>(
    null,
  );

  final Rx<CoachProfileModel?> coachProfile = Rx<CoachProfileModel?>(null);
  final Rx<File?> profilePicture = Rx<File?>(null);

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  Future<void> loadUserData() async {
    try {
      isLoading.value = true;
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        Get.snackbar('Error', 'No user is logged in. Please log in again.');
        Get.offAllNamed('/login');
        return;
      }
      user.value = await _authService.getUser(currentUser.uid);
      if (user.value == null) {
        Get.snackbar('Error', 'User data not found. Please try again.');
        Get.offAllNamed('/login');
        return;
      }
      if (user.value!.role == 'student') {
        studentProfile.value = await _profileService.getStudentProfile(
          currentUser.uid,
        );
      } else if (user.value!.role == 'coach') {
        coachProfile.value = await _profileService.getCoachProfile(
          currentUser.uid,
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load user data: $e');
      Get.offAllNamed('/login');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createStudentProfile({
    required double height,
    required double weight,
    double? bodyFatPercentage,
    required String fitnessGoals,
    String? medicalConditions,
    File? image,
  }) async {
    try {
      isLoading.value = true;
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) throw Exception('No user logged in');

      String? profilePictureUrl;
      if (image != null) {
        profilePictureUrl = await _profileService.uploadProfilePicture(
          currentUser.uid,
          image,
        );
      }

      final profile = StudentProfileModel(
        userId: currentUser.uid,
        height: height,
        weight: weight,
        bodyFatPercentage: bodyFatPercentage,
        fitnessGoals: fitnessGoals,
        medicalConditions: medicalConditions,
        updatedAt: Timestamp.now(),
        profilePicture: profilePictureUrl,
      );

      await _profileService.createStudentProfile(profile);
      studentProfile.value = profile;
      Get.snackbar('Success', 'Profile created successfully');
      Get.offAllNamed(
        user.value!.role == AppConstants1.roleStudent
            ? '/student-home'
            : '/coach-home',
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to create profile: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createCoachProfile({
    required String qualifications,
    required int experienceYears,
    required List<String> specializations,
    required String availability,
    File? image,
  }) async {
    try {
      isLoading.value = true;
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) throw Exception('No user logged in');

      String? profilePictureUrl;
      if (image != null) {
        profilePictureUrl = await _profileService.uploadProfilePicture(
          currentUser.uid,
          image,
        );
      }

      final profile = CoachProfileModel(
        userId: currentUser.uid,
        name: user.value?.name ?? '', // Add the required 'name' parameter
        qualifications: qualifications,
        experienceYears: experienceYears,
        specializations: specializations,
        availability: availability,
        updatedAt: Timestamp.now(),
        profilePicture: profilePictureUrl,
      );

      await _profileService.createCoachProfile(profile);
      coachProfile.value = profile;
      Get.snackbar('Success', 'Profile created successfully');
      Get.offAllNamed(
        user.value!.role == AppConstants1.roleStudent
            ? '/student-home'
            : '/coach-home',
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to create profile: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateStudentProfile({
    required double height,
    required double weight,
    double? bodyFatPercentage,
    required String fitnessGoals,
    String? medicalConditions,
    File? image,
  }) async {
    try {
      isLoading.value = true;
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) throw Exception('No user logged in');

      String? profilePictureUrl = studentProfile.value?.profilePicture;
      if (image != null) {
        profilePictureUrl = await _profileService.uploadProfilePicture(
          currentUser.uid,
          image,
        );
      }

      final profile = StudentProfileModel(
        userId: currentUser.uid,
        height: height,
        weight: weight,
        bodyFatPercentage: bodyFatPercentage,
        fitnessGoals: fitnessGoals,
        medicalConditions: medicalConditions,
        updatedAt: Timestamp.now(),
        profilePicture: profilePictureUrl,
      );

      await _profileService.updateStudentProfile(profile);
      studentProfile.value = profile;
      Get.snackbar('Success', 'Profile updated successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update profile: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateCoachProfile({
    required String qualifications,
    required int experienceYears,
    required List<String> specializations,
    required String availability,
    File? image,
  }) async {
    try {
      isLoading.value = true;
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) throw Exception('No user logged in');

      String? profilePictureUrl = coachProfile.value?.profilePicture;
      if (image != null) {
        profilePictureUrl = await _profileService.uploadProfilePicture(
          currentUser.uid,
          image,
        );
      }

      final profile = CoachProfileModel(
        name: user.value?.name ?? '', // Add the required 'name' parameter
        userId: currentUser.uid,
        qualifications: qualifications,
        experienceYears: experienceYears,
        specializations: specializations,
        availability: availability,
        updatedAt: Timestamp.now(),
        profilePicture: profilePictureUrl,
      );

      await _profileService.updateCoachProfile(profile);
      coachProfile.value = profile;
      Get.back();
      Get.snackbar('Success', 'Profile updated successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update profile: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
