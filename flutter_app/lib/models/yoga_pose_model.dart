class YogaPose {
  final String key;
  final String name;
  final String sanskritName;
  final String category;
  final String difficulty;
  final String description;
  final List<String> benefits;
  final int holdDurationSec;
  final Map<String, dynamic>? rulesConfig;

  YogaPose({
    required this.key,
    required this.name,
    required this.sanskritName,
    required this.category,
    required this.difficulty,
    required this.description,
    required this.benefits,
    required this.holdDurationSec,
    this.rulesConfig,
  });

  factory YogaPose.fromJson(Map<String, dynamic> json) {
    return YogaPose(
      key: json['key'] ?? '',
      name: json['name'] ?? '',
      sanskritName: json['sanskrit_name'] ?? '',
      category: json['category'] ?? 'Balance & Focus',
      difficulty: json['difficulty'] ?? 'Beginner',
      description: json['description'] ?? '',
      benefits: json['benefits'] != null
          ? List<String>.from(json['benefits'])
          : [],
      holdDurationSec: json['hold_duration_sec'] ?? 30,
      rulesConfig: json['rules_config'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'name': name,
      'sanskrit_name': sanskritName,
      'category': category,
      'difficulty': difficulty,
      'description': description,
      'benefits': benefits,
      'hold_duration_sec': holdDurationSec,
      'rules_config': rulesConfig,
    };
  }

  static List<YogaPose> get fallbackYogaPoses => [
    YogaPose(
      key: 'tree_pose',
      name: 'Tree Pose',
      sanskritName: 'Vrikshasana',
      category: 'Balance & Focus',
      difficulty: 'Beginner',
      description: 'Standing balance pose strengthening ankle stability, pelvic balance, and mental focus.',
      benefits: [
        'Improves physical balance and postural stability',
        'Strengthens thighs, calves, ankles, and spine',
        'Relieves sciatica and tones core'
      ],
      holdDurationSec: 30,
    ),
    YogaPose(
      key: 'warrior_2',
      name: 'Warrior II Pose',
      sanskritName: 'Virabhadrasana II',
      category: 'Strength & Stamina',
      difficulty: 'Intermediate',
      description: 'Powerful standing stance building hip openness, leg stamina, and arm extension.',
      benefits: [
        'Strengthens legs, ankles, and core',
        'Opens hips, chest, and lungs',
        'Increases stamina and concentration'
      ],
      holdDurationSec: 45,
    ),
    YogaPose(
      key: 'downward_dog',
      name: 'Downward-Facing Dog',
      sanskritName: 'Adho Mukha Svanasana',
      category: 'Flexibility & Energy',
      difficulty: 'Beginner',
      description: 'Inverted V pose lengthening posterior hamstrings, calves, and shoulders.',
      benefits: [
        'Stretches shoulders, hamstrings, calves, and hands',
        'Energizes the entire body and calms the brain'
      ],
      holdDurationSec: 45,
    ),
    YogaPose(
      key: 'cobra_pose',
      name: 'Cobra Pose',
      sanskritName: 'Bhujangasana',
      category: 'Back Flexibility',
      difficulty: 'Beginner',
      description: 'Gentle backbend expanding chest cavity and strengthening spine extensors.',
      benefits: [
        'Strengthens spine and tones abdomen',
        'Opens chest and shoulders',
        'Decreases stiffness in lower back'
      ],
      holdDurationSec: 30,
    ),
    YogaPose(
      key: 'triangle_pose',
      name: 'Extended Triangle Pose',
      sanskritName: 'Utthita Trikonasana',
      category: 'Flexibility & Energy',
      difficulty: 'Intermediate',
      description: 'Standing lateral stretch lengthening hamstrings, opening chest, and relieving back tension.',
      benefits: [
        'Stretches hips, groins, hamstrings, and calves',
        'Opens chest and shoulders',
        'Stimulates abdominal organs'
      ],
      holdDurationSec: 30,
    ),
    YogaPose(
      key: 'bridge_pose',
      name: 'Bridge Pose',
      sanskritName: 'Setu Bandha Sarvangasana',
      category: 'Strength & Stamina',
      difficulty: 'Beginner',
      description: 'Supine backbend strengthening glutes, spine, and opening the chest.',
      benefits: [
        'Strengthens back muscles, glutes, and thighs',
        'Calms the brain and rejuvenates tired legs',
        'Opens heart and hip flexors'
      ],
      holdDurationSec: 35,
    ),
    YogaPose(
      key: 'child_pose',
      name: "Child's Pose",
      sanskritName: 'Balasana',
      category: 'Back Flexibility',
      difficulty: 'Beginner',
      description: 'Restorative resting posture gently stretching lower back, hips, thighs, and ankles.',
      benefits: [
        'Releases tension in back, neck, and shoulders',
        'Promotes relaxation and steady breathing',
        'Stretches hips and ankles'
      ],
      holdDurationSec: 40,
    ),
  ];
}
