import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../auth/widgets/custom_button.dart';
import '../controllers/dashboard_controller.dart';
import '../widgets/connection_card.dart';
import '../widgets/plan_card.dart';

class StudentHomeScreen extends StatelessWidget {
  const StudentHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final DashboardController controller = Get.put(DashboardController());
    final AuthController authController = Get.put(AuthController());
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authController.signOut(),
          ),
        ],
      ),
      body: Obx(
        () =>
            controller.isLoading.value
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile Summary
                      Card(
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundImage:
                                    controller.user.value?.profilePicture !=
                                            null
                                        ? NetworkImage(
                                          controller
                                              .user
                                              .value!
                                              .profilePicture!,
                                        )
                                        : null,
                                child:
                                    controller.user.value?.profilePicture ==
                                            null
                                        ? Text(
                                          controller.user.value?.name[0] ?? 'U',
                                        )
                                        : null,
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Welcome, ${controller.user.value?.name ?? ''}',
                                    style:
                                        Theme.of(
                                          context,
                                        ).textTheme.headlineSmall,
                                  ),
                                  Text(
                                    controller.user.value?.email ?? '',
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Connection Status
                      Text(
                        'Coach Connection',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      if (controller.studentConnection.value != null &&
                          controller.connectedCoach.value != null)
                        // ...inside your Obx or widget tree where you show ConnectionCard...
                        Obx(() {
                          if (controller.studentConnection.value != null &&
                              controller.connectedCoach.value != null) {
                            return ConnectionCard(
                              user: controller.connectedCoach.value!,
                              onDisconnected: () {
                                // Remove/disconnect logic, e.g.:
                                controller.studentConnection.value = null;
                                controller.connectedCoach.value = null;
                              },
                            );
                          } else {
                            return CustomButton(
                              text: 'Find a Coach',
                              onPressed: () => Get.toNamed('/find-coach'),
                            );
                          }
                        })
                      else
                        CustomButton(
                          text: 'Find a Coach',
                          onPressed: () => Get.toNamed('/find-coach'),
                        ),
                      const SizedBox(height: 8),
                      CustomButton(
                        text: 'Explore Coaches',
                        onPressed: () => Get.toNamed('/find-coach'),
                      ),
                      const SizedBox(height: 16),
                      // Latest Plan
                      if (controller.latestPlan.value != null) ...[
                        Text(
                          'Latest Plan',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        PlanCard(plan: controller.latestPlan.value!),
                      ],
                      const SizedBox(height: 16),
                      // Quick Actions
                      Text(
                        'Quick Actions',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: [
                          ElevatedButton.icon(
                            icon: const Icon(Icons.fitness_center),
                            label: const Text('View Plans'),
                            onPressed: () => Get.toNamed('/plans'),
                          ),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.chat),
                            label: const Text('Chat'),
                            onPressed: () {
                              if (controller.studentConnection.value != null &&
                                  controller.connectedCoach.value != null &&
                                  currentUser != null) {
                                Get.toNamed(
                                  '/chat',
                                  arguments: {
                                    'studentId': currentUser.uid,
                                    'coachId':
                                        controller.connectedCoach.value!.id,
                                  },
                                );
                              } else {
                                Get.snackbar(
                                  'Error',
                                  'Connect with a coach to chat',
                                );
                              }
                            },
                          ),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.person),
                            label: const Text('Profile'),
                            onPressed: () => Get.toNamed('/profile-view-edit'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
      ),
    );
  }
}
