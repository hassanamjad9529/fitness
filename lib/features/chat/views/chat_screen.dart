import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/chat_controller.dart';
import '../models/chat_message_model.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ChatController());
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: Column(
        children: [
          Expanded(
            child: Obx(
              () => ListView.builder(
                reverse: true,
                itemCount: controller.messages.length,
                itemBuilder: (context, index) {
                  final message = controller.messages[index];
                  final isMe = message.senderId == currentUser?.uid;
                  return GestureDetector(
                    onLongPress:
                        isMe
                            ? () => _showDeleteDialog(
                              context,
                              controller,
                              message.messageId,
                            )
                            : null,
                    child: _buildMessageBubble(message, isMe),
                  );
                },
              ),
            ),
          ),
          _buildMessageInput(controller),
          SizedBox(height: 30),
        ],
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    ChatController controller,
    String messageId,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Message'),
            content: const Text(
              'Are you sure you want to delete this message?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  controller.deleteMessage(messageId);
                  Navigator.pop(context);
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildMessageBubble(ChatMessageModel message, bool isMe) {
    final bubbleColor = isMe ? Colors.green[100] : Colors.blue[100];
    final alignment = isMe ? Alignment.centerRight : Alignment.centerLeft;
    final margin =
        isMe
            ? const EdgeInsets.only(left: 50, right: 10, top: 5, bottom: 5)
            : const EdgeInsets.only(left: 10, right: 50, top: 5, bottom: 5);

    return Container(
      margin: margin,
      child: Align(
        alignment: alignment,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              if (message.type == 'text') ...[
                Text(
                  message.content,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF2C3E50),
                  ),
                ),
              ] else if (message.type == 'image' &&
                  message.attachmentUrl != null) ...[
                GestureDetector(
                  onTap: () => _launchUrl(message.attachmentUrl!),
                  child: Image.network(
                    message.attachmentUrl!,
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
                Text(
                  message.content,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF2C3E50),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ] else if (message.type == 'pdf' &&
                  message.attachmentUrl != null) ...[
                GestureDetector(
                  onTap: () => _launchUrl(message.attachmentUrl!),
                  child: Row(
                    children: [
                      const Icon(Icons.picture_as_pdf, color: Colors.red),
                      const SizedBox(width: 5),
                      Text(
                        message.content,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 5),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    DateFormat('hh:mm a').format(message.timestamp.toDate()),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  if (isMe) ...[
                    const SizedBox(width: 5),
                    _buildMessageStatusTicks(message),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageStatusTicks(ChatMessageModel message) {
    if (message.isRead) {
      return const Icon(Icons.done_all, size: 16, color: Colors.blue);
    } else if (message.isDelivered) {
      return const Icon(Icons.done_all, size: 16, color: Colors.grey);
    } else {
      return const Icon(Icons.done, size: 16, color: Colors.grey);
    }
  }

  Widget _buildMessageInput(ChatController controller) {
    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.grey[200],
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.image, color: Color(0xFF2C3E50)),
            onPressed: controller.pickImage,
          ),
          IconButton(
            icon: const Icon(Icons.attach_file, color: Color(0xFF2C3E50)),
            onPressed: controller.pickFile,
          ),
          Expanded(
            child: TextField(
              style: const TextStyle(color: Color(0xFF2C3E50)),
              controller: controller.messageController,
              decoration: const InputDecoration(
                hintStyle: TextStyle(color: Colors.grey),
                hintText: 'Type a message...',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Obx(
            () => IconButton(
              icon:
                  controller.isLoading.value
                      ? const CircularProgressIndicator()
                      : const Icon(Icons.send, color: Color(0xFF2C3E50)),
              onPressed:
                  controller.isLoading.value
                      ? null
                      : () => controller.sendMessage(
                        controller.messageController.text,
                      ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      Get.snackbar('Error', 'Cannot open attachment');
    }
  }
}
