import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness/core/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../auth/models/user_model.dart';
import '../../auth/services/auth_service.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final authService = AuthService();

    return Scaffold(
      appBar: AppBar(title: const Text('Chats')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection(AppConstants.chatRoomsCollection)
            .where('studentId', isEqualTo: currentUser?.uid)
            .snapshots(),
        builder: (context, studentSnapshot) {
          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection(AppConstants.chatRoomsCollection)
                .where('coachId', isEqualTo: currentUser?.uid)
                .snapshots(),
            builder: (context, coachSnapshot) {
              if (studentSnapshot.connectionState == ConnectionState.waiting ||
                  coachSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final chatRooms = [
                ...(studentSnapshot.data?.docs ?? []),
                ...(coachSnapshot.data?.docs ?? []),
              ];

              if (chatRooms.isEmpty) {
                return const Center(child: Text('No chats available'));
              }

              return ListView.builder(
                itemCount: chatRooms.length,
                itemBuilder: (context, index) {
                  final chatRoom = chatRooms[index].data() as Map<String, dynamic>;
                  final studentId = chatRoom['studentId'] as String;
                  final coachId = chatRoom['coachId'] as String;
                  final lastMessage = chatRoom['lastMessage'] as String?;
                  final lastMessageTime = (chatRoom['lastMessageTime'] as Timestamp?)?.toDate();

                  return FutureBuilder<UserModel?>(
                    future: authService.getUser(currentUser!.uid == studentId ? coachId : studentId),
                    builder: (context, snapshot) {
                      final otherUser = snapshot.data;
                      return ListTile(
                        title: Text(otherUser?.name ?? 'Unknown'),
                        subtitle: Text(lastMessage ?? 'No messages yet'),
                        trailing: lastMessageTime != null
                            ? Text(
                                '${lastMessageTime.hour}:${lastMessageTime.minute.toString().padLeft(2, '0')}',
                              )
                            : null,
                        onTap: () {
                          Get.toNamed('/chat', arguments: {
                            'studentId': studentId,
                            'coachId': coachId,
                          });
                        },
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}