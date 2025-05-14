import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness/features/dashboard/services/connection_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../auth/models/user_model.dart';

class ConnectionCard extends StatelessWidget {
  final UserModel user;
  final VoidCallback? onChat;
  final VoidCallback? onDisconnected; // <-- Add this

  const ConnectionCard({
    super.key,
    required this.user,
    this.onChat,
    this.onDisconnected, // <-- Add this
  });

  @override
  Widget build(BuildContext context) {
    final ConnectionService connectionService = ConnectionService();
    final currentUser = FirebaseAuth.instance.currentUser;

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: user.profilePicture != null
              ? NetworkImage(user.profilePicture!)
              : null,
          child: user.profilePicture == null ? Text(user.name[0]) : null,
        ),
        title: Text(user.name),
        subtitle: Text(user.email),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.chat),
              onPressed: () {
                if (currentUser != null) {
                  Get.toNamed(
                    '/chat',
                    arguments: {
                      'studentId': currentUser.uid,
                      'coachId': user.id,
                    },
                  );
                } else {
                  Get.snackbar('Error', 'Please log in to chat');
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.remove_circle, color: Colors.red),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Disconnect Coach'),
                    content: const Text(
                      'Are you sure you want to disconnect from this coach?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () async {
                          try {
                            await connectionService.disconnect(user.id);
                            Get.snackbar(
                              'Success',
                              'Disconnected from coach',
                            );
                            Navigator.pop(context);
                            if (onDisconnected != null) {
                              onDisconnected!(); // <-- Notify parent
                            }
                          } catch (e) {
                            Get.snackbar(
                              'Error',
                              'Failed to disconnect: $e',
                            );
                          }
                        },
                        child: const Text(
                          'Disconnect',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}