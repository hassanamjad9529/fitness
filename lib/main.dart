import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness/features/auth/controllers/auth_controller.dart';
import 'package:fitness/features/chat/views/chat_list_screen.dart';
import 'package:fitness/features/coach_discovery/views/connection_management_screen.dart';
import 'package:fitness/features/dashboard/controllers/dashboard_controller.dart';
import 'package:fitness/features/profile/views/profile_view_edit_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CoachHomeScreen extends StatefulWidget {
  const CoachHomeScreen({super.key});

  @override
  State<CoachHomeScreen> createState() => _CoachHomeScreenState();
}

class _CoachHomeScreenState extends State<CoachHomeScreen> {
  final DashboardController controller = Get.put(DashboardController());
  final AuthController authController = Get.put(AuthController());
  final currentUser = FirebaseAuth.instance.currentUser;

  int _selectedIndex = 0;

  // These are the pages shown based on the bottom nav index
  final List<Widget> _pages = [
    _DashboardTab(),
    const ChatListScreen(),
    const ConnectionManagementScreen(),
    const ProfileViewEditScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
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

      // IndexedStack keeps state of all tabs alive
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),

      // Bottom navigation bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF1C2526),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Connections',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
  
}
class _DashboardTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final DashboardController controller = Get.find();
    final currentUser = FirebaseAuth.instance.currentUser;

    return Obx(() => controller.isLoading.value
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
                          backgroundImage: controller.user.value?.profilePicture != null
                              ? NetworkImage(controller.user.value!.profilePicture!)
                              : null,
                          child: controller.user.value?.profilePicture == null
                              ? Text(controller.user.value?.name[0] ?? 'U')
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome, ${controller.user.value?.name ?? ''}',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            Text(
                              controller.user.value?.email ?? '',
                              style: Theme.of(context).textTheme.bodySmall,
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
                Obx(() {
                  if (controller.connectedStudents.isEmpty) {
                    return const Text('No students connected');
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.connectedStudents.length,
                    itemBuilder: (context, index) {
                      final student = controller.connectedStudents[index];
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: student.profilePicture != null
                                ? NetworkImage(student.profilePicture!)
                                : null,
                            child: student.profilePicture == null
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
                                Get.snackbar('Error', 'Please log in to chat');
                              }
                            },
                          ),
                          onTap: () => Get.toNamed('/my-students'),
                        ),
                      );
                    },
                  );
                }),
              ],
            ),
          ));
  }
}
