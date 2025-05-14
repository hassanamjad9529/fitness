import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/profile_controller.dart';

class ProfilePicturePicker extends StatelessWidget {
  const ProfilePicturePicker({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController controller = Get.find<ProfileController>();

    return Obx(
      () => Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: controller.profilePicture.value != null
                ? FileImage(controller.profilePicture.value!)
                : controller.user.value?.role == 'student' &&
                        controller.studentProfile.value?.profilePicture != null
                    ? NetworkImage(controller.studentProfile.value!.profilePicture!)
                    : controller.user.value?.role == 'coach' &&
                            controller.coachProfile.value?.profilePicture != null
                        ? NetworkImage(controller.coachProfile.value!.profilePicture!)
                        : null,
            child: controller.profilePicture.value == null &&
                    controller.studentProfile.value?.profilePicture == null &&
                    controller.coachProfile.value?.profilePicture == null
                ? const Icon(Icons.person, size: 50)
                : null,
          ),
          TextButton(
            onPressed: () async {
              final picker = ImagePicker();
              final pickedFile = await picker.pickImage(source: ImageSource.gallery);
              if (pickedFile != null) {
                controller.profilePicture.value = File(pickedFile.path);
              }
            },
            child: const Text('Pick Profile Picture'),
          ),
        ],
      ),
    );
  }
}