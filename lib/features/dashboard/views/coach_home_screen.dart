import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness/core/constants/app_scaffold.dart';
import 'package:fitness/features/auth/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/dashboard_controller.dart';
import '../../auth/widgets/custom_button.dart';
import '../widgets/connection_card.dart';

class CoachHomeScreen extends StatelessWidget {
  const CoachHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final DashboardController controller = Get.put(DashboardController());
    final AuthController authController = Get.put(AuthController());
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Coach Dashboard'),
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
                      // Connected Students
                      Text(
                        'My Students',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      controller.connectedStudents.isEmpty
                          ? const Text('No students connected')
                          : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: controller.connectedStudents.length,
                            itemBuilder: (context, index) {
                              final student =
                                  controller.connectedStudents[index];
                              return Card(
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundImage:
                                        student.profilePicture != null
                                            ? NetworkImage(
                                              student.profilePicture!,
                                            )
                                            : null,
                                    child:
                                        student.profilePicture == null
                                            ? Text(student.name[0])
                                            : null,
                                  ),
                                  title: Text(student.name),
                                  subtitle: Text(student.email),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.chat),
                                    onPressed: () {
                                      if (currentUser != null) {
                                        Get.toNamed(
                                          '/chat',
                                          arguments: {
                                            'studentId': student.id,
                                            'coachId': currentUser.uid,
                                          },
                                        );
                                      } else {
                                        Get.snackbar(
                                          'Error',
                                          'Please log in to chat',
                                        );
                                      }
                                    },
                                  ),
                                  onTap: () => Get.toNamed('/my-students'),
                                ),
                              );
                            },
                          ),
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
                            icon: const Icon(Icons.chat),
                            label: const Text('Chat'),
                            onPressed: () => Get.toNamed('/chat-list'),
                          ),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.person),
                            label: const Text('Profile'),
                            onPressed: () => Get.toNamed('/profile-view-edit'),
                          ),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.group),
                            label: const Text('Manage Students'),
                            onPressed: () => Get.toNamed('/my-students'),
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




