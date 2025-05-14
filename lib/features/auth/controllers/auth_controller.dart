import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../services/auth_service.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();
  final RxBool isLoading = false.obs;
  final RxString selectedRole = 'student'.obs;

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    try {
      isLoading.value = true;
      User? user = await _authService.signUp(
        email: email,
        password: password,
        name: name,
        role: role,
      );
      if (user != null) {
        Get.snackbar('Success', 'Account created successfully');
        Get.offAllNamed('/profile-setup');
      } else {
        Get.snackbar('Error', 'Failed to create account');
      }
    } catch (e) {
      Get.snackbar('Error', _handleError(e));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      isLoading.value = true;
      User? user = await _authService.login(
        email: email,
        password: password,
      );
      if (user != null) {
        final userData = await _authService.getUser(user.uid);
        if (userData == null) {
          Get.snackbar('Error', 'User data not found. Please sign up again.');
          return;
        }
        Get.snackbar('Success', 'Logged in successfully');
        Get.offAllNamed(userData.role == 'student' ? '/student-home' : '/coach-home');
      } else {
        Get.snackbar('Error', 'Login failed: No user returned');
      }
    } catch (e) {
      Get.snackbar('Error', _handleError(e));
    } finally {
      isLoading.value = false;
    }
  }

  String _handleError(dynamic e) {
    print('Auth Error: $e'); // Log for debugging
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'email-already-in-use':
          return 'This email is already registered.';
        case 'invalid-email':
          return 'Invalid email address.';
        case 'weak-password':
          return 'Password is too weak.';
        case 'user-not-found':
        case 'wrong-password':
          return 'Invalid email or password.';
        default:
          return 'Authentication error: ${e.message}';
      }
    } else if (e is FirebaseException) {
      switch (e.code) {
        case 'permission-denied':
          return 'Firestore permission denied. Check security rules.';
        default:
          return 'Firestore error: ${e.message}';
      }
    } else if (e is Exception) {
      return 'Unexpected error: ${e.toString()}';
    }
    return 'An unexpected error occurred.';
  }
    Future<void> signOut() async {
    try {
      isLoading.value = true;
      await _authService.signOut();
      Get.offAllNamed('/login');
      Get.snackbar('Success', 'Signed out successfully');
    } catch (e) {
      Get.snackbar('Error', _handleError(e));
    } finally {
      isLoading.value = false;
    }
  }
}