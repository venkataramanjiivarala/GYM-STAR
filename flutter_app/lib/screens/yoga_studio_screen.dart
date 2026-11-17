import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/services/api_service.dart';
import '../models/yoga_pose_model.dart';
import '../widgets/yoga_detail_sheet.dart';

class YogaStudioScreen extends StatefulWidget {
  final Function(String poseKey, bool isYoga) onStartPractice;

  const YogaStudioScreen({
    super.key,
    required this.onStartPractice,
  });

  @override
  State<YogaStudioScreen> createState() => _YogaStudioScreenState();
}

class _YogaStudioScreenState extends State<YogaStudioScreen> with SingleTickerProviderStateMixin {
  List<YogaPose> _poses = [];
  bool _isLoading = true;
  String _selectedCategory = 'All';
  String _selectedDifficulty = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // Guided breathing animation state
  late AnimationController _breathingController;
  late Animation<double> _breathingAnimation;
  String _breathingPhase = 'Inhale';

  final List<String> _categories = [
    'All',
    'Balance & Focus',
    'Flexibility & Energy',
    'Strength & Stamina',
    'Back Flexibility',
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
    _loadPoses();

    // 12s breathing loop: 4s Inhale, 4s Hold, 4s Exhale
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    _breathingAnimation = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    );

    _breathingController.addListener(() {
      final val = _breathingController.value;
      String phase;
      if (val < 0.33) {
        phase = 'Inhale deeply...';
      } else if (val < 0.66) {
        phase = 'Hold breath gently...';
      } else {
        phase = 'Exhale & release...';
      }
      if (phase != _breathingPhase && mounted) {
        setState(() => _breathingPhase = phase);
      }
    });
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPoses() async {
    setState(() => _isLoading = true);
    final list = await ApiService().fetchYogaPoses(
      category: _selectedCategory,
      query: _searchQuery,
    );
    if (mounted) {
      setState(() {
        _poses = list;
        _isLoading = false;
      });
    }
  }

  void _onCategorySelected(String cat) {
    setState(() => _selectedCategory = cat);
    _loadPoses();
  }

  void _onDifficultySelected(String diff) {
    setState(() => _selectedDifficulty = diff);
  }

  void _onSearchChanged(String query) {
    setState(() => _searchQuery = query);
    _loadPoses();
  }

  void _openPoseDetail(YogaPose pose) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => YogaDetailSheet(
        pose: pose,
        onStartPractice: () => widget.onStartPractice(pose.key, true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayedPoses = _selectedDifficulty == 'All'
        ? _poses
        : _poses.where((p) => p.difficulty.toLowerCase() == _selectedDifficulty.toLowerCase()).toList();

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: const Text(
          'Yoga & Stability Studio',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5, color: AppColors.textPrimary),
        ),
        backgroundColor: AppColors.surfaceDark,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Guided Breathing Bar Widget
          Container(
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 10),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.violet.withValues(alpha: 0.22),
                  AppColors.primary.withValues(alpha: 0.12),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.violet.withValues(alpha: 0.35)),
            ),
            child: Row(
              children: [
                ScaleTransition(
                  scale: _breathingAnimation,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.violetPurpleGradient,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.violet.withValues(alpha: 0.4),
                          blurRadius: 12,
                          spreadRadius: 2,
                        )
                      ],
                    ),
                    child: const Icon(Icons.self_improvement_rounded, color: Colors.white, size: 24),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'GUIDED PRANAYAMA BREATHING',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: AppColors.violet,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _breathingPhase,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    '4-4-4 Cadence',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),

          // Search & Filter Box
          Container(
            color: AppColors.surfaceDark,
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
            child: Column(
              children: [
                // Search Input
                TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Search pose name, Sanskrit (Vrikshasana, Warrior)...',
                    hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
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
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppColors.borderDark),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppColors.borderDark),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppColors.violet, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Category Chips
                SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (ctx, idx) {
                      final cat = _categories[idx];
                      final isSelected = _selectedCategory == cat;
                      return ChoiceChip(
                        label: Text(cat),
                        selected: isSelected,
                        onSelected: (_) => _onCategorySelected(cat),
                        labelStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                          color: isSelected ? Colors.white : AppColors.textSecondary,
                        ),
                        backgroundColor: AppColors.bgDark,
                        selectedColor: AppColors.violet,
                        side: BorderSide(
                          color: isSelected ? AppColors.violet : AppColors.borderDark,
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        showCheckmark: false,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),

                // Difficulty Filter Pills
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      const Text(
                        'Level: ',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMuted),
                      ),
                      const SizedBox(width: 4),
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
                                    ? AppColors.violet.withValues(alpha: 0.22)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected ? AppColors.violet : Colors.transparent,
                                ),
                              ),
                              child: Text(
                                diff,
                                style: TextStyle(
                                  fontSize: 11,
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

          // Poses List
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.violet),
                  )
                : displayedPoses.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.self_improvement_outlined, size: 54, color: AppColors.textMuted),
                            SizedBox(height: 12),
                            Text(
                              'No yoga poses found',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Try resetting filters to discover restorative flows',
                              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                        itemCount: displayedPoses.length,
                        itemBuilder: (ctx, idx) {
                          final pose = displayedPoses[idx];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceDark,
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(color: AppColors.borderDark),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.25),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(22),
                                onTap: () => _openPoseDetail(pose),
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      // Pose icon
                                      Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          gradient: AppColors.violetPurpleGradient,
                                          borderRadius: BorderRadius.circular(14),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.violet.withValues(alpha: 0.3),
                                              blurRadius: 8,
                                              offset: const Offset(0, 3),
                                            )
                                          ],
                                        ),
                                        child: const Icon(Icons.self_improvement_rounded, color: Colors.white, size: 24),
                                      ),
                                      const SizedBox(width: 12),
                                      // Text block — takes all remaining space before button
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            // Category badge + hold text in a constrained row
                                            Row(
                                              children: [
                                                Flexible(
                                                  child: Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: AppColors.violet.withValues(alpha: 0.16),
                                                      borderRadius: BorderRadius.circular(7),
                                                    ),
                                                    child: Text(
                                                      pose.category,
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                        fontSize: 9.5,
                                                        fontWeight: FontWeight.w700,
                                                        color: AppColors.violet,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  '${pose.holdDurationSec}s Hold',
                                                  style: const TextStyle(
                                                    fontSize: 10.5,
                                                    fontWeight: FontWeight.w600,
                                                    color: AppColors.textMuted,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 5),
                                            Text(
                                              pose.name,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.textPrimary,
                                              ),
                                            ),
                                            if (pose.sanskritName.isNotEmpty) ...[
                                              const SizedBox(height: 2),
                                              Text(
                                                pose.sanskritName,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  fontStyle: FontStyle.italic,
                                                  color: AppColors.textSecondary,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      // Flow button — fixed width so it never pushes siblings
                                      SizedBox(
                                        width: 68,
                                        child: ElevatedButton(
                                          onPressed: () => widget.onStartPractice(pose.key, true),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.violet.withValues(alpha: 0.15),
                                            foregroundColor: AppColors.violet,
                                            elevation: 0,
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(14),
                                              side: BorderSide(color: AppColors.violet.withValues(alpha: 0.35)),
                                            ),
                                          ),
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.play_arrow_rounded, size: 16),
                                              SizedBox(width: 2),
                                              Text('Flow', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
