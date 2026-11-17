import '../core/constants/exercise_image_registry.dart';
class Exercise {
  final String key;
  final String name;
  final String category; // Chest, Back, Shoulders, Biceps, Triceps, Legs, Abs and Core, Forearms, Glutes, Full Body, Cardio
  final String difficulty; // Beginner, Intermediate, Advanced
  final String primaryMuscles;
  final String secondaryMuscles;
  final String targetMuscles;
  final String description;
  final List<String> instructions;
  final List<String> commonMistakes;
  final double caloriesPerRep;
  final String equipment;
  final String recommendedSets;
  final String recommendedReps;
  final String estimatedDuration;
  final String executionTechnique;
  final String startingPosition;
  final String breathingTechnique;
  final String safetyInstructions;
  final String imageUrl;
  final bool isAiSupported;
  final Map<String, dynamic>? rulesConfig;

  Exercise({
    required this.key,
    required this.name,
    required this.category,
    required this.difficulty,
    required this.primaryMuscles,
    this.secondaryMuscles = '',
    required this.targetMuscles,
    required this.description,
    required this.instructions,
    required this.commonMistakes,
    required this.caloriesPerRep,
    this.equipment = 'Bodyweight',
    this.recommendedSets = '3 Sets',
    this.recommendedReps = '10-12 Reps',
    this.estimatedDuration = '8-10 min',
    this.executionTechnique = 'Controlled tempo with steady breathing and core engagement.',
    this.startingPosition = 'Maintain neutral spine and engage core muscles.',
    this.breathingTechnique = 'Inhale during the eccentric (lowering) phase, exhale during concentric (drive) phase.',
    this.safetyInstructions = 'Stop immediately if you feel joint pain or sharpness in tendons.',
    this.imageUrl = '',
    this.isAiSupported = false,
    this.rulesConfig,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    final prim = json['primary_muscles'] ?? json['target_muscles'] ?? '';
    final sec = json['secondary_muscles'] ?? '';
    return Exercise(
      key: json['key'] ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? 'General',
      difficulty: json['difficulty'] ?? 'Beginner',
      primaryMuscles: prim,
      secondaryMuscles: sec,
      targetMuscles: json['target_muscles'] ?? prim,
      description: json['description'] ?? '',
      instructions: json['instructions'] != null
          ? List<String>.from(json['instructions'])
          : [],
      commonMistakes: json['common_mistakes'] != null
          ? List<String>.from(json['common_mistakes'])
          : [],
      caloriesPerRep: (json['calories_per_rep'] as num?)?.toDouble() ?? 0.4,
      equipment: json['equipment'] ?? 'Bodyweight',
      recommendedSets: json['recommended_sets'] ?? '3 Sets',
      recommendedReps: json['recommended_reps'] ?? '10-12 Reps',
      estimatedDuration: json['estimated_duration'] ?? '8-10 min',
      executionTechnique: json['execution_technique'] ?? 'Controlled tempo with steady breathing and core engagement.',
      startingPosition: json['starting_position'] ?? 'Maintain neutral spine and engage core muscles.',
      breathingTechnique: json['breathing_technique'] ?? 'Inhale on the eccentric phase, exhale on the concentric phase.',
      safetyInstructions: json['safety_instructions'] ?? 'Stop immediately if you feel joint discomfort.',
      imageUrl: json['image_url'] ?? '',
      isAiSupported: json['is_ai_supported'] ?? _checkIfAiSupported(json['key'] ?? ''),
      rulesConfig: json['rules_config'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'name': name,
      'category': category,
      'difficulty': difficulty,
      'primary_muscles': primaryMuscles,
      'secondary_muscles': secondaryMuscles,
      'target_muscles': targetMuscles,
      'description': description,
      'instructions': instructions,
      'common_mistakes': commonMistakes,
      'calories_per_rep': caloriesPerRep,
      'equipment': equipment,
      'recommended_sets': recommendedSets,
      'recommended_reps': recommendedReps,
      'estimated_duration': estimatedDuration,
      'execution_technique': executionTechnique,
      'starting_position': startingPosition,
      'breathing_technique': breathingTechnique,
      'safety_instructions': safetyInstructions,
      'image_url': imageUrl,
      'is_ai_supported': isAiSupported,
      'rules_config': rulesConfig,
    };
  }

  static bool _checkIfAiSupported(String key) {
    const aiKeys = {
      'squat', 'barbell_back_squat', 'goblet_squat',
      'pushup', 'diamond_pushup',
      'bicep_curl', 'standing_dumbbell_curl', 'barbell_curl', 'preacher_curl', 'ez_bar_preacher_curl',
      'lateral_raise', 'cable_lateral_raise',
      'overhead_press', 'dumbbell_shoulder_press',
      'lunge', 'walking_lunge',
      'plank',
    };
    return aiKeys.contains(key);
  }

  // ==========================================
  // CENTRALIZED EXERCISE REGISTRY (77 EXERCISES)
  // Organized by exact muscle categories
  // ==========================================
  static List<Exercise> get fallbackExercises => [
    // ------------------------------------------
    // 1. CHEST
    // ------------------------------------------
    Exercise(
      key: 'barbell_bench_press',
      name: 'Barbell Bench Press',
      category: 'Chest',
      difficulty: 'Intermediate',
      primaryMuscles: 'Pectoralis Major (Sternal & Clavicular)',
      secondaryMuscles: 'Anterior Deltoids, Triceps Brachii',
      targetMuscles: 'Pectoralis Major, Triceps Brachii, Anterior Deltoids',
      description: 'The definitive upper-body pressing compound exercise for building chest thickness and raw pushing power.',
      instructions: [
        'Lie flat on the bench with eyes positioned directly under the racked barbell.',
        'Grip the bar slightly wider than shoulder-width with wrists straight.',
        'Unrack the bar and stabilize it directly over your chest with locked arms.',
        'Lower the bar with control to your mid-chest touching lightly at nipple line.',
        'Press forcefully upward, driving your feet into the floor to return to top.'
      ],
      commonMistakes: [
        'Bouncing the bar off the ribcage',
        'Flaring elbows out at 90 degrees to torso',
        'Lifting hips off the bench during drive'
      ],
      caloriesPerRep: 0.65,
      equipment: 'Barbell & Flat Bench',
      recommendedSets: '4 Sets',
      recommendedReps: '8-10 Reps',
      estimatedDuration: '10 min',
      executionTechnique: 'Retract scapulae and maintain slight arch in lumbar spine.',
      startingPosition: 'Plant feet flat, shoulder blades squeezed into bench.',
      breathingTechnique: 'Inhale deep as the bar descends; exhale forcefully through sticking point.',
      safetyInstructions: 'Always use collars and keep thumb wrapped around the bar.',
      imageUrl: ExerciseImageRegistry.getImage('barbell_bench_press'),
      isAiSupported: false,
    ),
    Exercise(
      key: 'incline_bench_press',
      name: 'Incline Bench Press',
      category: 'Chest',
      difficulty: 'Intermediate',
      primaryMuscles: 'Upper Pectoralis Major (Clavicular Head)',
      secondaryMuscles: 'Anterior Deltoids, Triceps',
      targetMuscles: 'Clavicular Pectorals, Deltoids, Triceps',
      description: 'Targets upper chest fibers at a 30 to 45-degree angle to create a balanced, full chest profile.',
      instructions: [
        'Set an adjustable bench to a 30-45 degree incline.',
        'Grip the bar slightly wider than shoulder-width and unrack over upper chest.',
        'Lower bar smoothly to the upper clavicular notch with elbows tucked at 45°.',
        'Press upward in a slight diagonal arc back to start position.'
      ],
      commonMistakes: [
        'Setting incline angle steeper than 45 degrees (shifts work to shoulders)',
        'Wrists cocking backward under the bar load'
      ],
      caloriesPerRep: 0.62,
      equipment: 'Barbell & Incline Bench',
      recommendedSets: '3 Sets',
      recommendedReps: '8-12 Reps',
      estimatedDuration: '10 min',
      imageUrl: ExerciseImageRegistry.getImage('incline_bench_press'),
    ),
    Exercise(
      key: 'decline_bench_press',
      name: 'Decline Bench Press',
      category: 'Chest',
      difficulty: 'Intermediate',
      primaryMuscles: 'Lower Pectoralis Major (Costal Head)',
      secondaryMuscles: 'Triceps, Anterior Deltoids',
      targetMuscles: 'Lower Pectorals, Triceps',
      description: 'Focuses mechanical tension onto the lower pectoral shelf with reduced shoulder joint stress.',
      instructions: [
        'Secure your legs under the decline bench rollers and lie back.',
        'Grip the bar with overhand grip and unrack directly over lower chest.',
        'Lower the bar slowly to touch the lower sternum.',
        'Drive bar vertically upward until elbows reach full extension.'
      ],
      commonMistakes: [
        'Lifting neck off bench during press',
        'Letting bar drift over face instead of lower chest'
      ],
      caloriesPerRep: 0.58,
      equipment: 'Barbell & Decline Bench',
      recommendedSets: '3 Sets',
      recommendedReps: '10-12 Reps',
      imageUrl: ExerciseImageRegistry.getImage('decline_bench_press'),
    ),
    Exercise(
      key: 'dumbbell_bench_press',
      name: 'Dumbbell Bench Press',
      category: 'Chest',
      difficulty: 'Beginner',
      primaryMuscles: 'Pectoralis Major',
      secondaryMuscles: 'Triceps, Anterior Deltoids, Rotator Cuff',
      targetMuscles: 'Chest, Triceps, Stabilizers',
      description: 'Allows greater range of motion and unilateral stabilization than the barbell bench press.',
      instructions: [
        'Sit on flat bench holding dumbbells on thighs, then kick back onto bench.',
        'Hold dumbbells at chest level with palms angled slightly inward (45°).',
        'Press dumbbells upward and slightly inward in a gentle triangle path.',
        'Lower weights until dumbbells hover level with outer chest.'
      ],
      commonMistakes: [
        'Clanking dumbbells together at top',
        'Dropping elbows below bench plane excessively'
      ],
      caloriesPerRep: 0.55,
      equipment: 'Dumbbells & Flat Bench',
      recommendedSets: '3 Sets',
      recommendedReps: '10-12 Reps',
      imageUrl: ExerciseImageRegistry.getImage('dumbbell_bench_press'),
    ),
    Exercise(
      key: 'incline_dumbbell_press',
      name: 'Incline Dumbbell Press',
      category: 'Chest',
      difficulty: 'Intermediate',
      primaryMuscles: 'Upper Pectoralis Major',
      secondaryMuscles: 'Anterior Deltoids, Triceps',
      targetMuscles: 'Upper Chest, Deltoids',
      description: 'Isolates clavicular head of pectorals with personalized arm path and free joint movement.',
      instructions: [
        'Set bench to 30 degrees incline. Clean dumbbells to shoulders and lie back.',
        'Press both dumbbells overhead without locking elbows harshly.',
        'Lower smoothly with elbows tucked at 45 degrees relative to ribs.'
      ],
      commonMistakes: [
        'Excessive arch in lower back',
        'Pressing dumbbells outward instead of upward'
      ],
      caloriesPerRep: 0.55,
      equipment: 'Dumbbells & Incline Bench',
      recommendedSets: '3 Sets',
      recommendedReps: '10-12 Reps',
      imageUrl: ExerciseImageRegistry.getImage('incline_dumbbell_press'),
    ),
    Exercise(
      key: 'dumbbell_fly',
      name: 'Dumbbell Fly',
      category: 'Chest',
      difficulty: 'Intermediate',
      primaryMuscles: 'Pectoralis Major (Sternal Head)',
      secondaryMuscles: 'Anterior Deltoids, Biceps Brachii',
      targetMuscles: 'Pectoral Squeeze, Sternal Head',
      description: 'Pectoral isolation exercise that maximizes horizontal adduction and stretch on chest fibers.',
      instructions: [
        'Lie on flat bench with dumbbells held over chest, elbows slightly bent.',
        'Lower arms out to sides in a wide arc until chest feels deep stretch.',
        'Squeeze chest muscles to bring dumbbells back along the same arc.'
      ],
      commonMistakes: [
        'Bending elbows too much turning it into a press',
        'Lowering weights too far causing shoulder impingement'
      ],
      caloriesPerRep: 0.45,
      equipment: 'Dumbbells & Flat Bench',
      recommendedSets: '3 Sets',
      recommendedReps: '12-15 Reps',
      imageUrl: ExerciseImageRegistry.getImage('dumbbell_fly'),
    ),
    Exercise(
      key: 'cable_crossover',
      name: 'Cable Crossover',
      category: 'Chest',
      difficulty: 'Intermediate',
      primaryMuscles: 'Pectoralis Major (Middle & Lower)',
      secondaryMuscles: 'Anterior Deltoids',
      targetMuscles: 'Pectorals, Inner Chest Peak',
      description: 'Delivers continuous muscle tension throughout entire range of horizontal chest fly motion.',
      instructions: [
        'Set cable pulleys to high position and attach D-handles.',
        'Step forward with one foot, lean forward slightly, and keep elbows bent.',
        'Pull handles down and together across front of body in hugging motion.',
        'Squeeze chest peak contraction for 1 second, then control return.'
      ],
      commonMistakes: [
        'Swinging body back and forth for momentum',
        'Straightening elbows completely'
      ],
      caloriesPerRep: 0.42,
      equipment: 'Cable Machine & D-Handles',
      recommendedSets: '3 Sets',
      recommendedReps: '12-15 Reps',
      imageUrl: ExerciseImageRegistry.getImage('cable_crossover'),
    ),
    Exercise(
      key: 'pec_deck_fly',
      name: 'Pec Deck Machine Fly',
      category: 'Chest',
      difficulty: 'Beginner',
      primaryMuscles: 'Pectoralis Major',
      secondaryMuscles: 'Anterior Deltoids',
      targetMuscles: 'Sternal Pectorals',
      description: 'Machine-guided isolation fly providing stabilized resistance and peak chest contraction.',
      instructions: [
        'Adjust seat height so handles align with mid-chest level.',
        'Grip handles and keep forearms flush with pads or handles.',
        'Bring pads smoothly together in front of chest.',
        'Pause and contract chest firmly, then release slowly.'
      ],
      commonMistakes: [
        'Letting weights slam at bottom of eccentric',
        'Shrugging shoulders upward'
      ],
      caloriesPerRep: 0.40,
      equipment: 'Pec Deck Machine',
      recommendedSets: '3 Sets',
      recommendedReps: '12-15 Reps',
      imageUrl: ExerciseImageRegistry.getImage('pec_deck_fly'),
    ),
    Exercise(
      key: 'chest_dips',
      name: 'Chest Dips',
      category: 'Chest',
      difficulty: 'Advanced',
      primaryMuscles: 'Lower Pectoralis Major',
      secondaryMuscles: 'Triceps Brachii, Anterior Deltoids',
      targetMuscles: 'Lower Chest, Triceps',
      description: 'High-intensity bodyweight compound movement that heavily targets the lower chest and triceps.',
      instructions: [
        'Mount parallel bars with locked arms, lean torso forward ~30 degrees.',
        'Lower body smoothly until elbows reach 90 degrees.',
        'Push upward through palms to lock out arms while maintaining forward lean.'
      ],
      commonMistakes: [
        'Staying too upright (shifts tension entirely to triceps)',
        'Dropping too low causing shoulder strain'
      ],
      caloriesPerRep: 0.60,
      equipment: 'Parallel Dip Bars',
      recommendedSets: '3 Sets',
      recommendedReps: '8-12 Reps',
      imageUrl: ExerciseImageRegistry.getImage('chest_dips'),
    ),
    Exercise(
      key: 'pushup',
      name: 'Classic Push-Up',
      category: 'Chest',
      difficulty: 'Beginner',
      primaryMuscles: 'Pectoralis Major, Triceps Brachii',
      secondaryMuscles: 'Anterior Deltoids, Core Abdominals',
      targetMuscles: 'Pectorals, Triceps, Deltoids, Core',
      description: 'Essential upper-body pushing movement strengthening chest, arms, and core stability.',
      instructions: [
        'Place hands slightly wider than shoulder-width in a high plank.',
        'Keep body rigid from crown of head to heels.',
        'Lower chest until elbows reach 90 degrees.',
        'Push firmly back up to full arm extension.'
      ],
      commonMistakes: [
        'Hips sagging down or arching too high',
        'Elbows flaring excessively at 90 degrees to torso',
        'Incomplete depth'
      ],
      caloriesPerRep: 0.50,
      equipment: 'Bodyweight / Mat',
      recommendedSets: '3 Sets',
      recommendedReps: '15-20 Reps',
      isAiSupported: true,
      rulesConfig: {
        'primary_angle': 'elbow_angle',
        'bottom_threshold': 90,
        'top_threshold': 155,
        'required_landmarks': ['LEFT_SHOULDER', 'LEFT_ELBOW', 'LEFT_WRIST', 'LEFT_HIP', 'LEFT_ANKLE']
      },
      imageUrl: ExerciseImageRegistry.getImage('pushup'),
    ),

    // ------------------------------------------
    // 2. BACK
    // ------------------------------------------
    Exercise(
      key: 'lat_pulldown',
      name: 'Lat Pulldown',
      category: 'Back',
      difficulty: 'Beginner',
      primaryMuscles: 'Latissimus Dorsi',
      secondaryMuscles: 'Biceps Brachii, Rhomboids, Rear Deltoids',
      targetMuscles: 'Lats, Upper Back, Biceps',
      description: 'Fundamental vertical pulling movement building back width and V-taper physique.',
      instructions: [
        'Sit with thighs secured snugly under pad. Grip bar wide with overhand grip.',
        'Retract scapulae and pull bar smoothly down to upper chest.',
        'Squeeze lats tight at bottom, then slowly let bar return overhead.'
      ],
      commonMistakes: [
        'Pulling bar behind the neck',
        'Swinging torso backward to use momentum'
      ],
      caloriesPerRep: 0.52,
      equipment: 'Lat Pulldown Cable Machine',
      recommendedSets: '3 Sets',
      recommendedReps: '10-12 Reps',
      imageUrl: ExerciseImageRegistry.getImage('lat_pulldown'),
    ),
    Exercise(
      key: 'pull_up',
      name: 'Overhand Pull-Up',
      category: 'Back',
      difficulty: 'Advanced',
      primaryMuscles: 'Latissimus Dorsi, Teres Major',
      secondaryMuscles: 'Biceps, Rhomboids, Core',
      targetMuscles: 'Lats, Upper Back, Arms',
      description: 'Gold-standard bodyweight pulling exercise for building back width and grip strength.',
      instructions: [
        'Grip pull-up bar slightly wider than shoulders with knuckles over the bar.',
        'Hang with arms fully extended and core braced.',
        'Drive elbows down towards hips until chin clears the bar.',
        'Lower with complete control to dead-hang.'
      ],
      commonMistakes: [
        'Kicking legs / kipping',
        'Partial repetitions without full dead-hang stretch'
      ],
      caloriesPerRep: 0.70,
      equipment: 'Pull-Up Bar',
      recommendedSets: '3 Sets',
      recommendedReps: '6-10 Reps',
      imageUrl: ExerciseImageRegistry.getImage('pull_up'),
    ),
    Exercise(
      key: 'seated_cable_row',
      name: 'Seated Cable Row',
      category: 'Back',
      difficulty: 'Beginner',
      primaryMuscles: 'Rhomboids, Middle & Lower Trapezius',
      secondaryMuscles: 'Latissimus Dorsi, Biceps Brachii',
      targetMuscles: 'Middle Back, Thickness',
      description: 'Horizontal cable pull targeting mid-back thickness, posture, and scapular retraction.',
      instructions: [
        'Sit with feet on footplates, knees slightly bent. Grip V-bar attachment.',
        'Sit upright with chest tall and arms fully extended.',
        'Pull handle toward belly button while driving elbows back.',
        'Squeeze shoulder blades for 1 second, then slowly release.'
      ],
      commonMistakes: [
        'Rounding back during extension',
        'Rocking forward and backward excessively'
      ],
      caloriesPerRep: 0.50,
      equipment: 'Seated Cable Row Machine & V-Bar',
      recommendedSets: '3 Sets',
      recommendedReps: '10-12 Reps',
      imageUrl: ExerciseImageRegistry.getImage('seated_cable_row'),
    ),
    Exercise(
      key: 'bent_over_row',
      name: 'Bent-Over Barbell Row',
      category: 'Back',
      difficulty: 'Intermediate',
      primaryMuscles: 'Latissimus Dorsi, Rhomboids, Trapezius',
      secondaryMuscles: 'Spinal Erectors, Hamstrings, Biceps',
      targetMuscles: 'Complete Back Complex',
      description: 'Heavy compound free-weight movement developing back thickness, core stability, and posterior chain strength.',
      instructions: [
        'Hinge at hips with knees soft until torso is at ~45-degree angle.',
        'Grip barbell just outside knees with palms facing down.',
        'Pull barbell to lower ribcage/navel, keeping elbows tucked close.',
        'Lower bar under control without letting spine round.'
      ],
      commonMistakes: [
        'Rounding lower back into flexion',
        'Standing upright during the row'
      ],
      caloriesPerRep: 0.65,
      equipment: 'Barbell & Weight Plates',
      recommendedSets: '4 Sets',
      recommendedReps: '8-10 Reps',
      imageUrl: ExerciseImageRegistry.getImage('bent_over_row'),
    ),
    Exercise(
      key: 'one_arm_dumbbell_row',
      name: 'One-Arm Dumbbell Row',
      category: 'Back',
      difficulty: 'Beginner',
      primaryMuscles: 'Latissimus Dorsi',
      secondaryMuscles: 'Rhomboids, Biceps, Rear Deltoid',
      targetMuscles: 'Unilateral Lat, Mid-Back',
      description: 'Unilateral rowing movement that corrects muscular imbalances and promotes deep lat contraction.',
      instructions: [
        'Place one knee and same-side hand firmly on flat bench.',
        'Keep spine flat parallel to floor. Hold dumbbell in free hand.',
        'Pull dumbbell vertically up to hip, keeping elbow close to torso.',
        'Lower dumbbell until lat feels full stretch.'
      ],
      commonMistakes: [
        'Rotating torso to yank weight up',
        'Pulling dumbbell to chest instead of hip'
      ],
      caloriesPerRep: 0.48,
      equipment: 'Dumbbell & Flat Bench',
      recommendedSets: '3 Sets each',
      recommendedReps: '10-12 Reps',
      imageUrl: ExerciseImageRegistry.getImage('one_arm_dumbbell_row'),
    ),
    Exercise(
      key: 't_bar_row',
      name: 'T-Bar Row',
      category: 'Back',
      difficulty: 'Intermediate',
      primaryMuscles: 'Mid-Back, Rhomboids, Lats',
      secondaryMuscles: 'Biceps, Posterior Deltoids, Erector Spinae',
      targetMuscles: 'Mid-Back Density',
      description: 'Fixed-pivot rowing movement that allows heavy loading to pack dense muscle onto the mid-back.',
      instructions: [
        'Straddle T-bar platform and hinge hips at 45 degrees.',
        'Grip parallel handles, brace core, and maintain flat back.',
        'Pull handles to chest squeezing scapulae firmly.',
        'Lower weights slowly without rounding lumbar spine.'
      ],
      commonMistakes: [
        'Using legs to heave weight up',
        'Caving chest inward'
      ],
      caloriesPerRep: 0.60,
      equipment: 'T-Bar Row Machine / Landmine',
      recommendedSets: '3 Sets',
      recommendedReps: '8-10 Reps',
      imageUrl: ExerciseImageRegistry.getImage('t_bar_row'),
    ),
    Exercise(
      key: 'straight_arm_pulldown',
      name: 'Straight-Arm Cable Pulldown',
      category: 'Back',
      difficulty: 'Beginner',
      primaryMuscles: 'Latissimus Dorsi (Lower & Outer)',
      secondaryMuscles: 'Teres Major, Triceps Long Head, Abs',
      targetMuscles: 'Lat Isolation, Serratus',
      description: 'Isolation exercise targeting lats through pure shoulder extension without biceps fatigue.',
      instructions: [
        'Attach straight bar or rope to high cable. Step back with slight torso lean.',
        'Keep arms nearly straight with soft elbows.',
        'Pull bar down in an arc to touch thighs by contracting lats.',
        'Return smoothly until arms are level with head.'
      ],
      commonMistakes: [
        'Bending elbows into a tricep pushdown',
        'Rounding upper back'
      ],
      caloriesPerRep: 0.38,
      equipment: 'Cable Machine & Straight Bar',
      recommendedSets: '3 Sets',
      recommendedReps: '12-15 Reps',
      imageUrl: ExerciseImageRegistry.getImage('straight_arm_pulldown'),
    ),
    Exercise(
      key: 'deadlift',
      name: 'Conventional Deadlift',
      category: 'Back',
      difficulty: 'Advanced',
      primaryMuscles: 'Erector Spinae, Gluteus Maximus, Hamstrings',
      secondaryMuscles: 'Lats, Trapezius, Forearms, Core',
      targetMuscles: 'Full Posterior Chain & Back',
      description: 'The premier full-body test of brute strength, recruiting the entire posterior chain from heels to traps.',
      instructions: [
        'Stand with feet hip-width apart, barbell over mid-foot.',
        'Hinge hips back and grip bar just outside shins.',
        'Lock lats, flatten back, and take slack out of the bar.',
        'Drive through floor with legs, extending hips and knees simultaneously.',
        'Stand tall at top lockout without leaning back excessively.'
      ],
      commonMistakes: [
        'Rounding lumbar spine during the pull',
        'Bar drifting away from shins',
        'Hyperextending lower back at top'
      ],
      caloriesPerRep: 0.95,
      equipment: 'Barbell & Bumper Plates',
      recommendedSets: '4 Sets',
      recommendedReps: '5-8 Reps',
      imageUrl: ExerciseImageRegistry.getImage('deadlift'),
    ),
    Exercise(
      key: 'face_pull',
      name: 'Cable Face Pull',
      category: 'Back',
      difficulty: 'Beginner',
      primaryMuscles: 'Rear Deltoids, Infraspinatus, Teres Minor',
      secondaryMuscles: 'Rhomboids, Trapezius',
      targetMuscles: 'Rotator Cuff, Upper Back Posture',
      description: 'Crucial postural exercise strengthening external rotators and rear deltoids to prevent shoulder injury.',
      instructions: [
        'Attach rope to cable at upper-chest height.',
        'Grip rope ends with thumbs pointing backward.',
        'Pull rope towards face, separating hands and flaring elbows back.',
        'Rotate hands upward at peak to engage external rotators.'
      ],
      commonMistakes: [
        'Using too much weight and leaning backward',
        'Pulling to chest instead of eye level'
      ],
      caloriesPerRep: 0.35,
      equipment: 'Cable Machine & Rope Attachment',
      recommendedSets: '3 Sets',
      recommendedReps: '15 Reps',
      imageUrl: ExerciseImageRegistry.getImage('face_pull'),
    ),

    // ------------------------------------------
    // 3. SHOULDERS
    // ------------------------------------------
    Exercise(
      key: 'dumbbell_shoulder_press',
      name: 'Dumbbell Shoulder Press',
      category: 'Shoulders',
      difficulty: 'Intermediate',
      primaryMuscles: 'Anterior & Lateral Deltoids',
      secondaryMuscles: 'Triceps Brachii, Upper Trapezius',
      targetMuscles: 'Deltoid Heads, Triceps',
      description: 'Vertical pressing movement for building round 3D deltoids with free joint articulation.',
      instructions: [
        'Sit upright on bench. Bring dumbbells up to shoulder height, palms forward.',
        'Press weights directly overhead until arms are nearly locked.',
        'Lower smoothly back to ears with control.'
      ],
      commonMistakes: [
        'Arching lower back off bench pad',
        'Clashing dumbbells at the apex'
      ],
      caloriesPerRep: 0.50,
      equipment: 'Dumbbells & Upright Bench',
      recommendedSets: '3 Sets',
      recommendedReps: '8-12 Reps',
      isAiSupported: true,
      rulesConfig: {
        'primary_angle': 'elbow_angle',
        'top_threshold': 165,
        'bottom_threshold': 85
      },
      imageUrl: ExerciseImageRegistry.getImage('dumbbell_shoulder_press'),
    ),
    Exercise(
      key: 'overhead_press',
      name: 'Barbell Overhead Press (OHP)',
      category: 'Shoulders',
      difficulty: 'Intermediate',
      primaryMuscles: 'Anterior Deltoids, Lateral Deltoids',
      secondaryMuscles: 'Triceps Brachii, Upper Chest, Core',
      targetMuscles: 'Shoulder Complex, Core Stability',
      description: 'Standing military barbell press building true overhead strength, deltoids, and core rigidity.',
      instructions: [
        'Stand with feet shoulder-width apart, bar resting on clavicles.',
        'Squeeze glutes and core tight. Press bar overhead in straight vertical path.',
        'Move head slightly back as bar passes face, then forward once cleared.',
        'Lock bar out directly over heels.'
      ],
      commonMistakes: [
        'Leaning torso backward into an incline bench simulation',
        'Allowing bar to drift forward away from body'
      ],
      caloriesPerRep: 0.60,
      equipment: 'Barbell & Weight Plates',
      recommendedSets: '4 Sets',
      recommendedReps: '6-8 Reps',
      isAiSupported: true,
      imageUrl: ExerciseImageRegistry.getImage('overhead_press'),
    ),
    Exercise(
      key: 'arnold_press',
      name: 'Arnold Dumbbell Press',
      category: 'Shoulders',
      difficulty: 'Intermediate',
      primaryMuscles: 'Anterior & Lateral Deltoids',
      secondaryMuscles: 'Triceps, Trapezius',
      targetMuscles: 'All Three Deltoid Heads',
      description: 'Invented by Arnold Schwarzenegger, this rotational press hits all three deltoid heads through rotation.',
      instructions: [
        'Start with dumbbells at chin height, palms facing your chest.',
        'As you press upward, rotate wrists 180 degrees so palms face forward at top.',
        'Reverse the rotation smoothly on the way back down.'
      ],
      commonMistakes: [
        'Rushing the rotation phase',
        'Using momentum to kick weights up'
      ],
      caloriesPerRep: 0.48,
      equipment: 'Dumbbells & Bench',
      recommendedSets: '3 Sets',
      recommendedReps: '10-12 Reps',
      imageUrl: ExerciseImageRegistry.getImage('arnold_press'),
    ),
    Exercise(
      key: 'lateral_raise',
      name: 'Dumbbell Lateral Raise',
      category: 'Shoulders',
      difficulty: 'Beginner',
      primaryMuscles: 'Lateral Deltoids (Side Delts)',
      secondaryMuscles: 'Upper Trapezius, Supraspinatus',
      targetMuscles: 'Side Delts, Shoulder Width',
      description: 'The essential shoulder isolation movement for creating wide, capped deltoids and a broad silhouette.',
      instructions: [
        'Stand tall with dumbbells held at your sides, elbows slightly unlocked.',
        'Raise arms out to sides in a smooth arc until parallel to floor (shoulder level).',
        'Pour the pitchers slightly (pinkies slightly higher than thumbs).',
        'Lower weights with control back to hips.'
      ],
      commonMistakes: [
        'Swinging body or using hip momentum',
        'Shrugging shoulders up toward ears',
        'Raising arms above shoulder plane'
      ],
      caloriesPerRep: 0.32,
      equipment: 'Dumbbells',
      recommendedSets: '4 Sets',
      recommendedReps: '12-15 Reps',
      isAiSupported: true,
      rulesConfig: {
        'primary_angle': 'shoulder_angle',
        'top_threshold': 90,
        'bottom_threshold': 25
      },
      imageUrl: ExerciseImageRegistry.getImage('lateral_raise'),
    ),
    Exercise(
      key: 'front_raise',
      name: 'Dumbbell Front Raise',
      category: 'Shoulders',
      difficulty: 'Beginner',
      primaryMuscles: 'Anterior Deltoids (Front Delts)',
      secondaryMuscles: 'Upper Chest, Serratus Anterior',
      targetMuscles: 'Front Deltoids',
      description: 'Isolates the anterior deltoid head for defined front shoulder definition.',
      instructions: [
        'Stand holding dumbbells resting on front of thighs with overhand grip.',
        'Lift weights forward with arms extended until reaching eye level.',
        'Pause for a split second, then lower smoothly.'
      ],
      commonMistakes: [
        'Rocking torso backward',
        'Swinging dumbbells with leg drive'
      ],
      caloriesPerRep: 0.30,
      equipment: 'Dumbbells',
      recommendedSets: '3 Sets',
      recommendedReps: '12 Reps',
      imageUrl: ExerciseImageRegistry.getImage('front_raise'),
    ),
    Exercise(
      key: 'reverse_fly',
      name: 'Reverse Dumbbell Fly',
      category: 'Shoulders',
      difficulty: 'Intermediate',
      primaryMuscles: 'Posterior Deltoids (Rear Delts)',
      secondaryMuscles: 'Rhomboids, Infraspinatus, Mid-Trapezius',
      targetMuscles: 'Rear Shoulders & Upper Back',
      description: 'Hinged fly motion isolating posterior deltoids for balanced shoulder health and 3D look.',
      instructions: [
        'Hinge hips until torso is almost parallel to floor, dumbbells under chest.',
        'Keep slight bend in elbows and raise arms out to sides like wings.',
        'Squeeze rear deltoids at peak, then lower slowly.'
      ],
      commonMistakes: [
        'Bending elbows into a row',
        'Using traps instead of rear deltoids'
      ],
      caloriesPerRep: 0.32,
      equipment: 'Dumbbells',
      recommendedSets: '3 Sets',
      recommendedReps: '12-15 Reps',
      imageUrl: ExerciseImageRegistry.getImage('reverse_fly'),
    ),
    Exercise(
      key: 'cable_lateral_raise',
      name: 'Cable Lateral Raise',
      category: 'Shoulders',
      difficulty: 'Intermediate',
      primaryMuscles: 'Lateral Deltoids',
      secondaryMuscles: 'Trapezius',
      targetMuscles: 'Side Delts',
      description: 'Maintains continuous resistance on lateral deltoids through the entire arc of motion.',
      instructions: [
        'Set cable to lowest setting. Stand perpendicular and hold D-handle across body.',
        'Raise handle laterally away from body up to shoulder height.',
        'Lower slowly under constant tension.'
      ],
      commonMistakes: [
        'Leaning heavily into the cable column',
        'Jerking weight off the bottom stack'
      ],
      caloriesPerRep: 0.32,
      equipment: 'Cable Machine & D-Handle',
      recommendedSets: '3 Sets',
      recommendedReps: '12-15 Reps',
      isAiSupported: true,
      imageUrl: ExerciseImageRegistry.getImage('cable_lateral_raise'),
    ),
    Exercise(
      key: 'upright_row',
      name: 'Barbell Upright Row',
      category: 'Shoulders',
      difficulty: 'Intermediate',
      primaryMuscles: 'Lateral Deltoids, Upper Trapezius',
      secondaryMuscles: 'Biceps, Forearms',
      targetMuscles: 'Shoulders, Traps',
      description: 'Compound pulling exercise targeting side delts and upper traps in a single upward pull.',
      instructions: [
        'Hold barbell with shoulder-width overhand grip resting against thighs.',
        'Pull bar vertically up along torso, leading with elbows high.',
        'Stop when bar reaches mid-chest (elbows at shoulder level).',
        'Lower smoothly back to start.'
      ],
      commonMistakes: [
        'Gripping too narrow (strains rotator cuff)',
        'Pulling bar up to chin level'
      ],
      caloriesPerRep: 0.45,
      equipment: 'Barbell / EZ-Bar',
      recommendedSets: '3 Sets',
      recommendedReps: '10-12 Reps',
      imageUrl: ExerciseImageRegistry.getImage('upright_row'),
    ),
    Exercise(
      key: 'dumbbell_shrugs',
      name: 'Dumbbell Shrugs',
      category: 'Shoulders',
      difficulty: 'Beginner',
      primaryMuscles: 'Upper Trapezius',
      secondaryMuscles: 'Levator Scapulae, Forearms',
      targetMuscles: 'Traps, Neck Support',
      description: 'Heavy trap isolation movement developing upper neck and scapular elevation power.',
      instructions: [
        'Stand holding heavy dumbbells at your sides with arms straight.',
        'Elevate shoulders straight up toward ears as high as possible.',
        'Hold peak contraction for 1 full second, then release slowly.'
      ],
      commonMistakes: [
        'Rolling shoulders in circles (injures rotator cuff)',
        'Bending elbows to assist the lift'
      ],
      caloriesPerRep: 0.38,
      equipment: 'Heavy Dumbbells',
      recommendedSets: '4 Sets',
      recommendedReps: '12-15 Reps',
      imageUrl: ExerciseImageRegistry.getImage('dumbbell_shrugs'),
    ),

    // ------------------------------------------
    // 4. BICEPS
    // ------------------------------------------
    Exercise(
      key: 'bicep_curl',
      name: 'Standing Bicep Curl',
      category: 'Biceps',
      difficulty: 'Beginner',
      primaryMuscles: 'Biceps Brachii',
      secondaryMuscles: 'Brachialis, Forearm Flexors',
      targetMuscles: 'Biceps Brachii, Brachialis',
      description: 'Isolated arm exercise building biceps peak and elbow flexion strength.',
      instructions: [
        'Stand tall holding resistance or dumbbells with palms facing forward.',
        'Keep upper arms pinned stationary by your ribcage.',
        'Curl palms upward towards shoulders contracting biceps.',
        'Lower back down with smooth controlled eccentric motion.'
      ],
      commonMistakes: [
        'Swinging shoulders or momentum',
        'Elbows moving forward away from torso'
      ],
      caloriesPerRep: 0.38,
      equipment: 'Dumbbells',
      recommendedSets: '3 Sets',
      recommendedReps: '10-12 Reps',
      isAiSupported: true,
      imageUrl: ExerciseImageRegistry.getImage('bicep_curl'),
    ),
    Exercise(
      key: 'barbell_curl',
      name: 'Standing Barbell Curl',
      category: 'Biceps',
      difficulty: 'Beginner',
      primaryMuscles: 'Biceps Brachii (Short & Long heads)',
      secondaryMuscles: 'Brachialis, Brachioradialis, Forearms',
      targetMuscles: 'Biceps Peak, Arm Mass',
      description: 'The heavyweight mass-builder for full, thick biceps through heavy bilateral elbow flexion.',
      instructions: [
        'Stand tall holding barbell with shoulder-width underhand grip.',
        'Pin elbows stationary against your sides.',
        'Curl the bar upward contracting biceps until forearms touch biceps.',
        'Lower under complete control to full extension.'
      ],
      commonMistakes: [
        'Swinging hips or back to heave the weight',
        'Letting elbows drift forward away from ribcage'
      ],
      caloriesPerRep: 0.40,
      equipment: 'Straight Barbell & Plates',
      recommendedSets: '4 Sets',
      recommendedReps: '8-10 Reps',
      isAiSupported: true,
      rulesConfig: {
        'primary_angle': 'elbow_angle',
        'top_threshold': 55,
        'bottom_threshold': 145
      },
      imageUrl: ExerciseImageRegistry.getImage('barbell_curl'),
    ),
    Exercise(
      key: 'standing_dumbbell_curl',
      name: 'Standing Dumbbell Curl',
      category: 'Biceps',
      difficulty: 'Beginner',
      primaryMuscles: 'Biceps Brachii',
      secondaryMuscles: 'Brachialis, Forearm Flexors',
      targetMuscles: 'Biceps Flexion & Supination',
      description: 'Allows natural wrist supination during the curl to activate both heads of the biceps brachii.',
      instructions: [
        'Stand with dumbbells at sides, palms facing inward.',
        'Curl weights upward, supinating wrists so palms face shoulders at top.',
        'Squeeze peak biceps contraction, then lower slowly.'
      ],
      commonMistakes: [
        'Swinging torso momentum',
        'Failing to fully supinate wrist at peak'
      ],
      caloriesPerRep: 0.38,
      equipment: 'Dumbbells',
      recommendedSets: '3 Sets',
      recommendedReps: '10-12 Reps',
      isAiSupported: true,
      imageUrl: ExerciseImageRegistry.getImage('standing_dumbbell_curl'),
    ),
    Exercise(
      key: 'alternate_dumbbell_curl',
      name: 'Alternate Dumbbell Curl',
      category: 'Biceps',
      difficulty: 'Beginner',
      primaryMuscles: 'Biceps Brachii',
      secondaryMuscles: 'Brachialis, Forearms',
      targetMuscles: 'Biceps Unilateral Focus',
      description: 'Single-arm alternating curl maximizing mind-muscle connection and full focus on each arm.',
      instructions: [
        'Hold dumbbells at sides. Curl right arm up with full wrist rotation.',
        'Lower right arm smoothly while curling left arm upward.',
        'Maintain strict upright posture without rocking side to side.'
      ],
      commonMistakes: [
        'Leaning sideways towards the working arm',
        'Dropping weights too fast on eccentric'
      ],
      caloriesPerRep: 0.35,
      equipment: 'Dumbbells',
      recommendedSets: '3 Sets each',
      recommendedReps: '10-12 Reps',
      imageUrl: ExerciseImageRegistry.getImage('alternate_dumbbell_curl'),
    ),
    Exercise(
      key: 'hammer_curl',
      name: 'Neutral Grip Hammer Curl',
      category: 'Biceps',
      difficulty: 'Beginner',
      primaryMuscles: 'Brachialis, Brachioradialis',
      secondaryMuscles: 'Biceps Brachii, Forearm Extensors',
      targetMuscles: 'Arm Thickness, Forearms',
      description: 'Neutral palms-facing grip targets the brachialis muscle beneath biceps to push biceps peak higher.',
      instructions: [
        'Stand holding dumbbells with palms facing each other (neutral grip).',
        'Keep elbows pinned to your sides and curl weights up to shoulders.',
        'Squeeze at top, then lower smoothly under control.'
      ],
      commonMistakes: [
        'Flaring elbows out to sides',
        'Using hip swing'
      ],
      caloriesPerRep: 0.38,
      equipment: 'Dumbbells',
      recommendedSets: '3 Sets',
      recommendedReps: '10-12 Reps',
      isAiSupported: true,
      imageUrl: ExerciseImageRegistry.getImage('hammer_curl'),
    ),
    Exercise(
      key: 'concentration_curl',
      name: 'Concentration Curl',
      category: 'Biceps',
      difficulty: 'Beginner',
      primaryMuscles: 'Biceps Brachii (Short Head Focus)',
      secondaryMuscles: 'Brachialis',
      targetMuscles: 'Biceps Peak Isolation',
      description: 'Seated isolation curl with elbow braced against thigh, eliminating all body momentum.',
      instructions: [
        'Sit on bench, brace back of right elbow against inside of right thigh.',
        'Let dumbbell hang fully extended towards floor.',
        'Curl dumbbell up towards face without moving elbow off thigh.',
        'Squeeze hard at top and lower with a 3-second tempo.'
      ],
      commonMistakes: [
        'Lifting elbow off inner thigh during curl',
        'Swinging torso backward'
      ],
      caloriesPerRep: 0.32,
      equipment: 'Single Dumbbell & Bench',
      recommendedSets: '3 Sets each',
      recommendedReps: '12 Reps',
      imageUrl: ExerciseImageRegistry.getImage('concentration_curl'),
    ),
    Exercise(
      key: 'preacher_curl',
      name: 'Preacher Curl',
      category: 'Biceps',
      difficulty: 'Intermediate',
      primaryMuscles: 'Biceps Brachii (Short Head & Lower Bicep)',
      secondaryMuscles: 'Brachialis, Forearm Flexors',
      targetMuscles: 'Lower Biceps Tie-In',
      description: 'Arm curl executed on a 45-degree slanted preacher bench ensuring strict isolation and deep stretch.',
      instructions: [
        'Sit at preacher bench with armpits snug over pad and triceps firmly against the cushion.',
        'Grip bar with underhand grip, arms extended.',
        'Curl bar upward contracting biceps without lifting elbows off pad.',
        'Stop just short of vertical to maintain tension, then lower with control.'
      ],
      commonMistakes: [
        'Lifting elbows off preacher pad to cheat',
        'Hyperextending elbows at the bottom',
        'Resting bar vertically at top'
      ],
      caloriesPerRep: 0.38,
      equipment: 'Preacher Bench & Barbell / Dumbbell',
      recommendedSets: '3 Sets',
      recommendedReps: '10-12 Reps',
      isAiSupported: true,
      rulesConfig: {
        'primary_angle': 'elbow_angle',
        'top_threshold': 60,
        'bottom_threshold': 140,
        'pad_angle_check': true
      },
      imageUrl: ExerciseImageRegistry.getImage('preacher_curl'),
    ),
    Exercise(
      key: 'ez_bar_preacher_curl',
      name: 'EZ-Bar Preacher Curl',
      category: 'Biceps',
      difficulty: 'Intermediate',
      primaryMuscles: 'Biceps Brachii, Brachialis',
      secondaryMuscles: 'Brachioradialis',
      targetMuscles: 'Biceps Peak, Wrist Comfort',
      description: 'Preacher curl using angled EZ-curl bar to relieve wrist torque and zero-in on biceps muscle.',
      instructions: [
        'Grip EZ-bar on inner camber with wrists naturally angled.',
        'Lock triceps into preacher pad.',
        'Curl smoothly to shoulder level, squeeze biceps, and lower with a 3-second cadence.'
      ],
      commonMistakes: [
        'Bouncing weight off bottom stretch',
        'Lifting chest off support pad'
      ],
      caloriesPerRep: 0.38,
      equipment: 'Preacher Bench & EZ-Bar',
      recommendedSets: '3 Sets',
      recommendedReps: '10-12 Reps',
      isAiSupported: true,
      imageUrl: ExerciseImageRegistry.getImage('ez_bar_preacher_curl'),
    ),
    Exercise(
      key: 'incline_dumbbell_curl',
      name: 'Incline Dumbbell Curl',
      category: 'Biceps',
      difficulty: 'Intermediate',
      primaryMuscles: 'Biceps Brachii (Long Head)',
      secondaryMuscles: 'Brachialis, Anterior Deltoids',
      targetMuscles: 'Long Head Stretch & Peak',
      description: 'Performed on an incline bench to position the shoulder in hyperextension for an intense long-head stretch.',
      instructions: [
        'Set bench to 45-degree incline and sit back with arms hanging down.',
        'Keep upper arms vertical perpendicular to floor.',
        'Curl dumbbells up while keeping elbows pointed down at floor.',
        'Lower under complete control for maximum stretch.'
      ],
      commonMistakes: [
        'Pulling elbows forward to reduce the stretch',
        'Lifting head off the incline pad'
      ],
      caloriesPerRep: 0.36,
      equipment: 'Dumbbells & Incline Bench',
      recommendedSets: '3 Sets',
      recommendedReps: '10-12 Reps',
      imageUrl: ExerciseImageRegistry.getImage('incline_dumbbell_curl'),
    ),
    Exercise(
      key: 'cable_bicep_curl',
      name: 'Cable Biceps Curl',
      category: 'Biceps',
      difficulty: 'Beginner',
      primaryMuscles: 'Biceps Brachii',
      secondaryMuscles: 'Brachialis, Forearms',
      targetMuscles: 'Continuous Biceps Tension',
      description: 'Provides constant resistance throughout the entire curl arc, especially at peak contraction.',
      instructions: [
        'Attach short bar to low cable pulley.',
        'Stand upright holding bar with underhand grip.',
        'Curl bar toward chin while pinning elbows to sides.',
        'Squeeze for 1 second at top and lower slowly.'
      ],
      commonMistakes: [
        'Stepping too far away from pulley',
        'Leaning back as weight stacks rise'
      ],
      caloriesPerRep: 0.35,
      equipment: 'Low Cable Pulley & Straight Bar',
      recommendedSets: '3 Sets',
      recommendedReps: '12-15 Reps',
      imageUrl: ExerciseImageRegistry.getImage('cable_bicep_curl'),
    ),
    Exercise(
      key: 'reverse_curl',
      name: 'Reverse Barbell Curl',
      category: 'Biceps',
      difficulty: 'Intermediate',
      primaryMuscles: 'Brachioradialis, Forearm Extensors',
      secondaryMuscles: 'Biceps Brachii, Brachialis',
      targetMuscles: 'Forearms & Outer Arm',
      description: 'Overhand-grip curl targeting the brachioradialis for forearm thickness and grip power.',
      instructions: [
        'Hold barbell with overhand pronated grip (palms facing down).',
        'Keep wrists rigid and straight.',
        'Curl bar upward using forearms and outer arms.',
        'Lower with steady control.'
      ],
      commonMistakes: [
        'Letting wrists buckle downward',
        'Using excessive weights causing swinging'
      ],
      caloriesPerRep: 0.34,
      equipment: 'Barbell / EZ-Bar',
      recommendedSets: '3 Sets',
      recommendedReps: '12 Reps',
      imageUrl: ExerciseImageRegistry.getImage('reverse_curl'),
    ),

    // ------------------------------------------
    // 5. TRICEPS
    // ------------------------------------------
    Exercise(
      key: 'tricep_pushdown',
      name: 'Triceps Straight-Bar Pushdown',
      category: 'Triceps',
      difficulty: 'Beginner',
      primaryMuscles: 'Triceps Brachii (Lateral & Medial Heads)',
      secondaryMuscles: 'Anterior Deltoids, Core',
      targetMuscles: 'Triceps Horseshoe',
      description: 'Foundational triceps isolation exercise building lateral triceps head and arm lockout strength.',
      instructions: [
        'Attach straight bar to high cable pulley.',
        'Grip with overhand grip and tuck elbows tightly to sides.',
        'Push bar down until arms are completely locked out.',
        'Squeeze triceps at bottom, then let bar return to chest level.'
      ],
      commonMistakes: [
        'Allowing elbows to flare outward or drift forward',
        'Leaning over the bar using body weight'
      ],
      caloriesPerRep: 0.40,
      equipment: 'Cable Machine & Straight Bar',
      recommendedSets: '3 Sets',
      recommendedReps: '12-15 Reps',
      imageUrl: ExerciseImageRegistry.getImage('tricep_pushdown'),
    ),
    Exercise(
      key: 'rope_pushdown',
      name: 'Rope Triceps Pushdown',
      category: 'Triceps',
      difficulty: 'Beginner',
      primaryMuscles: 'Triceps Brachii (Lateral Head)',
      secondaryMuscles: 'Medial Head, Anconeus',
      targetMuscles: 'Triceps Peak Contraction',
      description: 'Using rope attachment allows spreading hands at lockout for greater lateral triceps contraction.',
      instructions: [
        'Attach rope to high pulley. Grip ends with neutral grip.',
        'Push rope down and flare ends apart at the bottom lockout.',
        'Squeeze triceps hard for 1 second, then control the return.'
      ],
      commonMistakes: [
        'Failing to flare rope ends apart at lockout',
        'Shoulders rolling forward'
      ],
      caloriesPerRep: 0.40,
      equipment: 'Cable Machine & Rope Attachment',
      recommendedSets: '3 Sets',
      recommendedReps: '12-15 Reps',
      imageUrl: ExerciseImageRegistry.getImage('rope_pushdown'),
    ),
    Exercise(
      key: 'overhead_tricep_extension',
      name: 'Overhead Dumbbell Triceps Extension',
      category: 'Triceps',
      difficulty: 'Intermediate',
      primaryMuscles: 'Triceps Brachii (Long Head)',
      secondaryMuscles: 'Anconeus, Core',
      targetMuscles: 'Triceps Long Head Stretch',
      description: 'Overhead position puts long head of triceps on maximum stretch for superior muscle hypertrophy.',
      instructions: [
        'Sit upright on bench holding one dumbbell vertically with both hands overhead.',
        'Keep elbows tucked close to ears.',
        'Lower dumbbell behind head until elbows reach 90 degrees.',
        'Press weight back overhead to full arm lockout.'
      ],
      commonMistakes: [
        'Flaring elbows out to sides',
        'Arching lower back aggressively'
      ],
      caloriesPerRep: 0.45,
      equipment: 'Heavy Dumbbell & Bench',
      recommendedSets: '3 Sets',
      recommendedReps: '10-12 Reps',
      imageUrl: ExerciseImageRegistry.getImage('overhead_tricep_extension'),
    ),
    Exercise(
      key: 'skull_crushers',
      name: 'Lying EZ-Bar Skull Crushers',
      category: 'Triceps',
      difficulty: 'Intermediate',
      primaryMuscles: 'Triceps Brachii (Long & Medial Heads)',
      secondaryMuscles: 'Anconeus',
      targetMuscles: 'Triceps Mass & Meat',
      description: 'Lying barbell extension targeting deep triceps fibers through controlled elbow articulation.',
      instructions: [
        'Lie on flat bench holding EZ-bar with narrow overhand grip over chest.',
        'Hinge solely at elbows to lower bar smoothly to forehead / crown.',
        'Extend elbows forcefully back up to starting lockout.'
      ],
      commonMistakes: [
        'Moving upper arms back and forth like a pullover',
        'Flaring elbows outward'
      ],
      caloriesPerRep: 0.48,
      equipment: 'EZ-Bar & Flat Bench',
      recommendedSets: '3 Sets',
      recommendedReps: '10-12 Reps',
      imageUrl: ExerciseImageRegistry.getImage('skull_crushers'),
    ),
    Exercise(
      key: 'close_grip_bench_press',
      name: 'Close-Grip Barbell Bench Press',
      category: 'Triceps',
      difficulty: 'Intermediate',
      primaryMuscles: 'Triceps Brachii (All Heads)',
      secondaryMuscles: 'Inner Pectorals, Anterior Deltoids',
      targetMuscles: 'Triceps Overload & Chest',
      description: 'Heavy compound press narrowing grip to shoulder-width to shift load onto triceps.',
      instructions: [
        'Lie on bench and grip bar shoulder-width apart (thumbs ~14-16 inches apart).',
        'Lower bar with elbows tucked tightly against ribcage.',
        'Touch lower sternum and press forcefully to arm lockout.'
      ],
      commonMistakes: [
        'Gripping too narrow (< 8 inches causes severe wrist strain)',
        'Flaring elbows out'
      ],
      caloriesPerRep: 0.60,
      equipment: 'Barbell & Flat Bench',
      recommendedSets: '3 Sets',
      recommendedReps: '8-10 Reps',
      imageUrl: ExerciseImageRegistry.getImage('close_grip_bench_press'),
    ),
    Exercise(
      key: 'dumbbell_kickback',
      name: 'Dumbbell Triceps Kickback',
      category: 'Triceps',
      difficulty: 'Beginner',
      primaryMuscles: 'Triceps Brachii (Lateral Head Peak)',
      secondaryMuscles: 'Posterior Deltoids',
      targetMuscles: 'Triceps Peak Contraction',
      description: 'Strict isolation exercise delivering maximum contraction at full arm extension.',
      instructions: [
        'Hinge torso forward parallel to floor with one knee on bench.',
        'Keep upper arm pinned parallel to torso.',
        'Extend forearm backward until arm is completely straight.',
        'Squeeze triceps for 1 second before lowering.'
      ],
      commonMistakes: [
        'Dropping upper arm down toward floor',
        'Swinging dumbbell with shoulder momentum'
      ],
      caloriesPerRep: 0.32,
      equipment: 'Dumbbell & Bench',
      recommendedSets: '3 Sets each',
      recommendedReps: '12-15 Reps',
      imageUrl: ExerciseImageRegistry.getImage('dumbbell_kickback'),
    ),
    Exercise(
      key: 'tricep_dips',
      name: 'Bench Triceps Dips',
      category: 'Triceps',
      difficulty: 'Beginner',
      primaryMuscles: 'Triceps Brachii',
      secondaryMuscles: 'Anterior Deltoids, Pectorals',
      targetMuscles: 'Triceps Extension',
      description: 'Bodyweight triceps exercise using a gym bench to build triceps pressing power.',
      instructions: [
        'Place palms on edge of bench behind you with legs extended.',
        'Lower hips down by bending elbows to 90 degrees.',
        'Keep back close to bench edge throughout.',
        'Press back up through palms to full arm lockout.'
      ],
      commonMistakes: [
        'Moving hips too far away from bench (hurts shoulders)',
        'Shrugging shoulders into neck'
      ],
      caloriesPerRep: 0.42,
      equipment: 'Gym Bench',
      recommendedSets: '3 Sets',
      recommendedReps: '12-15 Reps',
      imageUrl: ExerciseImageRegistry.getImage('tricep_dips'),
    ),
    Exercise(
      key: 'diamond_pushup',
      name: 'Diamond Triceps Push-Up',
      category: 'Triceps',
      difficulty: 'Advanced',
      primaryMuscles: 'Triceps Brachii (All Heads)',
      secondaryMuscles: 'Inner Pectorals, Anterior Deltoids, Core',
      targetMuscles: 'Triceps Hypertrophy, Core',
      description: 'High-intensity push-up variation placing hands together in diamond shape to overload triceps.',
      instructions: [
        'Form diamond shape with thumbs and index fingers beneath center of chest.',
        'Maintain a rock-solid plank alignment from head to heels.',
        'Lower chest until touching hands.',
        'Press firmly through triceps back to start.'
      ],
      commonMistakes: [
        'Sagging hips',
        'Flaring elbows out too wide'
      ],
      caloriesPerRep: 0.58,
      equipment: 'Bodyweight / Mat',
      recommendedSets: '3 Sets',
      recommendedReps: '10-15 Reps',
      isAiSupported: true,
      rulesConfig: {
        'primary_angle': 'elbow_angle',
        'bottom_threshold': 85,
        'top_threshold': 160
      },
      imageUrl: ExerciseImageRegistry.getImage('diamond_pushup'),
    ),

    // ------------------------------------------
    // 6. LEGS
    // ------------------------------------------
    Exercise(
      key: 'squat',
      name: 'Bodyweight Squat',
      category: 'Legs',
      difficulty: 'Beginner',
      primaryMuscles: 'Quadriceps, Gluteus Maximus',
      secondaryMuscles: 'Hamstrings, Calves, Core Abdominals',
      targetMuscles: 'Quads, Glutes, Hamstrings, Core',
      description: 'Fundamental lower-body compound exercise that builds leg power, knee stability, and hip mobility.',
      instructions: [
        'Stand tall with feet shoulder-width apart, toes angled slightly outward.',
        'Brace your core, keep chest high, and push hips backward as if sitting into a chair.',
        'Lower smoothly until your hips sink below 90-degree knee flexion.',
        'Drive through your mid-foot and heels to power back up to full extension.'
      ],
      commonMistakes: [
        'Knees caving inward (valgus collapse)',
        'Rounding the lower back / leaning too far forward',
        'Lifting heels off the floor'
      ],
      caloriesPerRep: 0.45,
      equipment: 'Bodyweight',
      recommendedSets: '3 Sets',
      recommendedReps: '15-20 Reps',
      isAiSupported: true,
      rulesConfig: {
        'primary_angle': 'knee_angle',
        'bottom_threshold': 95,
        'top_threshold': 155,
        'required_landmarks': ['LEFT_HIP', 'LEFT_KNEE', 'LEFT_ANKLE', 'LEFT_SHOULDER']
      },
      imageUrl: ExerciseImageRegistry.getImage('squat'),
    ),
    Exercise(
      key: 'barbell_back_squat',
      name: 'Barbell Back Squat',
      category: 'Legs',
      difficulty: 'Advanced',
      primaryMuscles: 'Quadriceps, Gluteus Maximus',
      secondaryMuscles: 'Hamstrings, Adductors, Spinal Erectors, Core',
      targetMuscles: 'Complete Lower Body Power',
      description: 'The king of all leg exercises. Heavy loaded barbell squat building total lower-body strength.',
      instructions: [
        'Rest bar across upper traps (high bar) or rear delts (low bar).',
        'Unrack, step back, and set feet shoulder-width with toes out ~20°.',
        'Inhale deep into belly, brace core, and descend until hip crease is below knee.',
        'Drive out of the hole pushing knees out and driving hips up.'
      ],
      commonMistakes: [
        'Knees caving inward on ascent',
        'Good-morning squat (hips shooting up before chest)',
        'Heels rising off floor'
      ],
      caloriesPerRep: 0.85,
      equipment: 'Barbell & Squat Rack',
      recommendedSets: '4 Sets',
      recommendedReps: '6-8 Reps',
      isAiSupported: true,
      imageUrl: ExerciseImageRegistry.getImage('barbell_back_squat'),
    ),
    Exercise(
      key: 'front_squat',
      name: 'Barbell Front Squat',
      category: 'Legs',
      difficulty: 'Advanced',
      primaryMuscles: 'Quadriceps (Vastus Medialis & Lateralis)',
      secondaryMuscles: 'Glutes, Upper Back, Core',
      targetMuscles: 'Quad Focus & Thoracic Extension',
      description: 'Barbell racked across front deltoids enforces upright torso and shifts maximum load to quads.',
      instructions: [
        'Rack barbell across anterior deltoids with clean grip (fingertips under bar) or cross-arm grip.',
        'Keep elbows high pointing straight forward throughout.',
        'Squat deep while maintaining completely vertical torso.',
        'Drive through heels maintaining high elbows.'
      ],
      commonMistakes: [
        'Dropping elbows causing bar to roll forward',
        'Rounding thoracic spine'
      ],
      caloriesPerRep: 0.80,
      equipment: 'Barbell & Squat Rack',
      recommendedSets: '3 Sets',
      recommendedReps: '6-8 Reps',
      imageUrl: ExerciseImageRegistry.getImage('front_squat'),
    ),
    Exercise(
      key: 'goblet_squat',
      name: 'Kettlebell / Dumbbell Goblet Squat',
      category: 'Legs',
      difficulty: 'Beginner',
      primaryMuscles: 'Quadriceps, Glutes',
      secondaryMuscles: 'Hamstrings, Core, Biceps',
      targetMuscles: 'Legs, Hip Mobility',
      description: 'Superb squat teaching movement holding a kettlebell or dumbbell at chest height.',
      instructions: [
        'Hold dumbbell or kettlebell vertically against chest like a goblet.',
        'Squat down between knees until elbows touch inner knees.',
        'Keep chest proud and drive up through heels.'
      ],
      commonMistakes: [
        'Holding weight away from chest',
        'Rounding upper back'
      ],
      caloriesPerRep: 0.55,
      equipment: 'Kettlebell or Dumbbell',
      recommendedSets: '3 Sets',
      recommendedReps: '12-15 Reps',
      isAiSupported: true,
      imageUrl: ExerciseImageRegistry.getImage('goblet_squat'),
    ),
    Exercise(
      key: 'leg_press',
      name: '45-Degree Leg Press',
      category: 'Legs',
      difficulty: 'Beginner',
      primaryMuscles: 'Quadriceps, Gluteus Maximus',
      secondaryMuscles: 'Hamstrings, Adductors',
      targetMuscles: 'Quad Overload, Leg Mass',
      description: 'Machine compound press delivering intense leg volume without spinal axial loading.',
      instructions: [
        'Sit on leg press seat with back flat against pad. Place feet shoulder-width on platform.',
        'Release safety handles and lower carriage until knees reach 90 degrees.',
        'Press platform back up driving through heels without locking knees.'
      ],
      commonMistakes: [
        'Locking out knees aggressively at top (danger of hyperextension)',
        'Lowering so deep that pelvis rounds off back pad'
      ],
      caloriesPerRep: 0.60,
      equipment: '45-Degree Leg Press Machine',
      recommendedSets: '4 Sets',
      recommendedReps: '10-12 Reps',
      imageUrl: ExerciseImageRegistry.getImage('leg_press'),
    ),
    Exercise(
      key: 'leg_extension',
      name: 'Leg Extension Machine',
      category: 'Legs',
      difficulty: 'Beginner',
      primaryMuscles: 'Quadriceps (Rectus Femoris & Vastus)',
      secondaryMuscles: 'Patellar Tendon',
      targetMuscles: 'Quad Isolation & Definition',
      description: 'Open-chain quadriceps isolation targeting the teardrop muscle around the knee.',
      instructions: [
        'Align knee joint with machine axis of rotation. Pad rests on lower shins.',
        'Extend legs smoothly to full knee extension.',
        'Hold contraction for 1 second, then lower with control.'
      ],
      commonMistakes: [
        'Kicking weight up with explosive momentum',
        'Setting ankle pad too high on shins'
      ],
      caloriesPerRep: 0.35,
      equipment: 'Leg Extension Machine',
      recommendedSets: '3 Sets',
      recommendedReps: '12-15 Reps',
      imageUrl: ExerciseImageRegistry.getImage('leg_extension'),
    ),
    Exercise(
      key: 'leg_curl',
      name: 'Seated / Lying Leg Curl',
      category: 'Legs',
      difficulty: 'Beginner',
      primaryMuscles: 'Hamstrings (Biceps Femoris, Semitendinosus)',
      secondaryMuscles: 'Gastrocnemius (Calves)',
      targetMuscles: 'Hamstring Flexion',
      description: 'Direct hamstring isolation through active knee flexion for balanced leg development.',
      instructions: [
        'Position leg roller pad against lower Achilles tendon.',
        'Curl heels toward glutes by contracting hamstrings.',
        'Hold squeeze at peak, then slowly resist weight on return.'
      ],
      commonMistakes: [
        'Lifting hips off pad during curl',
        'Using jerky momentum'
      ],
      caloriesPerRep: 0.35,
      equipment: 'Leg Curl Machine',
      recommendedSets: '3 Sets',
      recommendedReps: '12-15 Reps',
      imageUrl: ExerciseImageRegistry.getImage('leg_curl'),
    ),
    Exercise(
      key: 'romanian_deadlift',
      name: 'Romanian Deadlift (RDL)',
      category: 'Legs',
      difficulty: 'Intermediate',
      primaryMuscles: 'Hamstrings, Gluteus Maximus',
      secondaryMuscles: 'Erector Spinae, Core',
      targetMuscles: 'Posterior Chain Stretch & Strength',
      description: 'Hip-hinge movement maximizing eccentric hamstring stretch and glute hypertrophy.',
      instructions: [
        'Stand holding barbell at hips. Soften knees and keep them fixed at that angle.',
        'Push hips backward as far as possible while sliding bar down shins.',
        'Stop when you feel deep hamstring stretch (just below knees).',
        'Drive hips forward to return to standing.'
      ],
      commonMistakes: [
        'Bending knees turning it into a squat',
        'Rounding lower back to reach the floor'
      ],
      caloriesPerRep: 0.65,
      equipment: 'Barbell or Dumbbells',
      recommendedSets: '3 Sets',
      recommendedReps: '8-10 Reps',
      imageUrl: ExerciseImageRegistry.getImage('romanian_deadlift'),
    ),
    Exercise(
      key: 'walking_lunge',
      name: 'Walking Lunges',
      category: 'Legs',
      difficulty: 'Intermediate',
      primaryMuscles: 'Quadriceps, Glutes',
      secondaryMuscles: 'Hamstrings, Calves, Core Stability',
      targetMuscles: 'Dynamic Unilateral Leg Power',
      description: 'Dynamic walking lunge building single-leg strength, balance, and athletic stride.',
      instructions: [
        'Step forward with right leg into a deep lunge with both knees at 90 degrees.',
        'Drive through front heel to step left leg directly forward into next lunge.',
        'Maintain upright posture and keep hands on hips or hold dumbbells.'
      ],
      commonMistakes: [
        'Front knee crossing far past toes',
        'Torso collapsing forward'
      ],
      caloriesPerRep: 0.50,
      equipment: 'Dumbbells / Bodyweight',
      recommendedSets: '3 Sets (20 steps)',
      recommendedReps: '20 Total Steps',
      isAiSupported: true,
      imageUrl: ExerciseImageRegistry.getImage('walking_lunge'),
    ),
    Exercise(
      key: 'lunge',
      name: 'Stationary Forward Lunge',
      category: 'Legs',
      difficulty: 'Beginner',
      primaryMuscles: 'Quadriceps, Gluteus Maximus',
      secondaryMuscles: 'Hamstrings, Calves',
      targetMuscles: 'Single-Leg Balance & Legs',
      description: 'Unilateral leg exercise developing single-leg stability, strength, and hip flexibility.',
      instructions: [
        'Step forward with one leg and lower hips until both knees are bent at 90-degree angles.',
        'Keep front knee tracking over ankle, back knee hovering just off ground.',
        'Push off front foot to return to standing position.'
      ],
      commonMistakes: [
        'Front knee collapsing inward',
        'Torso leaning excessively forward'
      ],
      caloriesPerRep: 0.48,
      equipment: 'Bodyweight / Dumbbells',
      recommendedSets: '3 Sets each leg',
      recommendedReps: '10-12 Reps',
      isAiSupported: true,
      rulesConfig: {
        'primary_angle': 'knee_angle',
        'bottom_threshold': 95
      },
      imageUrl: ExerciseImageRegistry.getImage('lunge'),
    ),
    Exercise(
      key: 'bulgarian_split_squat',
      name: 'Bulgarian Split Squat',
      category: 'Legs',
      difficulty: 'Intermediate',
      primaryMuscles: 'Quadriceps, Gluteus Maximus',
      secondaryMuscles: 'Hamstrings, Adductors, Core',
      targetMuscles: 'Unilateral Quad & Glute Hypertrophy',
      description: 'Rear-foot elevated split squat providing immense unilateral quad and glute stimulation.',
      instructions: [
        'Place top of rear foot on bench behind you. Front foot 2-3 feet in front.',
        'Descend by lowering hips until front thigh is parallel to ground.',
        'Drive through front mid-foot back to top.'
      ],
      commonMistakes: [
        'Standing too close to bench jamming the knee',
        'Pushing off rear foot instead of front leg'
      ],
      caloriesPerRep: 0.55,
      equipment: 'Bench & Dumbbells',
      recommendedSets: '3 Sets each leg',
      recommendedReps: '8-10 Reps',
      imageUrl: ExerciseImageRegistry.getImage('bulgarian_split_squat'),
    ),
    Exercise(
      key: 'calf_raises',
      name: 'Standing Calf Raises',
      category: 'Legs',
      difficulty: 'Beginner',
      primaryMuscles: 'Gastrocnemius, Soleus',
      secondaryMuscles: 'Tibialis Posterior',
      targetMuscles: 'Calves, Ankle Stability',
      description: 'Direct calf exercise elevating heels against resistance for diamond-shaped lower legs.',
      instructions: [
        'Stand with balls of feet on an elevated block or step.',
        'Lower heels into deep calf stretch.',
        'Drive onto balls of feet as high as possible.',
        'Hold top squeeze for 2 seconds before lowering.'
      ],
      commonMistakes: [
        'Bouncing rapidly without pausing at stretch and peak',
        'Bending knees'
      ],
      caloriesPerRep: 0.25,
      equipment: 'Step & Dumbbells',
      recommendedSets: '4 Sets',
      recommendedReps: '15-20 Reps',
      imageUrl: ExerciseImageRegistry.getImage('calf_raises'),
    ),

    // ------------------------------------------
    // 7. ABS AND CORE
    // ------------------------------------------
    Exercise(
      key: 'crunches',
      name: 'Classic Abdominal Crunch',
      category: 'Abs and Core',
      difficulty: 'Beginner',
      primaryMuscles: 'Rectus Abdominis (Upper Abs)',
      secondaryMuscles: 'Obliques',
      targetMuscles: 'Upper Abdominals',
      description: 'Targeted trunk flexion exercise that isolates upper abdominal wall.',
      instructions: [
        'Lie on back with knees bent and feet flat on floor. Hands lightly touching temples.',
        'Contract abs to curl head and shoulder blades off floor ~3-4 inches.',
        'Squeeze abs at peak, then slowly lower without relaxing completely.'
      ],
      commonMistakes: [
        'Yanking neck with hands',
        'Lifting lower back off floor'
      ],
      caloriesPerRep: 0.20,
      equipment: 'Mat',
      recommendedSets: '3 Sets',
      recommendedReps: '20 Reps',
      imageUrl: ExerciseImageRegistry.getImage('crunches'),
    ),
    Exercise(
      key: 'reverse_crunches',
      name: 'Reverse Abdominal Crunch',
      category: 'Abs and Core',
      difficulty: 'Beginner',
      primaryMuscles: 'Rectus Abdominis (Lower Abs)',
      secondaryMuscles: 'Hip Flexors',
      targetMuscles: 'Lower Abdominals',
      description: 'Pelvic-tilt crunch moving hips toward chest to activate lower abdominal fibers.',
      instructions: [
        'Lie flat on back with arms beside you and knees bent at 90 degrees.',
        'Contract lower abs to curl hips off floor and bring knees towards chest.',
        'Lower hips back to floor with strict control.'
      ],
      commonMistakes: [
        'Using leg swinging momentum',
        'Arching lower back off mat at bottom'
      ],
      caloriesPerRep: 0.22,
      equipment: 'Mat',
      recommendedSets: '3 Sets',
      recommendedReps: '15 Reps',
      imageUrl: ExerciseImageRegistry.getImage('reverse_crunches'),
    ),
    Exercise(
      key: 'leg_raises',
      name: 'Lying Leg Raises',
      category: 'Abs and Core',
      difficulty: 'Intermediate',
      primaryMuscles: 'Lower Rectus Abdominis, Iliopsoas',
      secondaryMuscles: 'Transverse Abdominis, Obliques',
      targetMuscles: 'Lower Abs & Deep Core',
      description: 'Straight-leg elevation targeting the lower abdominal wall and hip flexors.',
      instructions: [
        'Lie on back with hands under hips for lower back support.',
        'Keep legs straight and raise them to 90 degrees vertical.',
        'Lower legs slowly until heels hover 2 inches above floor without lower back arching.'
      ],
      commonMistakes: [
        'Letting lower back lift off mat during descent',
        'Bending knees excessively'
      ],
      caloriesPerRep: 0.30,
      equipment: 'Mat',
      recommendedSets: '3 Sets',
      recommendedReps: '12-15 Reps',
      imageUrl: ExerciseImageRegistry.getImage('leg_raises'),
    ),
    Exercise(
      key: 'hanging_knee_raises',
      name: 'Hanging Knee Raises',
      category: 'Abs and Core',
      difficulty: 'Intermediate',
      primaryMuscles: 'Lower Rectus Abdominis, Hip Flexors',
      secondaryMuscles: 'Forearms, Lats, Obliques',
      targetMuscles: 'Lower Abs, Grip Strength',
      description: 'Hanging from a pull-up bar, curling knees to chest for deep lower abdominal contraction.',
      instructions: [
        'Hang from pull-up bar with overhand grip and legs straight.',
        'Without swinging, curl knees up to touch chest by tilting pelvis.',
        'Pause and lower legs slowly back to dead-hang.'
      ],
      commonMistakes: [
        'Swinging body back and forth',
        'Only lifting thighs without curling pelvis'
      ],
      caloriesPerRep: 0.40,
      equipment: 'Pull-Up Bar',
      recommendedSets: '3 Sets',
      recommendedReps: '10-15 Reps',
      imageUrl: ExerciseImageRegistry.getImage('hanging_knee_raises'),
    ),
    Exercise(
      key: 'plank',
      name: 'Isometric Forearm Plank',
      category: 'Abs and Core',
      difficulty: 'Beginner',
      primaryMuscles: 'Rectus Abdominis, Transverse Abdominis',
      secondaryMuscles: 'Obliques, Glutes, Deltoids',
      targetMuscles: 'Core Stability & Anti-Extension',
      description: 'Foundational anti-extension core hold building ironclad abdominal strength and spinal protection.',
      instructions: [
        'Position elbows directly below shoulders with forearms parallel on mat.',
        'Step feet back, tuck pelvis slightly into a posterior pelvic tilt.',
        'Squeeze glutes and quads tight; maintain a rigid line from crown to heels.',
        'Breathe steadily through nose without letting hips drop or pike.'
      ],
      commonMistakes: [
        'Hips sagging downward into lumbar hyperextension',
        'Piking hips into an inverted V to relieve abdominal load'
      ],
      caloriesPerRep: 0.15,
      equipment: 'Mat',
      recommendedSets: '3 Sets',
      recommendedReps: '45-60s Hold',
      isAiSupported: true,
      rulesConfig: {
        'primary_angle': 'hip_angle',
        'target_range': [160, 190]
      },
      imageUrl: ExerciseImageRegistry.getImage('plank'),
    ),
    Exercise(
      key: 'side_plank',
      name: 'Side Plank Hold',
      category: 'Abs and Core',
      difficulty: 'Beginner',
      primaryMuscles: 'Internal & External Obliques',
      secondaryMuscles: 'Quadratus Lumborum, Gluteus Medius',
      targetMuscles: 'Lateral Core, Anti-Lateral Flexion',
      description: 'Lateral core hold building stability, waistline strength, and resisting side-bending torque.',
      instructions: [
        'Lie on side with forearm flat under shoulder and feet stacked.',
        'Lift hips off ground until body forms a straight diagonal line.',
        'Hold posture while maintaining steady breathing.'
      ],
      commonMistakes: [
        'Hips dropping toward floor',
        'Top shoulder rolling forward'
      ],
      caloriesPerRep: 0.15,
      equipment: 'Mat',
      recommendedSets: '3 Sets each side',
      recommendedReps: '30-45s Hold',
      imageUrl: ExerciseImageRegistry.getImage('side_plank'),
    ),
    Exercise(
      key: 'russian_twists',
      name: 'Russian Twists',
      category: 'Abs and Core',
      difficulty: 'Intermediate',
      primaryMuscles: 'Internal & External Obliques',
      secondaryMuscles: 'Rectus Abdominis, Hip Flexors',
      targetMuscles: 'Rotational Core Power',
      description: 'Seated rotational core exercise strengthening obliques and rotational athletic control.',
      instructions: [
        'Sit on floor with knees bent and feet elevated 2 inches off floor.',
        'Lean torso back ~45 degrees holding hands or a weight plate.',
        'Rotate torso smoothly to tap the floor on right side, then left side.'
      ],
      commonMistakes: [
        'Moving only arms without rotating the torso',
        'Slumping lower back'
      ],
      caloriesPerRep: 0.28,
      equipment: 'Mat & Medicine Ball / Weight',
      recommendedSets: '3 Sets',
      recommendedReps: '20 Total Twists',
      imageUrl: ExerciseImageRegistry.getImage('russian_twists'),
    ),
    Exercise(
      key: 'bicycle_crunches',
      name: 'Bicycle Crunches',
      category: 'Abs and Core',
      difficulty: 'Beginner',
      primaryMuscles: 'Rectus Abdominis, Obliques',
      secondaryMuscles: 'Hip Flexors',
      targetMuscles: 'Total Abdominal Wall',
      description: 'Cross-body crunch proven by EMG studies to generate the highest abdominal muscle activation.',
      instructions: [
        'Lie on back with hands behind head, knees at 90 degrees.',
        'Bring right elbow towards left knee while extending right leg straight.',
        'Alternate smoothly in a pedaling cadence without pulling neck.'
      ],
      commonMistakes: [
        'Yanking neck with hands',
        'Rushing the tempo instead of squeezing'
      ],
      caloriesPerRep: 0.25,
      equipment: 'Mat',
      recommendedSets: '3 Sets',
      recommendedReps: '20 Reps',
      imageUrl: ExerciseImageRegistry.getImage('bicycle_crunches'),
    ),
    Exercise(
      key: 'mountain_climbers',
      name: 'Mountain Climbers',
      category: 'Abs and Core',
      difficulty: 'Intermediate',
      primaryMuscles: 'Rectus Abdominis, Hip Flexors',
      secondaryMuscles: 'Deltoids, Cardiovascular System',
      targetMuscles: 'Dynamic Core & Conditioning',
      description: 'Dynamic core and endurance movement engaging abdominal stabilizers under rapid pace.',
      instructions: [
        'Start in high plank position with shoulders stacked over wrists.',
        'Drive right knee towards chest without lifting hips.',
        'Quickly switch legs driving left knee forward in running rhythm.',
        'Keep core braced and spine neutral throughout.'
      ],
      commonMistakes: [
        'Bouncing hips high in air',
        'Letting shoulders drift behind wrists'
      ],
      caloriesPerRep: 0.35,
      equipment: 'Mat',
      recommendedSets: '3 Sets',
      recommendedReps: '30s Burst',
      isAiSupported: true,
      imageUrl: ExerciseImageRegistry.getImage('mountain_climbers'),
    ),
    Exercise(
      key: 'ab_wheel_rollout',
      name: 'Ab Wheel Rollout',
      category: 'Abs and Core',
      difficulty: 'Advanced',
      primaryMuscles: 'Rectus Abdominis, Transverse Abdominis',
      secondaryMuscles: 'Lats, Triceps, Hip Flexors',
      targetMuscles: 'Deep Core Anti-Extension',
      description: 'High-intensity core anti-extension roll out challenging the abdominal wall under full lever length.',
      instructions: [
        'Kneel on mat with hands on ab wheel handles directly under shoulders.',
        'Brace abs and slowly roll wheel forward extending body as far as comfortable.',
        'Pull wheel back toward knees using abdominal contraction, not hip flexors.'
      ],
      commonMistakes: [
        'Letting lower back sag into hyperextension',
        'Leading with hips instead of roll'
      ],
      caloriesPerRep: 0.50,
      equipment: 'Ab Wheel & Mat',
      recommendedSets: '3 Sets',
      recommendedReps: '8-10 Reps',
      imageUrl: ExerciseImageRegistry.getImage('ab_wheel_rollout'),
    ),

    // ------------------------------------------
    // 8. FOREARMS
    // ------------------------------------------
    Exercise(
      key: 'wrist_curls',
      name: 'Barbell Wrist Curls',
      category: 'Forearms',
      difficulty: 'Beginner',
      primaryMuscles: 'Flexor Carpi Radialis, Flexor Digitorum',
      secondaryMuscles: 'Forearm Deep Flexors',
      targetMuscles: 'Inner Forearm Mass & Grip',
      description: 'Isolates the wrist flexors on the underside of the forearm for crushing grip strength.',
      instructions: [
        'Sit with forearms resting on flat bench, wrists hanging over edge with underhand grip.',
        'Let bar roll down to fingertips, then curl fingers and wrists upward.',
        'Squeeze forearm flexors at peak and lower smoothly.'
      ],
      commonMistakes: [
        'Lifting forearms off bench',
        'Using excessive weight causing jerky motion'
      ],
      caloriesPerRep: 0.20,
      equipment: 'Barbell & Bench',
      recommendedSets: '3 Sets',
      recommendedReps: '15-20 Reps',
      imageUrl: ExerciseImageRegistry.getImage('wrist_curls'),
    ),
    Exercise(
      key: 'reverse_wrist_curls',
      name: 'Reverse Wrist Curls',
      category: 'Forearms',
      difficulty: 'Beginner',
      primaryMuscles: 'Extensor Carpi Radialis, Extensor Digitorum',
      secondaryMuscles: 'Brachioradialis',
      targetMuscles: 'Top Forearm Extensors',
      description: 'Overhand wrist curls targeting top forearm extensors for balanced wrist health and thickness.',
      instructions: [
        'Rest forearms on bench with wrists hanging over edge, overhand grip.',
        'Curl wrists upward towards ceiling.',
        'Pause for 1 second, then lower back down.'
      ],
      commonMistakes: [
        'Using too heavy weight',
        'Jerking wrists'
      ],
      caloriesPerRep: 0.20,
      equipment: 'Light Barbell or Dumbbells',
      recommendedSets: '3 Sets',
      recommendedReps: '15 Reps',
      imageUrl: ExerciseImageRegistry.getImage('reverse_wrist_curls'),
    ),
    Exercise(
      key: 'farmers_walk',
      name: "Farmer's Walk",
      category: 'Forearms',
      difficulty: 'Intermediate',
      primaryMuscles: 'Forearm Grip, Trapezius',
      secondaryMuscles: 'Core, Calves, Glutes',
      targetMuscles: 'Isometric Grip & Functional Core',
      description: 'Heavy loaded carry building vice-like grip, dense traps, and unshakeable core stability.',
      instructions: [
        'Deadlift two heavy dumbbells or trap bar to standing.',
        'Stand tall with chest proud and shoulders back.',
        'Walk in a straight line with smooth, controlled steps for distance or time.'
      ],
      commonMistakes: [
        'Slumping shoulders forward',
        'Waddling side to side'
      ],
      caloriesPerRep: 0.60,
      equipment: 'Heavy Dumbbells or Trap Bar',
      recommendedSets: '3 Sets (40m walk)',
      recommendedReps: '40 Meter Carry',
      imageUrl: ExerciseImageRegistry.getImage('farmers_walk'),
    ),
    Exercise(
      key: 'reverse_barbell_curl',
      name: 'Standing Reverse Barbell Curl',
      category: 'Forearms',
      difficulty: 'Beginner',
      primaryMuscles: 'Brachioradialis, Forearm Extensors',
      secondaryMuscles: 'Biceps Brachii',
      targetMuscles: 'Forearms & Upper Arm Tie-In',
      description: 'Compound arm curl with overhand grip that directly hammers the thick brachioradialis muscle.',
      instructions: [
        'Stand holding barbell with overhand pronated grip.',
        'Keep wrists locked firm and curl bar up to upper chest.',
        'Lower smoothly with control.'
      ],
      commonMistakes: [
        'Bending wrists backward under the load',
        'Swinging shoulders'
      ],
      caloriesPerRep: 0.35,
      equipment: 'Barbell / EZ-Bar',
      recommendedSets: '3 Sets',
      recommendedReps: '12 Reps',
      imageUrl: ExerciseImageRegistry.getImage('reverse_barbell_curl'),
    ),

    // ------------------------------------------
    // 9. GLUTES
    // ------------------------------------------
    Exercise(
      key: 'hip_thrust',
      name: 'Barbell Hip Thrust',
      category: 'Glutes',
      difficulty: 'Intermediate',
      primaryMuscles: 'Gluteus Maximus (Upper & Lower)',
      secondaryMuscles: 'Hamstrings, Quadriceps, Core',
      targetMuscles: 'Glute Power & Hypertrophy',
      description: 'The premier exercise for maximal gluteus maximus hypertrophy and horizontal hip power.',
      instructions: [
        'Sit on floor with upper back against sturdy bench. Roll padded barbell over hips.',
        'Plant feet flat hip-width apart with shins vertical at top lockout.',
        'Drive through heels to extend hips until torso and thighs form a straight bridge.',
        'Squeeze glutes hard at top for 2 seconds, then lower under control.'
      ],
      commonMistakes: [
        'Hyperextending lumbar spine instead of tucking chin',
        'Feet too far forward (shifts tension to hamstrings)'
      ],
      caloriesPerRep: 0.70,
      equipment: 'Barbell, Hip Pad & Bench',
      recommendedSets: '4 Sets',
      recommendedReps: '8-12 Reps',
      imageUrl: ExerciseImageRegistry.getImage('hip_thrust'),
    ),
    Exercise(
      key: 'glute_bridge',
      name: 'Bodyweight Glute Bridge',
      category: 'Glutes',
      difficulty: 'Beginner',
      primaryMuscles: 'Gluteus Maximus',
      secondaryMuscles: 'Hamstrings, Core',
      targetMuscles: 'Glute Activation & Hip Extension',
      description: 'Ground-based hip bridge targeting glute activation and lower back health.',
      instructions: [
        'Lie on back with knees bent and feet flat on floor hip-width apart.',
        'Drive through heels to lift hips toward ceiling until straight bridge is formed.',
        'Squeeze glutes hard for 2 seconds at peak, then lower slowly.'
      ],
      commonMistakes: [
        'Arching lower back instead of contracting glutes',
        'Pushing from toes'
      ],
      caloriesPerRep: 0.30,
      equipment: 'Mat',
      recommendedSets: '3 Sets',
      recommendedReps: '15-20 Reps',
      imageUrl: ExerciseImageRegistry.getImage('glute_bridge'),
    ),
    Exercise(
      key: 'cable_kickbacks',
      name: 'Cable Glute Kickbacks',
      category: 'Glutes',
      difficulty: 'Beginner',
      primaryMuscles: 'Gluteus Maximus (Upper Shelf)',
      secondaryMuscles: 'Hamstrings',
      targetMuscles: 'Glute Isolation',
      description: 'Ankle-cuff cable extension isolating the gluteus maximus through full hip extension.',
      instructions: [
        'Attach ankle strap to low cable. Face pulley and hold support pole.',
        'Kick working leg back and upward in a smooth arc.',
        'Squeeze glute at apex without arching spine.',
        'Return foot slowly to start.'
      ],
      commonMistakes: [
        'Swinging leg rapidly',
        'Arching lower back to get fake height'
      ],
      caloriesPerRep: 0.30,
      equipment: 'Cable Machine & Ankle Strap',
      recommendedSets: '3 Sets each leg',
      recommendedReps: '12-15 Reps',
      imageUrl: ExerciseImageRegistry.getImage('cable_kickbacks'),
    ),
    Exercise(
      key: 'sumo_squat',
      name: 'Dumbbell Sumo Squat',
      category: 'Glutes',
      difficulty: 'Beginner',
      primaryMuscles: 'Gluteus Maximus, Adductors (Inner Thighs)',
      secondaryMuscles: 'Quadriceps, Hamstrings',
      targetMuscles: 'Glutes, Inner Thighs',
      description: 'Wide-stance squat emphasizing glutes and adductor complex.',
      instructions: [
        'Stand with feet wide (1.5x shoulder width) with toes angled outward 45 degrees.',
        'Hold heavy dumbbell vertically between legs.',
        'Lower hips down and back until thighs are parallel to ground.',
        'Drive up through heels squeezing glutes firmly at top.'
      ],
      commonMistakes: [
        'Knees collapsing inward',
        'Leaning too far forward'
      ],
      caloriesPerRep: 0.50,
      equipment: 'Single Heavy Dumbbell',
      recommendedSets: '3 Sets',
      recommendedReps: '12 Reps',
      imageUrl: ExerciseImageRegistry.getImage('sumo_squat'),
    ),
    Exercise(
      key: 'donkey_kicks',
      name: 'Quadruped Donkey Kicks',
      category: 'Glutes',
      difficulty: 'Beginner',
      primaryMuscles: 'Gluteus Maximus',
      secondaryMuscles: 'Hamstrings, Core',
      targetMuscles: 'Glute Peak Contraction',
      description: 'All-fours hip extension kicking heel toward ceiling for targeted gluteus maximus burn.',
      instructions: [
        'Start on hands and knees with wrists under shoulders and knees under hips.',
        'Keep right knee bent at 90 degrees and kick sole of right foot toward ceiling.',
        'Squeeze glute at top without tilting hips.',
        'Lower with control back to start.'
      ],
      commonMistakes: [
        'Twisting hips off-level',
        'Arching lower back'
      ],
      caloriesPerRep: 0.25,
      equipment: 'Mat',
      recommendedSets: '3 Sets each leg',
      recommendedReps: '15-20 Reps',
      imageUrl: ExerciseImageRegistry.getImage('donkey_kicks'),
    ),

    // ------------------------------------------
    // 10. FULL BODY & CARDIO
    // ------------------------------------------
    Exercise(
      key: 'burpee',
      name: 'Full Body Burpee Blast',
      category: 'Full Body',
      difficulty: 'Advanced',
      primaryMuscles: 'Full Body Compound',
      secondaryMuscles: 'Pectorals, Quadriceps, Deltoids, Glutes, Core',
      targetMuscles: 'Cardiovascular Power, Full Body',
      description: 'Maximum power metabolic conditioning compound linking squat, plank, push-up, and jump.',
      instructions: [
        'From standing, squat down and plant hands firmly on floor.',
        'Jump feet back into high plank and perform push-up.',
        'Immediately jump feet forward towards hands.',
        'Explosively leap upward extending arms overhead.'
      ],
      commonMistakes: [
        'Sagging lower back in plank',
        'Landing stiff-legged on jump'
      ],
      caloriesPerRep: 1.20,
      equipment: 'Bodyweight',
      recommendedSets: '3 Sets',
      recommendedReps: '10-15 Reps',
      imageUrl: ExerciseImageRegistry.getImage('burpee'),
    ),
    Exercise(
      key: 'jumping_jacks',
      name: 'High Knees Cardio Burst',
      category: 'Cardio',
      difficulty: 'Beginner',
      primaryMuscles: 'Cardiovascular System, Quadriceps',
      secondaryMuscles: 'Calves, Hip Flexors',
      targetMuscles: 'Heart Rate, Agility',
      description: 'Rapid cardiovascular drill elevating heart rate and training lower-limb cadence.',
      instructions: [
        'Stand in place with feet hip-width apart.',
        'Drive right knee up to hip height while pumping left arm.',
        'Alternate dynamically in rapid running stride.',
        'Land softly on balls of feet.'
      ],
      commonMistakes: [
        'Leaning back excessively',
        'Failing to drive knees to waist height'
      ],
      caloriesPerRep: 0.28,
      equipment: 'Bodyweight',
      recommendedSets: '3 Sets',
      recommendedReps: '45s Sprint',
      imageUrl: ExerciseImageRegistry.getImage('jumping_jacks'),
    ),
  ];
}
