import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/dashboard_controller.dart';
import '../../auth/widgets/custom_button.dart';

class MyStudentsScreen extends StatelessWidget {
  const MyStudentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final DashboardController controller = Get.find<DashboardController>();
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('My Students')),
      body: Obx(
        () => controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : controller.connectedStudents.isEmpty
                ? const Center(child: Text('No students connected'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: controller.connectedStudents.length,
                    itemBuilder: (context, index) {
                      final student = controller.connectedStudents[index];
                      return ExpansionTile(
                        leading: CircleAvatar(
                          backgroundImage: student.profilePicture != null
                              ? NetworkImage(student.profilePicture!)
                              : null,
                          child: student.profilePicture == null
                              ? const Icon(Icons.person)
                              : null,
                        ),
                        title: Text(student.name),
                        subtitle: Text(student.email),
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 8.0,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  CustomButton(
                                    text: 'Create Plan',
                                    width: 150,
                                    onPressed: () => Get.toNamed(
                                      '/create-plan',
                                      arguments: {'studentId': student.id},
                                    ),
                                  ),
                                  CustomButton(
                                    text: 'Chat',
                                    width: 150,
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
                                        Get.snackbar('Error', 'Please log in to chat');
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
      ),
    );
  }
}