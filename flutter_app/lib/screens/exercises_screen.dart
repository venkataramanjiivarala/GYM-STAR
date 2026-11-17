import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/services/api_service.dart';
import '../models/exercise_model.dart';
import '../widgets/workout_card.dart';
import 'exercise_detail_screen.dart';

class ExercisesScreen extends StatefulWidget {
  final Function(String exerciseKey, bool isYoga) onStartCamera;

  const ExercisesScreen({
    super.key,
    required this.onStartCamera,
  });

  @override
  State<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends State<ExercisesScreen> {
  List<Exercise> _allExercises = [];
  bool _isLoading = true;

  // Filters
  String _selectedCategory = 'All';
  String _selectedDifficulty = 'All';
  String _selectedEquipment = 'All';
  String _activeTab = 'All'; // 'All', 'Favorites', 'AI Monitored', 'Recommended'
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // Favorites tracking
  final Set<String> _favoriteKeys = {
    'preacher_curl',
    'squat',
    'pushup',
    'standing_dumbbell_curl',
    'barbell_bench_press',
  };

  final List<String> _categories = [
    'All',
    'Chest',
    'Back',
    'Shoulders',
    'Biceps',
    'Triceps',
    'Forearms',
    'Legs',
    'Abs and Core',
    'Glutes',
    'Full Body',
    'Cardio',
  ];

  final List<String> _equipments = [
    'All',
    'Barbell',
    'Dumbbell',
    'Bodyweight',
    'Cable',
    'Machine',
  ];

  final List<String> _difficulties = [
    'All',
    'Beginner',
    'Intermediate',
    'Advanced',
  ];

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadExercises() async {
    setState(() => _isLoading = true);
    final list = await ApiService().fetchExercises();
    if (mounted) {
      setState(() {
        _allExercises = list.isNotEmpty ? list : Exercise.fallbackExercises;
        _isLoading = false;
      });
    }
  }

  void _onCategorySelected(String cat) {
    setState(() => _selectedCategory = cat);
  }

  void _onEquipmentSelected(String eq) {
    setState(() => _selectedEquipment = eq);
  }

  void _onDifficultySelected(String diff) {
    setState(() => _selectedDifficulty = diff);
  }

  void _onSearchChanged(String query) {
    setState(() => _searchQuery = query);
  }

  void _toggleFavorite(String key) {
    setState(() {
      if (_favoriteKeys.contains(key)) {
        _favoriteKeys.remove(key);
      } else {
        _favoriteKeys.add(key);
      }
    });
  }

  void _navigateToDetail(Exercise ex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => ExerciseDetailScreen(
          exercise: ex,
          initialIsFavorite: _favoriteKeys.contains(ex.key),
          onFavoriteChanged: (isFav) {
            setState(() {
              if (isFav) {
                _favoriteKeys.add(ex.key);
              } else {
                _favoriteKeys.remove(ex.key);
              }
            });
          },
          onStartWorkout: () {
            Navigator.of(ctx).pop();
            widget.onStartCamera(ex.key, false);
          },
        ),
      ),
    );
  }

  int _getCategoryCount(String cat) {
    if (cat == 'All') return _allExercises.length;
    return _allExercises.where((e) => e.category.toLowerCase() == cat.toLowerCase()).length;
  }

  List<Exercise> _getFilteredExercises() {
    return _allExercises.where((e) {
      // 1. Tab filter
      if (_activeTab == 'Favorites' && !_favoriteKeys.contains(e.key)) {
        return false;
      }
      if (_activeTab == 'AI Monitored' && !e.isAiSupported) {
        return false;
      }
      if (_activeTab == 'Recommended' &&
          !(e.key == 'squat' ||
              e.key == 'pushup' ||
              e.key == 'preacher_curl' ||
              e.key == 'lateral_raise' ||
              e.key == 'standing_dumbbell_curl')) {
        return false;
      }

      // 2. Category filter
      if (_selectedCategory != 'All' &&
          e.category.toLowerCase() != _selectedCategory.toLowerCase()) {
        return false;
      }

      // 3. Equipment filter
      if (_selectedEquipment != 'All' &&
          !e.equipment.toLowerCase().contains(_selectedEquipment.toLowerCase())) {
        return false;
      }

      // 4. Difficulty filter
      if (_selectedDifficulty != 'All' &&
          e.difficulty.toLowerCase() != _selectedDifficulty.toLowerCase()) {
        return false;
      }

      // 5. Search query
      if (_searchQuery.trim().isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchesName = e.name.toLowerCase().contains(q);
        final matchesCategory = e.category.toLowerCase().contains(q);
        final matchesTarget = e.targetMuscles.toLowerCase().contains(q);
        final matchesEquip = e.equipment.toLowerCase().contains(q);
        if (!matchesName && !matchesCategory && !matchesTarget && !matchesEquip) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final displayedExercises = _getFilteredExercises();

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.fitness_center_rounded, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            const Text(
              'Exercise Library',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
                fontSize: 18,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.surfaceDark,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Top Search & Multi-Filter Control Console
          Container(
            color: AppColors.surfaceDark,
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
            child: Column(
              children: [
                // 1. Search Bar
                TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  style: const TextStyle(color: Colors.white, fontSize: 13.5),
                  decoration: InputDecoration(
                    hintText: 'Search Preacher Curl, Squat, Bench Press, Lats...',
                    hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 12.5),
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, color: AppColors.textSecondary, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              _onSearchChanged('');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: AppColors.bgDark,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.borderDark),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.borderDark),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // 2. High-Level Filter Tabs (All, Favorites, AI Monitored, Recommended)
                Row(
                  children: [
                    _tabButton('All', 'All (${_allExercises.length})', Icons.grid_view_rounded),
                    const SizedBox(width: 8),
                    _tabButton('AI Monitored', 'AI Vision 🤖', Icons.videocam_rounded),
                    const SizedBox(width: 8),
                    _tabButton('Favorites', 'Favorites ⭐', Icons.star_rounded),
                  ],
                ),
                const SizedBox(height: 10),

                // 3. Category Horizontal Scroll with Count Badges
                SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (ctx, idx) {
                      final cat = _categories[idx];
                      final isSelected = _selectedCategory == cat;
                      final count = _getCategoryCount(cat);
                      return ChoiceChip(
                        label: Text('$cat ($count)'),
                        selected: isSelected,
                        onSelected: (_) => _onCategorySelected(cat),
                        labelStyle: TextStyle(
                          fontSize: 11.5,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                          color: isSelected ? Colors.white : AppColors.textSecondary,
                        ),
                        backgroundColor: AppColors.bgDark,
                        selectedColor: AppColors.primary,
                        side: BorderSide(
                          color: isSelected ? AppColors.primary : AppColors.borderDark,
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        showCheckmark: false,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),

                // 4. Equipment & Difficulty Filter Row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Equipment Pills
                      const Text(
                        'Apparatus: ',
                        style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.textMuted),
                      ),
                      ..._equipments.map((eq) {
                        final isSelected = _selectedEquipment == eq;
                        return Padding(
                          padding: const EdgeInsets.only(right: 6.0),
                          child: InkWell(
                            onTap: () => _onEquipmentSelected(eq),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary.withValues(alpha: 0.25)
                                    : AppColors.bgDark,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected ? AppColors.primary : AppColors.borderDark,
                                ),
                              ),
                              child: Text(
                                eq,
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                                  color: isSelected ? Colors.white : AppColors.textMuted,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                      const SizedBox(width: 8),

                      // Difficulty Pills
                      const Text(
                        'Level: ',
                        style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.textMuted),
                      ),
                      ..._difficulties.map((diff) {
                        final isSelected = _selectedDifficulty == diff;
                        return Padding(
                          padding: const EdgeInsets.only(right: 6.0),
                          child: InkWell(
                            onTap: () => _onDifficultySelected(diff),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.violet.withValues(alpha: 0.25)
                                    : AppColors.bgDark,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected ? AppColors.violet : AppColors.borderDark,
                                ),
                              ),
                              child: Text(
                                diff,
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                                  color: isSelected ? AppColors.violet : AppColors.textMuted,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Exercise List View
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : displayedExercises.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.fitness_center_outlined, size: 54, color: AppColors.textMuted),
                            const SizedBox(height: 12),
                            const Text(
                              'No exercises match your filter',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Try clearing your search query or selecting "All"',
                              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 14),
                            TextButton(
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _selectedCategory = 'All';
                                  _selectedDifficulty = 'All';
                                  _selectedEquipment = 'All';
                                  _activeTab = 'All';
                                  _searchQuery = '';
                                });
                              },
                              child: const Text('Reset All Filters', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 100),
                        itemCount: displayedExercises.length,
                        itemBuilder: (ctx, idx) {
                          final ex = displayedExercises[idx];
                          final isFav = _favoriteKeys.contains(ex.key);
                          return WorkoutCard(
                            exerciseKey: ex.key,
                            title: ex.name,
                            category: ex.category,
                            primaryMuscles: ex.primaryMuscles,
                            secondaryMuscles: ex.secondaryMuscles,
                            difficulty: ex.difficulty,
                            equipment: ex.equipment,
                            setsAndReps: '${ex.recommendedSets} • ${ex.recommendedReps}',
                            description: ex.description,
                            imageUrl: ex.imageUrl,
                            isAiSupported: ex.isAiSupported,
                            isFavorite: isFav,
                            onToggleFavorite: () => _toggleFavorite(ex.key),
                            onViewDetails: () => _navigateToDetail(ex),
                            onStartWorkout: () => widget.onStartCamera(ex.key, false),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _tabButton(String key, String title, IconData icon) {
    final isSelected = _activeTab == key;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _activeTab = key),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? AppColors.primary : AppColors.borderDark),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 13, color: isSelected ? Colors.white : AppColors.textMuted),
              const SizedBox(width: 5),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
