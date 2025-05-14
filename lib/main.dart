import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fitness/features/chat/views/chat_list_screen.dart';
import 'package:fitness/features/chat/views/chat_screen.dart';
import 'package:fitness/features/plans/views/plan_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'features/auth/services/auth_service.dart';
import 'features/auth/views/login_screen.dart';
import 'features/auth/views/signup_screen.dart';
import 'features/profile/views/profile_setup_screen.dart';
import 'features/profile/views/profile_view_edit_screen.dart';
import 'features/dashboard/views/student_home_screen.dart';
import 'features/dashboard/views/coach_home_screen.dart';
import 'features/coach_discovery/views/coach_discovery_screen.dart';
import 'features/coach_discovery/views/connection_management_screen.dart';
import 'features/plans/views/create_plan_screen.dart';
import 'features/plans/views/plans_screen.dart';
import 'features/dashboard/views/my_students_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<String> _getInitialRoute() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final authService = AuthService();
        final userData = await authService.getUser(user.uid);
        if (userData != null) {
          if (userData.role == 'student') {
            final profile =
                await FirebaseFirestore.instance
                    .collection('student_profiles')
                    .doc(user.uid)
                    .get();
            if (profile.exists) return '/student-home';
            return '/profile-setup';
          } else if (userData.role == 'coach') {
            final profile =
                await FirebaseFirestore.instance
                    .collection('coach_profiles')
                    .doc(user.uid)
                    .get();
            if (profile.exists) return '/coach-home';
            return '/profile-setup';
          }
        }
      }
      return '/login';
    } catch (e) {
      print('Error determining initial route: $e');
      return '/login';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _getInitialRoute(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }

        final initialRoute = snapshot.data ?? '/login';

        return GetMaterialApp(
          title: 'Fitness Coaching App',
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            scaffoldBackgroundColor:
                Colors.transparent, // transparent so bg shows
            primaryColor: Colors.white,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white, // Navy blue text/icons
            ),
            textTheme: const TextTheme(
              headlineSmall: TextStyle(
                color: Color.fromARGB(255, 231, 231, 231),
                fontWeight: FontWeight.bold,
              ),
              titleLarge: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
              bodyMedium: TextStyle(color: Colors.white),
              bodySmall: TextStyle(color: Colors.white),
            ),
            buttonTheme: const ButtonThemeData(
              textTheme: ButtonTextTheme.primary,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                foregroundColor: const Color.fromARGB(
                  255,
                  244,
                  245,
                  246,
                ), // Navy blue text
                backgroundColor: const Color(
                  0xFF2C3E50,
                ), // Dark button background
              ),
            ),
            cardTheme: const CardTheme(
              color: Color(0xFF1C2526), // Dark card background
            ),
          ),
          initialRoute: initialRoute,

          /// 👇 This wraps all screens globally with your background
          builder: (context, child) {
            return Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/fitness_bg.jpeg',
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.6), // Optional overlay
                  ),
                ),
                child ?? const SizedBox.shrink(),
              ],
            );
          },
          getPages: [
            GetPage(name: '/login', page: () => const LoginScreen()),
            GetPage(name: '/signup', page: () => const SignUpScreen()),
            GetPage(
              name: '/profile-setup',
              page: () => const ProfileSetupScreen(),
            ),
            GetPage(
              name: '/profile-view-edit',
              page: () => const ProfileViewEditScreen(),
            ),
            GetPage(
              name: '/student-home',
              page: () => const StudentHomeScreen(),
            ),
            GetPage(name: '/coach-home', page: () => const CoachHomeScreen()),
            GetPage(
              name: '/find-coach',
              page: () => const CoachDiscoveryScreen(),
            ),
            GetPage(
              name: '/manage-connections',
              page: () => const ConnectionManagementScreen(),
            ),
            GetPage(name: '/plans', page: () => const PlansScreen()),
            GetPage(name: '/my-students', page: () => const MyStudentsScreen()),
            GetPage(name: '/create-plan', page: () => const CreatePlanScreen()),
            GetPage(name: '/chat-list', page: () => const ChatListScreen()),
            GetPage(name: '/chat', page: () => const ChatScreen()),
                   GetPage(name: '/plan-details', page: () => const PlanDetailsScreen()),
   ],
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
          getPages: [
            GetPage(name: '/login', page: () => const LoginScreen()),
            GetPage(name: '/signup', page: () => const SignUpScreen()),
            GetPage(
              name: '/profile-setup',
              page: () => const ProfileSetupScreen(),
            ),
            GetPage(
              name: '/profile-view-edit',
              page: () => const ProfileViewEditScreen(),
            ),
            GetPage(
              name: '/student-home',
              page: () => const StudentHomeScreen(),
            ),
            GetPage(name: '/coach-home', page: () => const CoachHomeScreen()),
            GetPage(
              name: '/find-coach',
              page: () => const CoachDiscoveryScreen(),
            ),
            GetPage(
              name: '/manage-connections',
              page: () => const ConnectionManagementScreen(),
            ),
            GetPage(name: '/plans', page: () => const PlansScreen()),
            GetPage(name: '/my-students', page: () => const MyStudentsScreen()),
            GetPage(name: '/create-plan', page: () => const CreatePlanScreen()),
            GetPage(name: '/chat-list', page: () => const ChatListScreen()),
            GetPage(name: '/chat', page: () => const ChatScreen()),
                   GetPage(name: '/plan-details', page: () => const PlanDetailsScreen()),
   ],
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
