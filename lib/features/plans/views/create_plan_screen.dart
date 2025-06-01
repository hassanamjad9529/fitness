import 'package:fitness/core/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../auth/widgets/custom_button.dart';
import '../controllers/plan_controller.dart';

class CreatePlanScreen extends StatelessWidget {
  const CreatePlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final PlanController controller = Get.put(PlanController());
    final Map<String, dynamic>? args = Get.arguments;
    final String studentId = args?['studentId'] ?? '';
    print('CreatePlanScreen built with studentId: $studentId');

    return Scaffold(
      appBar: AppBar(title: const Text('Create Plan')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(
          () =>
              controller.isLoading.value
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Plan Type',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        DropdownButton<String>(
                          value: controller.selectedPlanType.value,
                          isExpanded: true,
                          items:
                              AppConstants1.planTypes
                                  .map(
                                    (type) => DropdownMenuItem(
                                      value: type,
                                      child: Text(type.capitalizeFirst!),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              controller.selectedPlanType.value = value;
                              print('Plan type changed to: $value');
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Title',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        TextField(
                          controller: controller.titleController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Enter plan title',
                          ),
                          style: const TextStyle(color: Color(0xFF001F3F)),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Description',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        TextField(
                          controller: controller.descriptionController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Enter plan description',
                          ),
                          style: const TextStyle(color: Color(0xFF001F3F)),
                          maxLines: 5,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Duration (weeks)',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        TextField(
                          controller: controller.durationController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Enter duration in weeks',
                          ),
                          style: const TextStyle(color: Color(0xFF001F3F)),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Frequency',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        DropdownButton<String>(
                          value: controller.selectedFrequency.value,
                          isExpanded: true,
                          items:
                              ['daily', 'weekly', 'biweekly']
                                  .map(
                                    (freq) => DropdownMenuItem(
                                      value: freq,
                                      child: Text(freq.capitalizeFirst!),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              controller.selectedFrequency.value = value;
                              print('Frequency changed to: $value');
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Goals',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Wrap(
                          spacing: 8.0,
                          children:
                              AppConstants1.fitnessGoals.map((goal) {
                                return Obx(
                                  () => FilterChip(
                                    label: Text(goal),
                                    selected: controller.selectedGoals.contains(
                                      goal,
                                    ),
                                    onSelected: (selected) {
                                      if (selected) {
                                        controller.selectedGoals.add(goal);
                                      } else {
                                        controller.selectedGoals.remove(goal);
                                      }
                                      print(
                                        'Goals updated: ${controller.selectedGoals}',
                                      );
                                    },
                                  ),
                                );
                              }).toList(),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Media',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        CustomButton(
                          text: 'Upload Media (Images/Videos)',
                          onPressed: controller.pickMedia,
                        ),
                        const SizedBox(height: 8),
                        Obx(
                          () => Wrap(
                            spacing: 8.0,
                            children:
                                controller.mediaFiles
                                    .map(
                                      (file) => Chip(
                                        label: Text(file.path.split('/').last),
                                        onDeleted: () {
                                          controller.mediaFiles.remove(file);
                                          print('Removed media: ${file.path}');
                                        },
                                      ),
                                    )
                                    .toList(),
                          ),
                        ),
                        const SizedBox(height: 24),
                        CustomButton(
                          text: 'Create Plan',
                          isLoading: controller.isLoading.value,
                          onPressed: () => controller.createPlan(studentId),
                        ),
                      ],
                    ),
                  ),
        ),
      ),
    );
  }
}
