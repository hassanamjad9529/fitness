import 'package:fitness/core/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../auth/models/user_model.dart';

class ConnectionRequestCard extends StatelessWidget {
  final UserModel student;
  final String status;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;

  const ConnectionRequestCard({
    super.key,
    required this.student,
    required this.status,
    this.onAccept,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: student.profilePicture != null ? NetworkImage(student.profilePicture!) : null,
              child: student.profilePicture == null ? const Icon(Icons.person, size: 30) : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    'Status: ${status.capitalizeFirst}',
                    style: TextStyle(
                      color: status == AppConstants.connectionStatusAccepted
                          ? Colors.green
                          : status == AppConstants.connectionStatusRejected
                              ? Colors.red
                              : Colors.orange,
                    ),
                  ),
                ],
              ),
            ),
            if (onAccept != null && onReject != null) ...[
              IconButton(
                icon: const Icon(Icons.check, color: Colors.green),
                onPressed: onAccept,
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.red),
                onPressed: onReject,
              ),
            ],
          ],
        ),
      ),
    );
  }
}