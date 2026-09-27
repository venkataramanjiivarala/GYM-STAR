const BASE_URL = 'http://localhost:8000/api/v1';

export async function fetchExercises(category = null, q = null) {
  try {
    const params = new URLSearchParams();
    if (category && category !== 'All') params.append('category', category);
    if (q) params.append('q', q);
    const queryStr = params.toString() ? `?${params.toString()}` : '';

    const res = await fetch(`${BASE_URL}/exercises${queryStr}`);
    if (!res.ok) throw new Error('Failed to fetch exercises');
    return await res.json();
  } catch (err) {
    console.warn('Backend offline, returning fallback exercise data', err);
    return [
      {
        id: 'ex_1',
        key: 'squat',
        name: 'Bodyweight Squat',
        category: 'Legs',
        difficulty: 'Beginner',
        target_muscles: 'Quadriceps, Glutes, Core',
        description: 'Fundamental lower-body compound exercise that builds leg strength and hip mobility.',
        instructions: [
          'Stand with feet shoulder-width apart, toes pointed slightly outward.',
          'Keep your chest upright and core braced.',
          'Lower your hips down and back until knees reach ~90 degrees.',
          'Drive through your heels to return to standing position.'
        ],
        common_mistakes: [
          'Knees caving inward (valgus collapse)',
          'Rounding the lower back',
          'Lifting heels off the ground'
        ],
        calories_per_rep: 0.45,
        rules_config: { primary_angle: 'knee_angle', bottom_threshold: 95 }
      },
      {
        id: 'ex_2',
        key: 'pushup',
        name: 'Classic Push-Up',
        category: 'Chest',
        difficulty: 'Beginner',
        target_muscles: 'Pectorals, Triceps, Core',
        description: 'Essential upper-body pressing movement strengthening chest, arms, and core stability.',
        instructions: [
          'Place hands slightly wider than shoulder-width in a rigid high plank.',
          'Keep body in a straight line from crown of head to heels.',
          'Lower chest until elbows reach 90 degrees.',
          'Push firmly back up to full arm extension.'
        ],
        common_mistakes: [
          'Hips sagging down or arching too high',
          'Elbows flaring at 90 degrees to torso',
          'Incomplete depth'
        ],
        calories_per_rep: 0.5,
        rules_config: { primary_angle: 'elbow_angle', bottom_threshold: 90 }
      },
      {
        id: 'ex_3',
        key: 'bicep_curl',
        name: 'Standing Bicep Curl',
        category: 'Arms',
        difficulty: 'Beginner',
        target_muscles: 'Biceps Brachii, Forearms',
        description: 'Isolated arm exercise building biceps peak and elbow flexion strength.',
        instructions: [
          'Stand tall holding resistance with palms facing forward.',
          'Keep upper arms pinned stationary by your ribcage.',
          'Curl palms upward towards shoulders contracting biceps.',
          'Lower back down with smooth controlled eccentric motion.'
        ],
        common_mistakes: [
          'Swinging shoulders or using momentum',
          'Elbows moving forward away from torso'
        ],
        calories_per_rep: 0.35,
        rules_config: { primary_angle: 'elbow_angle', top_threshold: 55 }
      },
      {
        id: 'ex_4',
        key: 'lunge',
        name: 'Forward Lunge',
        category: 'Legs',
        difficulty: 'Intermediate',
        target_muscles: 'Quadriceps, Glutes, Calves',
        description: 'Unilateral leg exercise developing single-leg stability, strength, and hip flexibility.',
        instructions: [
          'Step forward with one leg and lower hips until both knees bend at 90 degrees.',
          'Keep front knee tracking over ankle, back knee hovering off ground.',
          'Push off front foot to return to standing.'
        ],
        common_mistakes: [
          'Front knee collapsing inward',
          'Torso leaning excessively forward'
        ],
        calories_per_rep: 0.48,
        rules_config: { primary_angle: 'knee_angle', bottom_threshold: 95 }
      },
      {
        id: 'ex_5',
        key: 'plank',
        name: 'Isometric Forearm Plank',
        category: 'Core',
        difficulty: 'Beginner',
        target_muscles: 'Rectus Abdominis, Obliques, Core',
        description: 'Core stability hold strengthening deep abdominal wall and spine stabilizers.',
        instructions: [
          'Place forearms on ground with elbows directly under shoulders.',
          'Extend legs straight behind with toes tucked.',
          'Maintain a perfectly straight horizontal line from shoulders to ankles.'
        ],
        common_mistakes: [
          'Hips drooping down toward ground',
          'Piking hips up into inverted V'
        ],
        calories_per_rep: 0.15,
        rules_config: { primary_angle: 'hip_angle', target_range: [160, 190] }
      },
      {
        id: 'ex_6',
        key: 'overhead_press',
        name: 'Dumbbell Overhead Press',
        category: 'Shoulders',
        difficulty: 'Intermediate',
        target_muscles: 'Deltoids, Triceps, Trapezius',
        description: 'Vertical pressing exercise that develops overhead strength and shoulder stability.',
        instructions: [
          'Hold weights at shoulder height with palms forward.',
          'Press overhead until arms are extended without arching lower back.',
          'Lower with control back to shoulder level.'
        ],
        common_mistakes: ['Excessive back arching', 'Incomplete extension'],
        calories_per_rep: 0.42,
        rules_config: { primary_angle: 'elbow_angle', top_threshold: 165 }
      }
    ];
  }
}

export async function fetchExerciseByKey(key) {
  try {
    const res = await fetch(`${BASE_URL}/exercises/${key}`);
    if (!res.ok) throw new Error('Failed to fetch exercise');
    return await res.json();
  } catch (err) {
    const list = await fetchExercises();
    return list.find(e => e.key === key) || list[0];
  }
}

export async function fetchYogaPoses(category = null, q = null) {
  try {
    const params = new URLSearchParams();
    if (category && category !== 'All') params.append('category', category);
    if (q) params.append('q', q);
    const queryStr = params.toString() ? `?${params.toString()}` : '';

    const res = await fetch(`${BASE_URL}/yoga${queryStr}`);
    if (!res.ok) throw new Error('Failed to fetch yoga poses');
    return await res.json();
  } catch (err) {
    console.warn('Backend offline, returning fallback yoga data', err);
    return [
      {
        id: 'yg_1',
        key: 'tree_pose',
        name: 'Tree Pose',
        sanskrit_name: 'Vrikshasana',
        category: 'Balance & Focus',
        difficulty: 'Beginner',
        description: 'Standing balance pose strengthening ankle stability, pelvic balance, and mental focus.',
        benefits: ['Improves physical balance', 'Strengthens thighs and ankles', 'Calms mind'],
        hold_duration_sec: 30
      },
      {
        id: 'yg_2',
        key: 'warrior_2',
        name: 'Warrior II Pose',
        sanskrit_name: 'Virabhadrasana II',
        category: 'Strength & Stamina',
        difficulty: 'Intermediate',
        description: 'Powerful standing stance building hip openness, leg stamina, and arm extension.',
        benefits: ['Strengthens legs and core', 'Opens hips and lungs', 'Boosts stamina'],
        hold_duration_sec: 45
      },
      {
        id: 'yg_3',
        key: 'downward_dog',
        name: 'Downward-Facing Dog',
        sanskrit_name: 'Adho Mukha Svanasana',
        category: 'Flexibility & Energy',
        difficulty: 'Beginner',
        description: 'Inverted V pose lengthening posterior hamstrings, calves, and shoulders.',
        benefits: ['Stretches hamstrings and shoulders', 'Energizes the entire body'],
        hold_duration_sec: 45
      },
      {
        id: 'yg_4',
        key: 'cobra_pose',
        name: 'Cobra Pose',
        sanskrit_name: 'Bhujangasana',
        category: 'Back Flexibility & Relief',
        difficulty: 'Beginner',
        description: 'Gentle backbend expanding chest cavity and strengthening spine extensors.',
        benefits: ['Strengthens spine', 'Opens chest and shoulders', 'Relieves stiffness'],
        hold_duration_sec: 30
      },
      {
        id: 'yg_5',
        key: 'triangle_pose',
        name: 'Extended Triangle Pose',
        sanskrit_name: 'Utthita Trikonasana',
        category: 'Flexibility & Energy',
        difficulty: 'Intermediate',
        description: 'Standing lateral stretch lengthening hamstrings, opening chest, and relieving tension.',
        benefits: ['Stretches groins and hamstrings', 'Opens chest', 'Improves digestion'],
        hold_duration_sec: 30
      },
      {
        id: 'yg_6',
        key: 'bridge_pose',
        name: 'Bridge Pose',
        sanskrit_name: 'Setu Bandha Sarvangasana',
        category: 'Strength & Stamina',
        difficulty: 'Beginner',
        description: 'Supine backbend strengthening glutes, spine, and opening the chest.',
        benefits: ['Strengthens back and glutes', 'Rejuvenates tired legs', 'Relieves stress'],
        hold_duration_sec: 35
      }
    ];
  }
}

export async function fetchYogaPoseByKey(key) {
  try {
    const res = await fetch(`${BASE_URL}/yoga/${key}`);
    if (!res.ok) throw new Error('Failed to fetch yoga pose');
    return await res.json();
  } catch (err) {
    const list = await fetchYogaPoses();
    return list.find(y => y.key === key) || list[0];
  }
}

export async function fetchDashboardAnalytics() {
  try {
    const res = await fetch(`${BASE_URL}/analytics/dashboard`);
    if (!res.ok) throw new Error('Failed to fetch analytics');
    return await res.json();
  } catch (err) {
    return {
      total_workouts: 14,
      total_reps: 397,
      total_calories: 1850.0,
      avg_form_score: 94.5,
      streak_days: 7,
      weekly_form_trend: [
        { day: 'Mon', form_score: 78, reps: 32, calories: 140 },
        { day: 'Tue', form_score: 81, reps: 45, calories: 190 },
        { day: 'Wed', form_score: 85, reps: 50, calories: 210 },
        { day: 'Thu', form_score: 88, reps: 60, calories: 260 },
        { day: 'Fri', form_score: 92, reps: 65, calories: 320 },
        { day: 'Sat', form_score: 94, reps: 70, calories: 350 },
        { day: 'Sun', form_score: 95, reps: 75, calories: 380 }
      ],
      recent_sessions: [
        {
          id: 'sess_1',
          workout_type: 'Squat Mastery',
          total_duration_sec: 240,
          total_calories: 22.5,
          avg_form_score: 95.0,
          completed_at: new Date().toISOString()
        }
      ]
    };
  }
}

export async function saveCompletedWorkout(sessionData) {
  try {
    const res = await fetch(`${BASE_URL}/workouts/complete`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(sessionData)
    });
    if (!res.ok) throw new Error('Failed to save workout');
    return await res.json();
  } catch (err) {
    console.warn('Backend save workout failed, returning local receipt', err);
    return {
      id: 'local_' + Date.now(),
      ...sessionData,
      completed_at: new Date().toISOString()
    };
  }
}

export async function fetchWorkoutHistory() {
  try {
    const res = await fetch(`${BASE_URL}/workouts/history`);
    if (!res.ok) throw new Error('Failed to fetch workout history');
    return await res.json();
  } catch (err) {
    return [];
  }
}

export async function fetchUserProfile() {
  try {
    const res = await fetch(`${BASE_URL}/users/me`);
    if (!res.ok) throw new Error('Failed to fetch user profile');
    return await res.json();
  } catch (err) {
    return {
      id: 'demo_user',
      email: 'raman@gymstar.ai',
      name: 'Ramanji',
      is_active: true,
      profile: {
        age: 25,
        gender: 'unspecified',
        height_cm: 175,
        weight_kg: 70,
        fitness_level: 'Beginner',
        primary_goal: 'Strength & Form',
        workout_frequency: 4,
        equipment: 'Bodyweight',
        voice_coaching: true
      }
    };
  }
}

export async function updateUserProfile(profileData) {
  try {
    const res = await fetch(`${BASE_URL}/users/me/profile`, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(profileData)
    });
    if (!res.ok) throw new Error('Failed to update profile');
    return await res.json();
  } catch (err) {
    console.warn('Backend profile update failed, using local update', err);
    return { success: true, profile: profileData };
  }
}

export async function fetchAIPersonalizedPlan() {
  try {
    const res = await fetch(`${BASE_URL}/users/me/ai-plan`, {
      method: 'POST'
    });
    if (!res.ok) throw new Error('Failed to generate AI plan');
    return await res.json();
  } catch (err) {
    return {
      title: 'Beginner • Strength & Form AI Pathway',
      fitness_level: 'Beginner',
      primary_goal: 'Strength & Form',
      weekly_schedule: [
        { day: 'Monday', focus: 'Full Body Foundation', duration: '25 min', exercises: ['squat', 'pushup', 'plank'], type: 'Workout' },
        { day: 'Tuesday', focus: 'Morning Flexibility & Balance', duration: '20 min', exercises: ['tree_pose', 'warrior_2', 'downward_dog'], type: 'Yoga' },
        { day: 'Wednesday', focus: 'Active Recovery & Core', duration: '15 min', exercises: ['cobra_pose', 'child_pose'], type: 'Rest/Yoga' },
        { day: 'Thursday', focus: 'Lower Body & Unilateral Strength', duration: '30 min', exercises: ['squat', 'lunge', 'plank'], type: 'Workout' },
        { day: 'Friday', focus: 'Upper Body & Arms Sculpting', duration: '25 min', exercises: ['pushup', 'bicep_curl', 'overhead_press'], type: 'Workout' },
        { day: 'Saturday', focus: 'Evening Mindfulness Yoga', duration: '25 min', exercises: ['warrior_2', 'cobra_pose', 'tree_pose'], type: 'Yoga' },
        { day: 'Sunday', focus: 'Full Rest & Regeneration', duration: '0 min', exercises: [], type: 'Rest' }
      ],
      coach_tip: 'Consistency and joint alignment will accelerate your results 3x faster than speed!'
    };
  }
}

export async function sendAIChatQuery(query) {
  try {
    const res = await fetch(`${BASE_URL}/ai/chat`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ message: query, user_name: 'Ramanji' })
    });
    const data = await res.json();
    return data;
  } catch (err) {
    let reply = "I'm your GYM STAR AI Coach! Focus on smooth controlled movements and keeping your form score above 85%!";
    if (query.toLowerCase().includes('squat')) {
      reply = "**Squat Form Guide:** Keep your chest upright, push hips back first, drive through your heels, and maintain knees inline with your toes!";
    } else if (query.toLowerCase().includes('pushup') || query.toLowerCase().includes('push up')) {
      reply = "**Push-Up Blueprint:** Brace your core rigid like a plank, keep elbows at 45°, and lower chest until elbows reach 90° depth!";
    }
    return {
      reply,
      suggested_actions: [
        'How do I keep my back straight in squats?',
        'What is the 90/90 rule in lunges?',
        'How to hold Tree Pose without wobbling?'
      ]
    };
  }
}

export async function analyzePosePacket(payload) {
  try {
    const res = await fetch(`${BASE_URL}/pose/analyze`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload)
    });
    if (!res.ok) throw new Error('Pose analysis failed');
    return await res.json();
  } catch (err) {
    return null;
  }
}
