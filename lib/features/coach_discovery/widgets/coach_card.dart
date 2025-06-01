import 'package:fitness/core/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../profile/models/coach_profile_model.dart';

class CoachCard extends StatelessWidget {
  final CoachProfileModel coach;
  final String? connectionStatus;
  final VoidCallback? onRequestConnection;

  const CoachCard({
    super.key,
    required this.coach,
    this.connectionStatus,
    this.onRequestConnection,
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
              backgroundImage:
                  coach.profilePicture != null
                      ? NetworkImage(coach.profilePicture!)
                      : null,
              child:
                  coach.profilePicture == null
                      ? const Icon(Icons.person, size: 30)
                      : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    coach.name, // Display name instead of userId
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Specializations: ${coach.specializations.join(', ')}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            if (connectionStatus == null)
              ElevatedButton(
                onPressed: onRequestConnection,
                child: const Text('Request Connection'),
              )
            else
              Text(
                connectionStatus!.capitalizeFirst!,
                style: TextStyle(
                  color:
                      connectionStatus == AppConstants1.connectionStatusAccepted
                          ? Colors.green
                          : connectionStatus ==
                              AppConstants1.connectionStatusRejected
                          ? Colors.red
                          : Colors.orange,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
