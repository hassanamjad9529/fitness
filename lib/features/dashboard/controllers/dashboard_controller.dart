import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness/core/constants/app_constants.dart';
import 'package:get/get.dart';
import '../../auth/models/user_model.dart';
import '../models/connection_model.dart';
import '../models/plan_model.dart';
import '../services/dashboard_service.dart';

class DashboardController extends GetxController {
  final DashboardService _dashboardService = DashboardService();
  final RxBool isLoading = false.obs;
  final Rx<UserModel?> user = Rx<UserModel?>(null);
  final Rx<ConnectionModel?> studentConnection = Rx<ConnectionModel?>(null);
  final RxList<ConnectionModel> coachPendingConnections =
      <ConnectionModel>[].obs;
  final RxList<ConnectionModel> coachAcceptedConnections =
      <ConnectionModel>[].obs;
  final Rx<PlanModel?> latestPlan = Rx<PlanModel?>(null);
  final Rx<UserModel?> connectedCoach = Rx<UserModel?>(null);
  final RxList<UserModel> connectedStudents = <UserModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    try {
      isLoading.value = true;
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        Get.snackbar('Error', 'No user logged in. Please log in again.');
        Get.offAllNamed('/login');
        return;
      }
      user.value = await _dashboardService.getUser(currentUser.uid);
      if (user.value == null) {
        Get.snackbar('Error', 'User data not found. Please sign up again.');
        Get.offAllNamed('/login');
        return;
      }
      if (user.value!.role == AppConstants1.roleStudent) {
        await _loadStudentData(currentUser.uid);
      } else if (user.value!.role == AppConstants1.roleCoach) {
        await _loadCoachData(currentUser.uid);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load dashboard: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadStudentData(String studentId) async {
    try {
      studentConnection.value = await _dashboardService
          .getActiveConnectionForStudent(studentId);
      if (studentConnection.value != null) {
        connectedCoach.value = await _dashboardService.getUser(
          studentConnection.value!.coachId,
        );
      }
      latestPlan.value = await _dashboardService.getLatestPlanForStudent(
        studentId,
      );
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  Future<void> _loadCoachData(String coachId) async {
    try {
      coachPendingConnections.value = await _dashboardService
          .getPendingConnectionsForCoach(coachId);
      coachAcceptedConnections.value = await _dashboardService
          .getAcceptedConnectionsForCoach(coachId);
      connectedStudents.clear();
      for (var connection in coachAcceptedConnections) {
        final student = await _dashboardService.getUser(connection.studentId);
        if (student != null) {
          connectedStudents.add(student);
        }
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }
}
