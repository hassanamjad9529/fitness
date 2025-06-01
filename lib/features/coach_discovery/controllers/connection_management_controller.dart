import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness/core/constants/app_constants.dart';
import 'package:fitness/features/dashboard/models/connection_model.dart';
import 'package:get/get.dart';
import '../../auth/models/user_model.dart';
import '../../dashboard/services/dashboard_service.dart';

class ConnectionManagementController extends GetxController {
  final DashboardService _dashboardService = DashboardService();
  final RxBool isLoading = false.obs;
  final RxList<ConnectionModel> pendingConnections = <ConnectionModel>[].obs;
  final RxList<ConnectionModel> acceptedConnections = <ConnectionModel>[].obs;
  final RxList<ConnectionModel> rejectedConnections = <ConnectionModel>[].obs;
  final RxMap<String, UserModel> studentDetails = <String, UserModel>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadConnections();
  }

  Future<void> loadConnections() async {
    try {
      isLoading.value = true;
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        Get.snackbar('Error', 'Please log in to manage connections');
        Get.offAllNamed('/login');
        return;
      }
      pendingConnections.value = await _dashboardService
          .getPendingConnectionsForCoach(currentUser.uid);
      acceptedConnections.value = await _dashboardService
          .getAcceptedConnectionsForCoach(currentUser.uid);
      rejectedConnections.value = await _dashboardService
          .getConnectionsByStatus(
            currentUser.uid,
            AppConstants1.connectionStatusRejected,
          );
      for (var connection in [
        ...pendingConnections,
        ...acceptedConnections,
        ...rejectedConnections,
      ]) {
        final student = await _dashboardService.getUser(connection.studentId);
        if (student != null) {
          studentDetails[connection.studentId] = student;
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load connections: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> acceptConnection(String connectionId) async {
    try {
      isLoading.value = true;
      await _dashboardService.updateConnectionStatus(
        connectionId,
        AppConstants1.connectionStatusAccepted,
      );
      await loadConnections();
      Get.snackbar('Success', 'Connection accepted');
    } catch (e) {
      Get.snackbar('Error', 'Failed to accept connection: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> rejectConnection(String connectionId) async {
    try {
      isLoading.value = true;
      await _dashboardService.updateConnectionStatus(
        connectionId,
        AppConstants1.connectionStatusRejected,
      );
      await loadConnections();
      Get.snackbar('Success', 'Connection rejected');
    } catch (e) {
      Get.snackbar('Error', 'Failed to reject connection: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
