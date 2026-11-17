import 'package:flutter/material.dart';
import 'core/constants/app_colors.dart';
import 'core/services/api_service.dart';
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
          secondary: AppColors.violet,
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

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prof = await ApiService().fetchUserProfile();
    if (mounted) {
      setState(() => _userProfile = prof);
    }
  }

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
      builder: (ctx) => AiCoachChatModal(
        userName: _userProfile.name,
        profile: _userProfile,
      ),
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
    // Preserve tab state using IndexedStack for tabs 0, 1, 3, 4,
    // while CameraCoachScreen dynamically renders for tab 2
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
      backgroundColor: AppColors.bgDark,
      body: screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.borderDark, width: 1),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
          backgroundColor: AppColors.surfaceDark,
          indicatorColor: AppColors.primary.withValues(alpha: 0.22),
          elevation: 8,
          height: 68,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded, color: AppColors.primary),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.fitness_center_outlined),
              selectedIcon: Icon(Icons.fitness_center_rounded, color: AppColors.primary),
              label: 'Workouts',
            ),
            NavigationDestination(
              icon: Icon(Icons.videocam_outlined),
              selectedIcon: Icon(Icons.videocam_rounded, color: AppColors.accentNeon),
              label: 'AI Coach',
            ),
            NavigationDestination(
              icon: Icon(Icons.self_improvement_outlined),
              selectedIcon: Icon(Icons.self_improvement_rounded, color: AppColors.violet),
              label: 'Yoga',
            ),
            NavigationDestination(
              icon: Icon(Icons.insights_outlined),
              selectedIcon: Icon(Icons.insights_rounded, color: AppColors.primary),
              label: 'Progress',
            ),
          ],
        ),
      ),
    );
  }
}
