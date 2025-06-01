import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness/core/constants/app_constants.dart';
import 'package:fitness/features/dashboard/models/connection_model.dart';
import 'package:get/get.dart';
import '../../profile/models/coach_profile_model.dart';
import '../services/coach_discovery_service.dart';

class CoachDiscoveryController extends GetxController {
  final CoachDiscoveryService _service = CoachDiscoveryService();
  final RxBool isLoading = false.obs;
  final RxList<CoachProfileModel> coaches = <CoachProfileModel>[].obs;
  final RxMap<String, ConnectionModel?> connectionStatuses =
      <String, ConnectionModel?>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadCoaches();
  }

  Future<void> loadCoaches() async {
    try {
      isLoading.value = true;
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        Get.snackbar('Error', 'Please log in to view coaches');
        Get.offAllNamed('/login');
        return;
      }
      coaches.value = await _service.getAllCoaches();
      for (var coach in coaches) {
        connectionStatuses[coach.userId] = await _service.getConnectionStatus(
          currentUser.uid,
          coach.userId,
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load coaches: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> requestConnection(String coachId) async {
    try {
      isLoading.value = true;
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        Get.snackbar('Error', 'Please log in to send a request');
        Get.offAllNamed('/login');
        return;
      }
      await _service.requestConnection(currentUser.uid, coachId);
      connectionStatuses[coachId] = ConnectionModel(
        id: '${currentUser.uid}_$coachId',
        studentId: currentUser.uid,
        coachId: coachId,
        status: AppConstants1.connectionStatusPending,
        createdAt: Timestamp.now(),
      );
      Get.snackbar('Success', 'Connection request sent');
    } catch (e) {
      Get.snackbar('Error', 'Failed to send request: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
