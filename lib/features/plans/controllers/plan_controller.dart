import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness/core/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../../dashboard/models/plan_model.dart';
import '../../dashboard/services/dashboard_service.dart';

class PlanController extends GetxController {
  final DashboardService _dashboardService = DashboardService();
  final RxBool isLoading = false.obs;
  final RxList<PlanModel> plans = <PlanModel>[].obs;
  final RxString selectedPlanType = AppConstants.planTypeDiet.obs;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController durationController = TextEditingController();
  final RxString selectedFrequency = 'weekly'.obs;
  final RxList<String> selectedGoals = <String>[].obs;
  final RxList<File> mediaFiles = <File>[].obs;
  final RxString errorMessage = ''.obs;

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    durationController.dispose();
    super.onClose();
  }

  Future<void> loadPlans(String studentId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      print('PlanController: Loading plans for studentId: $studentId');
      plans.value = await _dashboardService.getPlansForStudent(studentId);
      print('PlanController: Loaded ${plans.length} plans');
    } catch (e) {
      print('PlanController: Error loading plans: $e');
      errorMessage.value = e.toString().contains('failed-precondition')
          ? 'Unable to load plans due to a database configuration issue. Please try again later or contact support.'
          : 'Failed to load plans: $e';
      Get.snackbar('Error', errorMessage.value, duration: const Duration(seconds: 5));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createPlan(String studentId) async {
    print('createPlan called with studentId: $studentId');
    try {
      isLoading.value = true;
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        print('No user logged in');
        Get.snackbar('Error', 'Please log in to create a plan', duration: const Duration(seconds: 3));
        Get.offAllNamed('/login');
        return;
      }

      if (titleController.text.isEmpty ||
          descriptionController.text.isEmpty ||
          durationController.text.isEmpty ||
          selectedGoals.isEmpty) {
        print('Validation failed: required fields empty');
        Get.snackbar('Error', 'Please fill in all required fields', duration: const Duration(seconds: 3));
        return;
      }

      final duration = int.tryParse(durationController.text);
      if (duration == null || duration <= 0) {
        print('Validation failed: invalid duration');
        Get.snackbar('Error', 'Duration must be a positive number', duration: const Duration(seconds: 3));
        return;
      }

      await _dashboardService.createPlan(
        coachId: currentUser.uid,
        studentId: studentId,
        type: selectedPlanType.value,
        title: titleController.text,
        description: descriptionController.text,
        duration: duration,
        frequency: selectedFrequency.value,
        goals: selectedGoals.toList(),
        mediaFiles: mediaFiles.toList(),
      );

      Get.back();
      Get.snackbar('Success', 'Plan created successfully', duration: const Duration(seconds: 3));
    } catch (e) {
      print('Error creating plan: $e');
      Get.snackbar('Error', 'Failed to create plan: $e', duration: const Duration(seconds: 3));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickMedia() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'mp4'],
        allowMultiple: true,
      );
      if (result != null) {
        mediaFiles.addAll(result.files.map((file) => File(file.path!)));
        print('Picked ${mediaFiles.length} media files');
      }
    } catch (e) {
      print('Error picking media: $e');
      Get.snackbar('Error', 'Failed to pick media: $e', duration: const Duration(seconds: 3));
    }
  }
}