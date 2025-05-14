import 'package:fitness/core/constants/app_constants.dart';
import 'package:fitness/core/utils/validator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';
import '../widgets/custom_dropdown.dart';
import '../widgets/profile_picture_picker.dart';
import '../../auth/widgets/custom_button.dart';
import '../../auth/widgets/custom_text_field.dart';

class ProfileViewEditScreen extends StatelessWidget {
  const ProfileViewEditScreen({super.key});

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

    void initializeFields() {
      print(
        'ProfileViewEditScreen: Initializing fields for role ${controller.user.value?.role}',
      );
      if (controller.user.value?.role == AppConstants.roleStudent &&
          controller.studentProfile.value != null) {
        _heightController.text =
            controller.studentProfile.value!.height.toString();
        _weightController.text =
            controller.studentProfile.value!.weight.toString();
        _bodyFatController.text =
            controller.studentProfile.value!.bodyFatPercentage?.toString() ??
            '';
        _selectedFitnessGoal.value =
            controller.studentProfile.value!.fitnessGoals;
        _medicalConditionsController.text =
            controller.studentProfile.value!.medicalConditions ?? '';
        print(
          'ProfileViewEditScreen: Student profile initialized - height: ${_heightController.text}, fitnessGoal: ${_selectedFitnessGoal.value}',
        );
      } else if (controller.user.value?.role == AppConstants.roleCoach &&
          controller.coachProfile.value != null) {
        _qualificationsController.text =
            controller.coachProfile.value!.qualifications;
        _experienceYearsController.text =
            controller.coachProfile.value!.experienceYears.toString();
        _selectedSpecializations.value =
            controller.coachProfile.value!.specializations;
        _availabilityController.text =
            controller.coachProfile.value!.availability;
        print(
          'ProfileViewEditScreen: Coach profile initialized - qualifications: ${_qualificationsController.text}, specializations: ${_selectedSpecializations.value}',
        );
      } else {
        print('ProfileViewEditScreen: No profile data available');
      }
    }

    controller.isLoading.listen((isLoading) {
      if (!isLoading && controller.user.value != null) {
        initializeFields();
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: Obx(
        () =>
            controller.isLoading.value
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        ProfilePicturePicker(),
                        const SizedBox(height: 16),
                        if (controller.user.value?.role ==
                            AppConstants.roleStudent) ...[
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
                          Obx(
                            () => DropdownButtonFormField<String>(
                              value:
                                  _selectedFitnessGoal.value.isEmpty
                                      ? null
                                      : _selectedFitnessGoal.value,
                              items:
                                  AppConstants.fitnessGoals
                                      .map(
                                        (goal) => DropdownMenuItem(
                                          value: goal,
                                          child: Text(
                                            goal,
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  _selectedFitnessGoal.value = value;
                                  print(
                                    'ProfileViewEditScreen: Fitness goal changed to $value',
                                  );
                                }
                              },
                              decoration: InputDecoration(
                                labelText: 'Fitness Goal',
                                border: const OutlineInputBorder(),
                                filled: true,
                                fillColor: const Color(0xFF2C3E50),
                                labelStyle: const TextStyle(
                                  color: Color.fromARGB(255, 247, 247, 247),
                                ),
                              ),
                              dropdownColor: const Color(0xFF2C3E50),
                              validator:
                                  (value) =>
                                      value == null
                                          ? 'Fitness Goal is required'
                                          : null,
                            ),
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: _medicalConditionsController,
                            label: 'Medical Conditions (Optional)',
                            validator: null,
                            maxLines: 3,
                          ),
                        ] else if (controller.user.value?.role ==
                            AppConstants.roleCoach) ...[
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
                          Obx(
                            () => CustomDropdown(
                              label: 'Specializations',
                              items: AppConstants.specializations,
                              selectedItems: _selectedSpecializations,
                              onChanged: (updated) {
                                _selectedSpecializations.value = updated;
                                print(
                                  'ProfileViewEditScreen: Specializations updated to $updated',
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: _availabilityController,
                            label: 'Availability (e.g., Mon-Fri, 9 AM - 5 PM)',
                            validator: Validator.validateAvailability,
                            maxLines: 2,
                          ),
                        ],
                        const SizedBox(height: 20),
                        CustomButton(
                          text: 'Update Profile',
                          isLoading: controller.isLoading.value,
                          onPressed: () {
                            print(
                              'ProfileViewEditScreen: Update Profile button pressed',
                            );
                            if (_formKey.currentState!.validate()) {
                              if (controller.user.value?.role ==
                                  AppConstants.roleStudent) {
                                controller.updateStudentProfile(
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
                              } else if (controller.user.value?.role ==
                                  AppConstants.roleCoach) {
                                controller.updateCoachProfile(
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
