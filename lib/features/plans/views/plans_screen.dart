import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness/features/dashboard/widgets/plan_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/plan_controller.dart';
import '../widgets/plan_card.dart';

class PlansScreen extends StatelessWidget {
  const PlansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final PlanController controller = Get.put(PlanController());
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      print('PlansScreen: Loading plans for user ${currentUser.uid}');
      controller
          .loadPlans(currentUser.uid)
          .then((_) {
            print('PlansScreen: Loaded ${controller.plans.length} plans');
          })
          .catchError((e) {
            print('PlansScreen: Error loading plans: $e');
          });
    } else {
      print('PlansScreen: No user logged in');
      Get.snackbar(
        'Error',
        'Please log in to view plans',
        duration: const Duration(seconds: 3),
      );
      Get.offAllNamed('/login');
    }

    return Scaffold(
      appBar: AppBar(title: const Text('My Plans')),
      body: Obx(
        () =>
            controller.isLoading.value
                ? const Center(child: CircularProgressIndicator())
                : controller.plans.isEmpty
                ? Center(
                  child: Text(
                    controller.errorMessage.value.isEmpty
                        ? 'No plans available'
                        : controller.errorMessage.value,
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                )
                : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: controller.plans.length,
                  itemBuilder: (context, index) {
                    final plan = controller.plans[index];
                    print(
                      'PlansScreen: Displaying plan ${plan.id} - ${plan.title}',
                    );
                    return PlanCard(plan: plan);
                  },
                ),
      ),
    );
  }
}
