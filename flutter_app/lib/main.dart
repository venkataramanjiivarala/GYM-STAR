import 'package:flutter/material.dart';
import 'core/constants/app_colors.dart';
import 'models/user_profile_model.dart';
import 'screens/home_screen.dart';
import 'screens/exercises_screen.dart';
import 'screens/camera_coach_screen.dart';
import 'screens/yoga_studio_screen.dart';
import 'screens/progress_analytics_screen.dart';
import 'widgets/ai_coach_chat_modal.dart';
import 'widgets/profile_plan_modal.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const GymStarApp());
}

class GymStarApp extends StatelessWidget {
  const GymStarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GYM STAR',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.bgDark,
        primaryColor: AppColors.primary,
        useMaterial3: true,
        fontFamily: 'Inter',
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          surface: AppColors.surfaceDark,
        ),
      ),
      home: const MainNavigationWrapper(),
    );
  }
}

class MainNavigationWrapper extends StatefulWidget {
  const MainNavigationWrapper({super.key});

  @override
  State<MainNavigationWrapper> createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper> {
  int _currentIndex = 0;
  UserProfile _userProfile = UserProfile();

  // Active workout parameters when navigating to camera
  String _activeExerciseKey = 'squat';
  bool _isActiveYoga = false;

  void _startCameraCoach(String exerciseKey, bool isYoga) {
    setState(() {
      _activeExerciseKey = exerciseKey;
      _isActiveYoga = isYoga;
      _currentIndex = 2; // AI Coach tab
    });
  }

  void _openCoachChat() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AiCoachChatModal(userName: _userProfile.name),
    );
  }

  void _openProfileModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ProfilePlanModal(
        profile: _userProfile,
        onProfileUpdated: (updated) {
          setState(() => _userProfile = updated);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      HomeScreen(
        profile: _userProfile,
        onStartCamera: _startCameraCoach,
        onOpenCoachChat: _openCoachChat,
        onOpenProfile: _openProfileModal,
      ),
      ExercisesScreen(
        onStartCamera: _startCameraCoach,
      ),
      CameraCoachScreen(
        key: ValueKey('$_activeExerciseKey-$_isActiveYoga'),
        initialExerciseKey: _activeExerciseKey,
        isYoga: _isActiveYoga,
        onWorkoutCompleted: () {
          setState(() => _currentIndex = 0); // Return to home tab
        },
      ),
      YogaStudioScreen(
        onStartPractice: _startCameraCoach,
      ),
      const ProgressAnalyticsScreen(),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
        backgroundColor: AppColors.surfaceDark,
        indicatorColor: AppColors.primary.withValues(alpha: 0.2),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: AppColors.primary),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.fitness_center_outlined),
            selectedIcon: Icon(Icons.fitness_center, color: AppColors.primary),
            label: 'Workouts',
          ),
          NavigationDestination(
            icon: Icon(Icons.camera_front_outlined),
            selectedIcon: Icon(Icons.camera_front, color: AppColors.accentNeon),
            label: 'AI Coach',
          ),
          NavigationDestination(
            icon: Icon(Icons.self_improvement_outlined),
            selectedIcon: Icon(Icons.self_improvement, color: AppColors.primary),
            label: 'Yoga',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights, color: AppColors.primary),
            label: 'Progress',
          ),
        ],
      ),
    );
  }
}
