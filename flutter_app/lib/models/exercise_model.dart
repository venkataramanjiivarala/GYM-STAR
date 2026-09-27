class Exercise {
  final String key;
  final String name;
  final String category;
  final String difficulty;
  final String targetMuscles;
  final String description;
  final List<String> instructions;
  final List<String> commonMistakes;
  final double caloriesPerRep;
  final Map<String, dynamic>? rulesConfig;

  Exercise({
    required this.key,
    required this.name,
    required this.category,
    required this.difficulty,
    required this.targetMuscles,
    required this.description,
    required this.instructions,
    required this.commonMistakes,
    required this.caloriesPerRep,
    this.rulesConfig,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      key: json['key'] ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? 'General',
      difficulty: json['difficulty'] ?? 'Beginner',
      targetMuscles: json['target_muscles'] ?? '',
      description: json['description'] ?? '',
      instructions: json['instructions'] != null
          ? List<String>.from(json['instructions'])
          : [],
      commonMistakes: json['common_mistakes'] != null
          ? List<String>.from(json['common_mistakes'])
          : [],
      caloriesPerRep: (json['calories_per_rep'] as num?)?.toDouble() ?? 0.4,
      rulesConfig: json['rules_config'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'name': name,
      'category': category,
      'difficulty': difficulty,
      'target_muscles': targetMuscles,
      'description': description,
      'instructions': instructions,
      'common_mistakes': commonMistakes,
      'calories_per_rep': caloriesPerRep,
      'rules_config': rulesConfig,
    };
  }

  static List<Exercise> get fallbackExercises => [
    Exercise(
      key: 'squat',
      name: 'Bodyweight Squat',
      category: 'Legs',
      difficulty: 'Beginner',
      targetMuscles: 'Quadriceps, Glutes, Hamstrings, Core',
      description: 'Fundamental lower-body compound exercise that builds leg strength and hip mobility.',
      instructions: [
        'Stand with feet shoulder-width apart, toes pointed slightly outward.',
        'Keep your chest upright and core braced.',
        'Lower your hips down and back until knees reach approximately 90 degrees.',
        'Drive through your heels to return to standing position.'
      ],
      commonMistakes: [
        'Knees caving inward (valgus collapse)',
        'Rounding the lower back',
        'Lifting heels off the ground'
      ],
      caloriesPerRep: 0.45,
    ),
    Exercise(
      key: 'pushup',
      name: 'Classic Push-Up',
      category: 'Chest',
      difficulty: 'Beginner',
      targetMuscles: 'Pectorals, Triceps, Anterior Deltoids, Core',
      description: 'Essential upper-body pushing movement strengthening chest, arms, and core stability.',
      instructions: [
        'Place hands slightly wider than shoulder-width apart in a rigid high plank position.',
        'Keep body in a straight line from crown of head to heels.',
        'Lower chest until elbows reach 90 degrees.',
        'Push firmly back up to full arm extension.'
      ],
      commonMistakes: [
        'Hips sagging down or arching too high',
        'Elbows flaring excessively at 90 degrees to torso',
        'Incomplete depth'
      ],
      caloriesPerRep: 0.50,
    ),
    Exercise(
      key: 'bicep_curl',
      name: 'Standing Bicep Curl',
      category: 'Arms',
      difficulty: 'Beginner',
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
      caloriesPerRep: 0.35,
    ),
    Exercise(
      key: 'lunge',
      name: 'Forward Lunge',
      category: 'Legs',
      difficulty: 'Intermediate',
      targetMuscles: 'Quadriceps, Glutes, Hamstrings, Calves',
      description: 'Unilateral leg exercise developing single-leg stability, strength, and hip flexibility.',
      instructions: [
        'Step forward with one leg and lower hips until both knees are bent at 90-degree angles.',
        'Keep front knee tracking over ankle, back knee hovering just off the ground.',
        'Push off front foot to return to standing position.'
      ],
      commonMistakes: [
        'Front knee collapsing inward',
        'Torso leaning excessively forward'
      ],
      caloriesPerRep: 0.48,
    ),
    Exercise(
      key: 'plank',
      name: 'Isometric Forearm Plank',
      category: 'Core',
      difficulty: 'Beginner',
      targetMuscles: 'Rectus Abdominis, Obliques, Transverse Abdominis',
      description: 'Core stability hold strengthening deep abdominal wall and spine stabilizers.',
      instructions: [
        'Place forearms on ground with elbows directly under shoulders.',
        'Extend legs straight behind with toes tucked.',
        'Maintain a perfectly straight horizontal line from shoulders to ankles.'
      ],
      commonMistakes: [
        'Hips drooping down toward ground',
        'Piking hips up into inverted V'
      ],
      caloriesPerRep: 0.15,
    ),
    Exercise(
      key: 'overhead_press',
      name: 'Dumbbell Overhead Press',
      category: 'Shoulders',
      difficulty: 'Intermediate',
      targetMuscles: 'Anterior & Lateral Deltoids, Triceps, Trapezius',
      description: 'Vertical pressing exercise that develops overhead strength and shoulder stability.',
      instructions: [
        'Hold weights at shoulder height with palms facing forward.',
        'Press overhead until arms are fully extended without arching back.',
        'Lower slowly with control back to shoulder level.'
      ],
      commonMistakes: [
        'Excessive lower back arching',
        'Incomplete extension overhead'
      ],
      caloriesPerRep: 0.42,
    ),
    Exercise(
      key: 'lateral_raise',
      name: 'Side Lateral Raise',
      category: 'Shoulders',
      difficulty: 'Beginner',
      targetMuscles: 'Lateral Deltoids, Trapezius',
      description: 'Shoulder isolation movement building width and scapular endurance.',
      instructions: [
        'Stand with slight forward lean holding weights at sides.',
        'Raise arms laterally until parallel to floor at 90 degrees.',
        'Control the descent back to starting position.'
      ],
      commonMistakes: [
        'Using body momentum to swing weights',
        'Raising arms above shoulder level'
      ],
      caloriesPerRep: 0.30,
    ),
  ];
}
