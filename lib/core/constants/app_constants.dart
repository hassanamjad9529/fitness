class AppConstants {
  static const String usersCollection = 'users';
  static const String studentProfilesCollection = 'student_profiles';
  static const String coachProfilesCollection = 'coach_profiles';
  static const String connectionsCollection = 'connections';
  static const String plansCollection = 'plans';
  static const String roleCoach = 'coach';
  static const String roleStudent = 'student';
  static const List<String> fitnessGoals = ['Weight Loss', 'Muscle Gain', 'Endurance', 'General Fitness'];
  static const List<String> specializations = ['Weight Loss', 'Strength Training', 'Cardio', 'Nutrition'];
  static const String connectionStatusPending = 'pending';
  static const String connectionStatusAccepted = 'accepted';
  static const String connectionStatusRejected = 'rejected';
  static const String planTypeDiet = 'diet';
  static const String planTypeWorkout = 'workout';
    static String get chatRoomsCollection => 'chat_rooms'; // Added for chat module

  static const List<String> planTypes = [planTypeDiet, planTypeWorkout];
}