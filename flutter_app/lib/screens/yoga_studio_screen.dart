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

class _YogaStudioScreenState extends State<YogaStudioScreen> {
  List<YogaPose> _poses = [];
  bool _isLoading = true;
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = [
    'All',
    'Balance & Focus',
    'Strength & Stamina',
    'Flexibility & Energy',
    'Back Flexibility',
  ];

  @override
  void initState() {
    super.initState();
    _loadPoses();
  }

  void _loadPoses() async {
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('🧘 Yoga & Stability Studio', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.surfaceDark,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search & Filter Box
          Container(
            color: AppColors.surfaceDark,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Search Tree Pose, Warrior, Vrikshasana...',
                    hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                    prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: AppColors.textSecondary, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              _onSearchChanged('');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: AppColors.bgDark,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 12),

                // Category Chips
                SizedBox(
                  height: 34,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    itemBuilder: (context, idx) {
                      final cat = _categories[idx];
                      final isSelected = _selectedCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(
                            cat,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? Colors.white : AppColors.textSecondary,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: AppColors.primary,
                          backgroundColor: AppColors.bgDark,
                          side: BorderSide(
                            color: isSelected ? AppColors.primary : AppColors.surfaceCard,
                          ),
                          onSelected: (_) => _onCategorySelected(cat),
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
          ),

          // Poses List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : _poses.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.search_off, size: 48, color: AppColors.textMuted),
                            const SizedBox(height: 12),
                            Text('No yoga poses found matching "$_searchQuery"', style: const TextStyle(color: AppColors.textSecondary)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _poses.length,
                        itemBuilder: (context, idx) {
                          final pose = _poses[idx];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceDark,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: AppColors.surfaceCard),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              leading: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.self_improvement, color: AppColors.primary, size: 22),
                              ),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      pose.name,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceCard,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '${pose.holdDurationSec}s Hold',
                                      style: const TextStyle(fontSize: 10, color: AppColors.accentNeon, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  '${pose.sanskritName} • ${pose.category}',
                                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontStyle: FontStyle.italic),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              trailing: IconButton(
                                icon: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.play_arrow, color: AppColors.primary, size: 20),
                                ),
                                onPressed: () => widget.onStartPractice(pose.key, true),
                              ),
                              onTap: () => _openPoseDetail(pose),
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
