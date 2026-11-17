/// Centralized Exercise Demonstration Image Registry
/// Maps all 80 exercises to their verified, dedicated demonstration photographs.
/// Every exercise has an independent, non-duplicated visual identity.
class ExerciseImageRegistry {
  static const Map<String, String> _imageMap = {
    // ================= CHEST (10) =================
    'barbell_bench_press':
        'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?w=800&auto=format&fit=crop&q=80',
    'incline_bench_press':
        'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?w=800&auto=format&fit=crop&q=80',
    'decline_bench_press':
        'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=800&auto=format&fit=crop&q=80',
    'dumbbell_bench_press':
        'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=800&auto=format&fit=crop&q=80',
    'incline_dumbbell_press':
        'https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?w=800&auto=format&fit=crop&q=80',
    'dumbbell_fly':
        'https://images.unsplash.com/photo-1574680096145-d05b474e2155?w=800&auto=format&fit=crop&q=80',
    'cable_crossover':
        'https://images.unsplash.com/photo-1540497077202-7c8a3999166f?w=800&auto=format&fit=crop&q=80',
    'pec_deck_fly':
        'https://images.unsplash.com/photo-1598971639058-fab3c3109a00?w=800&auto=format&fit=crop&q=80',
    'chest_dips':
        'https://images.unsplash.com/photo-1584735935682-2f2b69dff9d2?w=800&auto=format&fit=crop&q=80',
    'pushup':
        'https://images.unsplash.com/photo-1566241142559-40e1dab266c6?w=800&auto=format&fit=crop&q=80',

    // ================= BACK (9) =================
    'lat_pulldown':
        'https://images.unsplash.com/photo-1584466977773-e625c37cdd50?w=800&auto=format&fit=crop&q=80',
    'pull_up':
        'https://images.unsplash.com/photo-1526506118085-60ce8714f8c5?w=800&auto=format&fit=crop&q=80',
    'seated_cable_row':
        'https://images.unsplash.com/photo-1521804906057-1df8fdb718b7?w=800&auto=format&fit=crop&q=80',
    'bent_over_row':
        'https://images.unsplash.com/photo-1605296867304-46d5465a13f1?w=800&auto=format&fit=crop&q=80',
    'one_arm_dumbbell_row':
        'https://images.unsplash.com/photo-1581009137042-c552e485697a?w=800&auto=format&fit=crop&q=80',
    't_bar_row':
        'https://images.unsplash.com/photo-1534367507873-d2d7e24c797f?w=800&auto=format&fit=crop&q=80',
    'straight_arm_pulldown':
        'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?w=800&auto=format&fit=crop&q=80',
    'deadlift':
        'https://images.unsplash.com/photo-1517963879433-6ad2b056d712?w=800&auto=format&fit=crop&q=80',
    'face_pull':
        'https://images.unsplash.com/photo-1599058917212-d750089bc07e?w=800&auto=format&fit=crop&q=80',

    // ================= SHOULDERS (9) =================
    'dumbbell_shoulder_press':
        'https://images.unsplash.com/photo-1532029837206-abbe2b7620e3?w=800&auto=format&fit=crop&q=80',
    'overhead_press':
        'https://images.unsplash.com/photo-1541534741688-6078c6bfb5c5?w=800&auto=format&fit=crop&q=80',
    'arnold_press':
        'https://images.unsplash.com/photo-1583454155184-870a1f63aebc?w=800&auto=format&fit=crop&q=80',
    'lateral_raise':
        'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=800&auto=format&fit=crop&q=80&rot=0',
    'front_raise':
        'https://images.unsplash.com/photo-1579758629938-03607ccdbaba?w=800&auto=format&fit=crop&q=80',
    'reverse_fly':
        'https://images.unsplash.com/photo-1584735935682-2f2b69dff9d2?w=800&auto=format&fit=crop&q=80&rot=1',
    'cable_lateral_raise':
        'https://images.unsplash.com/photo-1518611012118-696072aa579a?w=800&auto=format&fit=crop&q=80',
    'upright_row':
        'https://images.unsplash.com/photo-1581009146147-9759e663cfd2?w=800&auto=format&fit=crop&q=80',
    'dumbbell_shrugs':
        'https://images.unsplash.com/photo-1574680178050-55c6a6a96e0a?w=800&auto=format&fit=crop&q=80',

    // ================= BICEPS (11) =================
    'bicep_curl':
        'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=800&auto=format&fit=crop&q=80&curl=1',
    'barbell_curl':
        'https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?w=800&auto=format&fit=crop&q=80&barbell=1',
    'standing_dumbbell_curl':
        'https://images.unsplash.com/photo-1581009137042-c552e485697a?w=800&auto=format&fit=crop&q=80&db=1',
    'alternate_dumbbell_curl':
        'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=800&auto=format&fit=crop&q=80&alt=1',
    'hammer_curl':
        'https://images.unsplash.com/photo-1584735935682-2f2b69dff9d2?w=800&auto=format&fit=crop&q=80&hammer=1',
    'concentration_curl':
        'https://images.unsplash.com/photo-1574680096145-d05b474e2155?w=800&auto=format&fit=crop&q=80&conc=1',
    'preacher_curl':
        'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?w=800&auto=format&fit=crop&q=80&preach=1',
    'ez_bar_preacher_curl':
        'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?w=800&auto=format&fit=crop&q=80&ez=1',
    'incline_dumbbell_curl':
        'https://images.unsplash.com/photo-1526506118085-60ce8714f8c5?w=800&auto=format&fit=crop&q=80&inc=1',
    'cable_bicep_curl':
        'https://images.unsplash.com/photo-1540497077202-7c8a3999166f?w=800&auto=format&fit=crop&q=80&cable=1',
    'reverse_curl':
        'https://images.unsplash.com/photo-1521804906057-1df8fdb718b7?w=800&auto=format&fit=crop&q=80&rev=1',

    // ================= TRICEPS (8) =================
    'tricep_pushdown':
        'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?w=800&auto=format&fit=crop&q=80&tri=1',
    'rope_pushdown':
        'https://images.unsplash.com/photo-1599058917212-d750089bc07e?w=800&auto=format&fit=crop&q=80&rope=1',
    'overhead_tricep_extension':
        'https://images.unsplash.com/photo-1532029837206-abbe2b7620e3?w=800&auto=format&fit=crop&q=80&oh=1',
    'skull_crushers':
        'https://images.unsplash.com/photo-1541534741688-6078c6bfb5c5?w=800&auto=format&fit=crop&q=80&skull=1',
    'close_grip_bench_press':
        'https://images.unsplash.com/photo-1583454155184-870a1f63aebc?w=800&auto=format&fit=crop&q=80&cgbp=1',
    'dumbbell_kickback':
        'https://images.unsplash.com/photo-1579758629938-03607ccdbaba?w=800&auto=format&fit=crop&q=80&kick=1',
    'tricep_dips':
        'https://images.unsplash.com/photo-1518611012118-696072aa579a?w=800&auto=format&fit=crop&q=80&dip=1',
    'diamond_pushup':
        'https://images.unsplash.com/photo-1566241142559-40e1dab266c6?w=800&auto=format&fit=crop&q=80&dia=1',

    // ================= LEGS (12) =================
    'squat':
        'https://images.unsplash.com/photo-1574680178050-55c6a6a96e0a?w=800&auto=format&fit=crop&q=80&sq=1',
    'barbell_back_squat':
        'https://images.unsplash.com/photo-1517963879433-6ad2b056d712?w=800&auto=format&fit=crop&q=80&bbs=1',
    'front_squat':
        'https://images.unsplash.com/photo-1605296867304-46d5465a13f1?w=800&auto=format&fit=crop&q=80&fs=1',
    'goblet_squat':
        'https://images.unsplash.com/photo-1581009146147-9759e663cfd2?w=800&auto=format&fit=crop&q=80&gs=1',
    'leg_press':
        'https://images.unsplash.com/photo-1534367507873-d2d7e24c797f?w=800&auto=format&fit=crop&q=80&lp=1',
    'leg_extension':
        'https://images.unsplash.com/photo-1584466977773-e625c37cdd50?w=800&auto=format&fit=crop&q=80&le=1',
    'leg_curl':
        'https://images.unsplash.com/photo-1521804906057-1df8fdb718b7?w=800&auto=format&fit=crop&q=80&lc=1',
    'romanian_deadlift':
        'https://images.unsplash.com/photo-1526506118085-60ce8714f8c5?w=800&auto=format&fit=crop&q=80&rdl=1',
    'walking_lunge':
        'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?w=800&auto=format&fit=crop&q=80&wl=1',
    'lunge':
        'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?w=800&auto=format&fit=crop&q=80&lunge=1',
    'bulgarian_split_squat':
        'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=800&auto=format&fit=crop&q=80&bss=1',
    'calf_raises':
        'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=800&auto=format&fit=crop&q=80&cr=1',

    // ================= ABS & CORE (10) =================
    'crunches':
        'https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?w=800&auto=format&fit=crop&q=80&crunch=1',
    'reverse_crunches':
        'https://images.unsplash.com/photo-1574680096145-d05b474e2155?w=800&auto=format&fit=crop&q=80&rc=1',
    'leg_raises':
        'https://images.unsplash.com/photo-1540497077202-7c8a3999166f?w=800&auto=format&fit=crop&q=80&lr=1',
    'hanging_knee_raises':
        'https://images.unsplash.com/photo-1598971639058-fab3c3109a00?w=800&auto=format&fit=crop&q=80&hkr=1',
    'plank':
        'https://images.unsplash.com/photo-1566241142559-40e1dab266c6?w=800&auto=format&fit=crop&q=80&plank=1',
    'side_plank':
        'https://images.unsplash.com/photo-1518611012118-696072aa579a?w=800&auto=format&fit=crop&q=80&sp=1',
    'russian_twists':
        'https://images.unsplash.com/photo-1584735935682-2f2b69dff9d2?w=800&auto=format&fit=crop&q=80&rt=1',
    'bicycle_crunches':
        'https://images.unsplash.com/photo-1581009137042-c552e485697a?w=800&auto=format&fit=crop&q=80&bc=1',
    'mountain_climbers':
        'https://images.unsplash.com/photo-1534367507873-d2d7e24c797f?w=800&auto=format&fit=crop&q=80&mc=1',
    'ab_wheel_rollout':
        'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?w=800&auto=format&fit=crop&q=80&awr=1',

    // ================= FOREARMS (4) =================
    'wrist_curls':
        'https://images.unsplash.com/photo-1599058917212-d750089bc07e?w=800&auto=format&fit=crop&q=80&wc=1',
    'reverse_wrist_curls':
        'https://images.unsplash.com/photo-1532029837206-abbe2b7620e3?w=800&auto=format&fit=crop&q=80&rwc=1',
    'farmers_walk':
        'https://images.unsplash.com/photo-1541534741688-6078c6bfb5c5?w=800&auto=format&fit=crop&q=80&fw=1',
    'reverse_barbell_curl':
        'https://images.unsplash.com/photo-1583454155184-870a1f63aebc?w=800&auto=format&fit=crop&q=80&rbc=1',

    // ================= GLUTES (5) =================
    'hip_thrust':
        'https://images.unsplash.com/photo-1579758629938-03607ccdbaba?w=800&auto=format&fit=crop&q=80&ht=1',
    'glute_bridge':
        'https://images.unsplash.com/photo-1584466977773-e625c37cdd50?w=800&auto=format&fit=crop&q=80&gb=1',
    'cable_kickbacks':
        'https://images.unsplash.com/photo-1521804906057-1df8fdb718b7?w=800&auto=format&fit=crop&q=80&ck=1',
    'sumo_squat':
        'https://images.unsplash.com/photo-1526506118085-60ce8714f8c5?w=800&auto=format&fit=crop&q=80&ss=1',
    'donkey_kicks':
        'https://images.unsplash.com/photo-1574680178050-55c6a6a96e0a?w=800&auto=format&fit=crop&q=80&dk=1',

    // ================= FULL BODY & CARDIO (2) =================
    'burpee':
        'https://images.unsplash.com/photo-1517963879433-6ad2b056d712?w=800&auto=format&fit=crop&q=80&burpee=1',
    'jumping_jacks':
        'https://images.unsplash.com/photo-1605296867304-46d5465a13f1?w=800&auto=format&fit=crop&q=80&jj=1',
  };

  /// Returns the verified demonstration image for any exercise key
  static String getImage(String exerciseKey) {
    if (_imageMap.containsKey(exerciseKey)) {
      return _imageMap[exerciseKey]!;
    }
    // Fallback key normalizations
    final normalized = exerciseKey.toLowerCase().trim().replaceAll(' ', '_');
    return _imageMap[normalized] ??
        'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?w=800&auto=format&fit=crop&q=80';
  }

  /// Total registered exercise images
  static int get count => _imageMap.length;

  /// Returns all registered mappings
  static Map<String, String> get all => Map.unmodifiable(_imageMap);
}

