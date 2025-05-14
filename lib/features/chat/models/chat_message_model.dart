import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessageModel {
  final String messageId;
  final String senderId;
  final String content;
  final String type; // text, image, pdf
  final String? attachmentUrl;
  final Timestamp timestamp;
  final bool isDelivered;
  final bool isRead;

  ChatMessageModel({
    required this.messageId,
    required this.senderId,
    required this.content,
    required this.type,
    this.attachmentUrl,
    required this.timestamp,
    this.isDelivered = false,
    this.isRead = false,
  });

  factory ChatMessageModel.fromMap(String id, Map<String, dynamic> map) {
    return ChatMessageModel(
      messageId: id,
      senderId: map['senderId'] as String,
      content: map['content'] as String,
      type: map['type'] as String,
      attachmentUrl: map['attachmentUrl'] as String?,
      timestamp: map['timestamp'] as Timestamp,
      isDelivered: map['isDelivered'] as bool? ?? false,
      isRead: map['isRead'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'content': content,
      'type': type,
      'attachmentUrl': attachmentUrl,
      'timestamp': timestamp,
      'isDelivered': isDelivered,
      'isRead': isRead,
    };
  }
}