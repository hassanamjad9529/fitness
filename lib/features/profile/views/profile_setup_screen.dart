import 'package:fitness/core/constants/app_constants.dart';
import 'package:fitness/core/utils/validator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';
import '../widgets/custom_dropdown.dart';
import '../widgets/profile_picture_picker.dart';
import '../../auth/widgets/custom_button.dart';
import '../../auth/widgets/custom_text_field.dart';

class ProfileSetupScreen extends StatelessWidget {
  const ProfileSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController controller = Get.put(ProfileController());
    final _formKey = GlobalKey<FormState>();
    final _heightController = TextEditingController();
    final _weightController = TextEditingController();
    final _bodyFatController = TextEditingController();
    final _medicalConditionsController = TextEditingController();
    final _qualificationsController = TextEditingController();
    final _experienceYearsController = TextEditingController();
    final _availabilityController = TextEditingController();
    final RxList<String> _selectedSpecializations = <String>[].obs;
    final RxString _selectedFitnessGoal = ''.obs;

    return Scaffold(
      appBar: AppBar(title: const Text('Setup Profile')),
      body: Obx(
        () =>
            controller.isLoading.value
                ? const Center(child: CircularProgressIndicator())
                : controller.user.value == null
                ? const Center(
                  child: Text('Error: User data not loaded. Please try again.'),
                )
                : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const ProfilePicturePicker(),
                        const SizedBox(height: 16),
                        if (controller.user.value!.role ==
                            AppConstants1.roleStudent) ...[
                          CustomTextField(
                            controller: _heightController,
                            label: 'Height (cm)',
                            validator: Validator.validateHeight,
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: _weightController,
                            label: 'Weight (kg)',
                            validator: Validator.validateWeight,
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: _bodyFatController,
                            label: 'Body Fat % (Optional)',
                            validator: Validator.validateBodyFatPercentage,
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value:
                                _selectedFitnessGoal.value.isEmpty
                                    ? null
                                    : _selectedFitnessGoal.value,
                            items:
                                AppConstants1.fitnessGoals
                                    .map(
                                      (goal) => DropdownMenuItem(
                                        value: goal,
                                        child: Text(goal),
                                      ),
                                    )
                                    .toList(),
                            onChanged: (value) {
                              if (value != null)
                                _selectedFitnessGoal.value = value;
                            },
                            decoration: const InputDecoration(
                              labelText: 'Fitness Goal',
                              border: OutlineInputBorder(),
                            ),
                            validator:
                                (value) =>
                                    value == null
                                        ? 'Fitness Goal is required'
                                        : null,
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: _medicalConditionsController,
                            label: 'Medical Conditions (Optional)',
                            validator: null,
                            maxLines: 3,
                          ),
                        ] else if (controller.user.value!.role ==
                            AppConstants1.roleCoach) ...[
                          CustomTextField(
                            controller: _qualificationsController,
                            label: 'Qualifications',
                            validator: Validator.validateQualifications,
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: _experienceYearsController,
                            label: 'Years of Experience',
                            validator: Validator.validateExperienceYears,
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 16),
                          CustomDropdown(
                            label: 'Specializations',
                            items: AppConstants1.specializations,
                            selectedItems: _selectedSpecializations,
                            onChanged:
                                (updated) =>
                                    _selectedSpecializations.value = updated,
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: _availabilityController,
                            label: 'Availability (e.g., Mon-Fri, 9 AM - 5 PM)',
                            validator: Validator.validateAvailability,
                            maxLines: 1,
                          ),
                        ],
                        const SizedBox(height: 20),
                        CustomButton(
                          text: 'Save Profile',
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              if (controller.user.value!.role ==
                                  AppConstants1.roleStudent) {
                                controller.createStudentProfile(
                                  height: double.parse(_heightController.text),
                                  weight: double.parse(_weightController.text),
                                  bodyFatPercentage:
                                      _bodyFatController.text.isEmpty
                                          ? null
                                          : double.parse(
                                            _bodyFatController.text,
                                          ),
                                  fitnessGoals: _selectedFitnessGoal.value,
                                  medicalConditions:
                                      _medicalConditionsController.text.isEmpty
                                          ? null
                                          : _medicalConditionsController.text,
                                  image: controller.profilePicture.value,
                                );
                              } else if (controller.user.value!.role ==
                                  AppConstants1.roleCoach) {
                                controller.createCoachProfile(
                                  qualifications:
                                      _qualificationsController.text,
                                  experienceYears: int.parse(
                                    _experienceYearsController.text,
                                  ),
                                  specializations: _selectedSpecializations,
                                  availability: _availabilityController.text,
                                  image: controller.profilePicture.value,
                                );
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
      ),
    );
  }
}
