import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fitness/core/constants/app_constants.dart';
import '../models/chat_message_model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  String _getChatRoomId(String studentId, String coachId) {
    return '${studentId}_${coachId}';
  }

  Future<void> sendMessage({
    required String studentId,
    required String coachId,
    required String content,
    required String type,
    File? attachment,
  }) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) throw Exception('No user logged in');

      final chatRoomId = _getChatRoomId(studentId, coachId);
      String? attachmentUrl;

      if (attachment != null) {
        final fileName = attachment.path.split('/').last;
        final storageRef = _storage.ref().child(
          'chat_attachments/$chatRoomId/${DateTime.now().millisecondsSinceEpoch}_$fileName',
        );
        await storageRef.putFile(attachment);
        attachmentUrl = await storageRef.getDownloadURL();
      }

      final message = ChatMessageModel(
        messageId: '',
        senderId: currentUser.uid,
        content: content,
        type: type,
        attachmentUrl: attachmentUrl,
        timestamp: Timestamp.now(),
        isDelivered: true, // Mark as delivered upon sending
      );

      final docRef = await _firestore
          .collection(AppConstants1.chatRoomsCollection)
          .doc(chatRoomId)
          .collection('messages')
          .add(message.toMap());
      await docRef.update({'messageId': docRef.id});

      await _firestore
          .collection(AppConstants1.chatRoomsCollection)
          .doc(chatRoomId)
          .set({
            'studentId': studentId,
            'coachId': coachId,
            'lastMessage': content,
            'lastMessageTime': Timestamp.now(),
          }, SetOptions(merge: true));
    } catch (e) {
      print('ChatService: Error sending message: $e');
      throw Exception('Failed to send message: $e');
    }
  }

  Stream<List<ChatMessageModel>> getMessages(String studentId, String coachId) {
    final chatRoomId = _getChatRoomId(studentId, coachId);
    return _firestore
        .collection(AppConstants1.chatRoomsCollection)
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          final messages =
              snapshot.docs
                  .map((doc) => ChatMessageModel.fromMap(doc.id, doc.data()))
                  .toList();
          // Mark messages as delivered and read
          final currentUser = FirebaseAuth.instance.currentUser;
          if (currentUser != null) {
            for (var msg in messages) {
              if (!msg.isDelivered && msg.senderId != currentUser.uid) {
                _markMessageAsDelivered(studentId, coachId, msg.messageId);
              }
              if (!msg.isRead && msg.senderId != currentUser.uid) {
                _markMessageAsRead(studentId, coachId, msg.messageId);
              }
            }
          }
          return messages;
        });
  }

  Future<void> _markMessageAsDelivered(
    String studentId,
    String coachId,
    String messageId,
  ) async {
    final chatRoomId = _getChatRoomId(studentId, coachId);
    await _firestore
        .collection(AppConstants1.chatRoomsCollection)
        .doc(chatRoomId)
        .collection('messages')
        .doc(messageId)
        .update({'isDelivered': true});
  }

  Future<void> _markMessageAsRead(
    String studentId,
    String coachId,
    String messageId,
  ) async {
    final chatRoomId = _getChatRoomId(studentId, coachId);
    await _firestore
        .collection(AppConstants1.chatRoomsCollection)
        .doc(chatRoomId)
        .collection('messages')
        .doc(messageId)
        .update({'isRead': true});
  }

  Future<void> deleteMessage(
    String studentId,
    String coachId,
    String messageId,
  ) async {
    try {
      final chatRoomId = _getChatRoomId(studentId, coachId);
      final messageRef = _firestore
          .collection(AppConstants1.chatRoomsCollection)
          .doc(chatRoomId)
          .collection('messages')
          .doc(messageId);

      // Check if message has an attachment and delete it
      final messageDoc = await messageRef.get();
      if (messageDoc.exists && messageDoc.data()?['attachmentUrl'] != null) {
        final attachmentUrl = messageDoc.data()!['attachmentUrl'] as String;
        final storageRef = _storage.refFromURL(attachmentUrl);
        await storageRef.delete();
      }

      // Delete the message
      await messageRef.delete();
    } catch (e) {
      print('ChatService: Error deleting message: $e');
      throw Exception('Failed to delete message: $e');
    }
  }
}
