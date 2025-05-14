import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness/features/dashboard/services/connection_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/coach_card.dart';
import '../../profile/models/coach_profile_model.dart';

class CoachDiscoveryController extends GetxController {
  final ConnectionService connectionService = ConnectionService();
  final RxMap<String, String?> connectionStatuses = <String, String?>{}.obs;

  Future<void> loadConnectionStatus(String studentId, String coachId) async {
    final doc =
        await FirebaseFirestore.instance
            .collection('connections')
            .doc('${studentId}_$coachId')
            .get();
    if (doc.exists) {
      connectionStatuses[coachId] = doc['status'] as String?;
    } else {
      connectionStatuses[coachId] = null;
    }
  }

  Future<void> sendRequest(String coachId, String studentId) async {
    await connectionService.sendConnectionRequest(coachId);
    // After sending, update status locally
    connectionStatuses[coachId] = 'pending';
  }
}

class CoachDiscoveryScreen extends StatelessWidget {
  const CoachDiscoveryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CoachDiscoveryController());
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Find a Coach')),
      body: FutureBuilder<List<CoachProfileModel>>(
        future: controller.connectionService.getCoachProfiles(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No coaches available'));
          }

          final coaches = snapshot.data!;
          // Preload connection statuses
          for (final coach in coaches) {
            if (!controller.connectionStatuses.containsKey(coach.userId)) {
              controller.loadConnectionStatus(currentUser!.uid, coach.userId);
            }
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: coaches.length,
            itemBuilder: (context, index) {
              final coach = coaches[index];
              // Only this part is reactive
              return Obx(() {
                final connectionStatus =
                    controller.connectionStatuses[coach.userId];

                return CoachCard(
                  coach: coach,
                  connectionStatus: connectionStatus,
                  onRequestConnection:
                      connectionStatus == null
                          ? () async {
                            try {
                              await controller.sendRequest(
                                coach.userId,
                                currentUser!.uid,
                              );
                              Get.snackbar(
                                'Success',
                                'Connection request sent',
                              );
                            } catch (e) {
                              Get.snackbar(
                                'Error',
                                'Failed to send request: $e',
                              );
                            }
                          }
                          : null,
                );
              });
            },
          );
        },
      ),
    );
  }
}
