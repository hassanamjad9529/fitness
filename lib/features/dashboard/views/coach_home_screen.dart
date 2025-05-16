import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../auth/controllers/auth_controller.dart';
import '../controllers/dashboard_controller.dart';

class CoachHomeScreen extends StatefulWidget {
  const CoachHomeScreen({super.key});

  @override
  State<CoachHomeScreen> createState() => _CoachHomeScreenState();
}

class _CoachHomeScreenState extends State<CoachHomeScreen> {
  int _selectedIndex = 0; // To track which tab is selected
  final AuthController authController = Get.put(AuthController());
  final DashboardController controller = Get.put(DashboardController());
  final currentUser = FirebaseAuth.instance.currentUser;

  // List of bottom nav bar views (can be actual screens in real use case)
  final List<Widget> _screens = [
    const Center(child: Text('Chat List View')),
    const Center(child: Text('Connections View')),
    const Center(child: Text('Profile View')),
    const Center(child: Text('My Students View')),
  ];

  // This method is triggered on tab tap
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

      // Show different body content based on selected tab
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ========== Profile Card ==========
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

              // ========== Students Section ==========
              Text('My Students', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              if (controller.connectedStudents.isEmpty)
                const Text('No students connected')
              else
                ListView.builder(
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
                              Get.toNamed('/chat', arguments: {
                                'studentId': student.id,
                                'coachId': currentUser!.uid,
                              });
                            } else {
                              Get.snackbar('Error', 'Please log in to chat');
                            }
                          },
                        ),
                        onTap: () => Get.toNamed('/my-students'),
                      ),
                    );
                  },
                ),

              const SizedBox(height: 16),

              // ========== Tab-based Screen Placeholder ==========
              _screens[_selectedIndex],
            ],
          ),
        );
      }),

      // ========== Bottom Navigation Bar ==========
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Connections'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Students'),
        ],
      ),
    );
  }
}
