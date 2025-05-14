import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../services/chat_service.dart';
import '../models/chat_message_model.dart';

class ChatController extends GetxController {
  final ChatService _chatService = ChatService();
  final RxList<ChatMessageModel> messages = <ChatMessageModel>[].obs;
  final TextEditingController messageController = TextEditingController();
  final RxBool isLoading = false.obs;
  final RxString studentId = ''.obs;
  final RxString coachId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    final arguments = Get.arguments as Map<String, dynamic>?;
    if (arguments != null) {
      studentId.value = arguments['studentId'] as String;
      coachId.value = arguments['coachId'] as String;
      _loadMessages();
    }
  }

  void _loadMessages() {
    _chatService.getMessages(studentId.value, coachId.value).listen((msgs) {
      messages.value = msgs;
    });
  }

  Future<void> sendMessage(String content, {File? attachment, String type = 'text'}) async {
    if (content.isEmpty && attachment == null) return;
    try {
      isLoading.value = true;
      await _chatService.sendMessage(
        studentId: studentId.value,
        coachId: coachId.value,
        content: content,
        type: type,
        attachment: attachment,
      );
      messageController.clear();
    } catch (e) {
      Get.snackbar('Error', 'Failed to send message: $e', duration: const Duration(seconds: 3));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      await sendMessage('Image attachment', attachment: file, type: 'image');
    }
  }

  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      await sendMessage('PDF attachment', attachment: file, type: 'pdf');
    }
  }

  Future<void> deleteMessage(String messageId) async {
    try {
      await _chatService.deleteMessage(studentId.value, coachId.value, messageId);
      Get.snackbar('Success', 'Message deleted', duration: const Duration(seconds: 2));
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete message: $e', duration: const Duration(seconds: 3));
    }
  }
}