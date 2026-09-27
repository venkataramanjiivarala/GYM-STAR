from typing import Dict, Any, List

class AICoachingEngine:
    def generate_personalized_plan(self, profile_data: Dict[str, Any]) -> Dict[str, Any]:
        """
        Generates custom weekly workout & yoga plan based on user onboarding choices.
        """
        fitness_level = profile_data.get("fitness_level", "Beginner")
        primary_goal = profile_data.get("primary_goal", "Strength & Form")

        if "weight" in primary_goal.lower() or "fat" in primary_goal.lower():
            schedule = [
                {"day": "Monday", "focus": "HIIT Lower Body & Core", "duration": "30 min", "exercises": ["squat", "lunge", "plank"], "type": "HIIT"},
                {"day": "Tuesday", "focus": "Cardio Core & Upper Body", "duration": "25 min", "exercises": ["pushup", "overhead_press", "plank"], "type": "HIIT"},
                {"day": "Wednesday", "focus": "Active Recovery Flow", "duration": "20 min", "exercises": ["downward_dog", "child_pose"], "type": "Yoga"},
                {"day": "Thursday", "focus": "Total Body Circuit", "duration": "30 min", "exercises": ["squat", "pushup", "bicep_curl", "lunge"], "type": "Circuit"},
                {"day": "Friday", "focus": "Core Endurance & Mobility", "duration": "25 min", "exercises": ["plank", "tree_pose", "warrior_2"], "type": "Yoga/Core"},
                {"day": "Saturday", "focus": "High Intensity Interval Flow", "duration": "25 min", "exercises": ["squat", "lateral_raise"], "type": "HIIT"},
                {"day": "Sunday", "focus": "Full Body Rest & Restoration", "duration": "0 min", "exercises": [], "type": "Rest"}
            ]
        elif "flexibility" in primary_goal.lower() or "yoga" in primary_goal.lower():
            schedule = [
                {"day": "Monday", "focus": "Morning Vinyasa Alignment", "duration": "25 min", "exercises": ["tree_pose", "warrior_2", "downward_dog"], "type": "Yoga"},
                {"day": "Tuesday", "focus": "Spine & Core Mobility", "duration": "20 min", "exercises": ["cobra_pose", "child_pose", "plank"], "type": "Yoga"},
                {"day": "Wednesday", "focus": "Balance & Grounding", "duration": "25 min", "exercises": ["tree_pose", "triangle_pose"], "type": "Yoga"},
                {"day": "Thursday", "focus": "Posterior Chain Stretch & Flow", "duration": "30 min", "exercises": ["downward_dog", "bridge_pose"], "type": "Yoga"},
                {"day": "Friday", "focus": "Upper Body Openers & Breath", "duration": "20 min", "exercises": ["cobra_pose", "child_pose"], "type": "Yoga"},
                {"day": "Saturday", "focus": "Deep Hip & Ankle Restoration", "duration": "30 min", "exercises": ["warrior_2", "triangle_pose", "bridge_pose"], "type": "Yoga"},
                {"day": "Sunday", "focus": "Mindful Meditation & Rest", "duration": "0 min", "exercises": [], "type": "Rest"}
            ]
        elif "muscle" in primary_goal.lower() or "hypertrophy" in primary_goal.lower():
            schedule = [
                {"day": "Monday", "focus": "Chest & Triceps Hypertrophy", "duration": "35 min", "exercises": ["pushup", "overhead_press"], "type": "Strength"},
                {"day": "Tuesday", "focus": "Quads & Glutes Volume", "duration": "35 min", "exercises": ["squat", "lunge"], "type": "Strength"},
                {"day": "Wednesday", "focus": "Active Recovery & Mobility", "duration": "15 min", "exercises": ["downward_dog", "cobra_pose"], "type": "Rest/Yoga"},
                {"day": "Thursday", "focus": "Back & Biceps Focus", "duration": "35 min", "exercises": ["bicep_curl", "plank"], "type": "Strength"},
                {"day": "Friday", "focus": "Shoulders & Core Stability", "duration": "30 min", "exercises": ["lateral_raise", "overhead_press", "plank"], "type": "Strength"},
                {"day": "Saturday", "focus": "Full Body Compound Burnout", "duration": "30 min", "exercises": ["squat", "pushup", "lunge"], "type": "Strength"},
                {"day": "Sunday", "focus": "Nutritional Recovery & Rest", "duration": "0 min", "exercises": [], "type": "Rest"}
            ]
        else:
            schedule = [
                {"day": "Monday", "focus": "Full Body Foundation", "duration": "25 min", "exercises": ["squat", "pushup", "plank"], "type": "Workout"},
                {"day": "Tuesday", "focus": "Morning Flexibility & Balance", "duration": "20 min", "exercises": ["tree_pose", "warrior_2", "downward_dog"], "type": "Yoga"},
                {"day": "Wednesday", "focus": "Active Recovery & Core", "duration": "15 min", "exercises": ["cobra_pose", "child_pose"], "type": "Rest/Yoga"},
                {"day": "Thursday", "focus": "Lower Body & Unilateral Strength", "duration": "30 min", "exercises": ["squat", "lunge", "plank"], "type": "Workout"},
                {"day": "Friday", "focus": "Upper Body & Arms Sculpting", "duration": "25 min", "exercises": ["pushup", "bicep_curl", "overhead_press"], "type": "Workout"},
                {"day": "Saturday", "focus": "Evening Mindfulness Yoga", "duration": "25 min", "exercises": ["warrior_2", "cobra_pose", "tree_pose"], "type": "Yoga"},
                {"day": "Sunday", "focus": "Full Rest & Regeneration", "duration": "0 min", "exercises": [], "type": "Rest"}
            ]

        tip = f"As an athlete at the {fitness_level} tier targeting {primary_goal}, prioritize joint alignment over tempo. Maintain your Form Score above 85% for fastest progressive overload!"

        return {
            "title": f"{fitness_level} • {primary_goal} AI Pathway",
            "fitness_level": fitness_level,
            "primary_goal": primary_goal,
            "weekly_schedule": schedule,
            "coach_tip": tip
        }

    def chat_response(self, user_query: str, user_name: str = "Athlete") -> str:
        """
        AI Coach conversation response builder based on user workout query context.
        """
        query_lower = user_query.lower()
        if "squat" in query_lower:
            return (
                f"**Hey {user_name}! Here are key cues for squats:**\n\n"
                "• **Stance:** Feet shoulder-width apart, toes turned outward 15–30 degrees.\n"
                "• **Descent:** Push hips back first, maintaining an upright chest.\n"
                "• **Knee Angle:** Aim for ≤ 90° depth without your knees collapsing inward (valgus).\n"
                "• **Ascent:** Drive firmly through mid-foot and heels while squeezing glutes at the top!"
            )
        elif "pushup" in query_lower or "push up" in query_lower or "chest" in query_lower:
            return (
                f"**Push-up Form Blueprint for {user_name}:**\n\n"
                "• **Core Brace:** Lock your pelvis to prevent hips from drooping.\n"
                "• **Elbow Flare:** Keep elbows tucked at 45° relative to your torso (arrow shape, not T-shape).\n"
                "• **Full ROM:** Lower until chest hovers an inch above ground (90° elbow bend), then lock out smoothly."
            )
        elif "bicep" in query_lower or "curl" in query_lower or "arm" in query_lower:
            return (
                f"**Bicep Curl Technique Guide:**\n\n"
                "• **Elbow Anchor:** Pin your upper arms firmly to your ribcage. Do NOT swing your shoulders!\n"
                "• **Peak Contraction:** Squeeze at the top for a full 1-second hold.\n"
                "• **Controlled Eccentric:** Take 2 full seconds lowering down to maximize muscle recruitment."
            )
        elif "plank" in query_lower or "core" in query_lower or "abs" in query_lower:
            return (
                f"**Plank Stability Cues:**\n\n"
                "• **Shoulder Stack:** Elbows directly under shoulders.\n"
                "• **Neutral Spine:** Eyes focused down; keep ears, shoulders, hips, and ankles in one straight diagonal plane.\n"
                "• **Anti-Sag:** Squeeze glutes and draw belly button inward toward your spine."
            )
        elif "lunge" in query_lower:
            return (
                f"**Lunge Alignment for {user_name}:**\n\n"
                "• **90/90 Rule:** Both front and back knees should reach 90° bends at bottom depth.\n"
                "• **Knee Tracking:** Ensure front knee does NOT track beyond toes or cave inward.\n"
                "• **Torso:** Keep spine vertical and core braced."
            )
        elif "yoga" in query_lower or "flexibility" in query_lower or "tree pose" in query_lower or "warrior" in query_lower:
            return (
                f"**Yoga & Stability Coaching for {user_name}:**\n\n"
                "• **Breath-Movement Sync:** Inhale when expanding or lifting; exhale when deepening into a fold or stance.\n"
                "• **Grounding:** In Tree Pose and Warrior II, spread all 5 toes to create an active arch and stabilize your ankle.\n"
                "• **Hold Goals:** Start with 30s holds, aiming for calm heart rate and zero joint strain."
            )
        elif "form" in query_lower or "score" in query_lower or "accuracy" in query_lower:
            return (
                f"**Understanding Your Form Score:**\n\n"
                "• **90% – 100%:** Optimal biometric angle execution with balanced bilateral symmetry.\n"
                "• **80% – 89%:** Good reps with minor joint deviations.\n"
                "• **Under 80%:** The AI Coach will chime in with live voice feedback (e.g., 'Straighten back', 'Go lower')."
            )
        elif "calorie" in query_lower or "nutrition" in query_lower or "diet" in query_lower:
            return (
                f"**Caloric & Nutrition Tips for {user_name}:**\n\n"
                "• **Protein Intake:** Aim for 1.6–2.2g of protein per kg of bodyweight to support muscle recovery.\n"
                "• **Hydration:** Drink at least 500ml of water before training sessions to maintain muscular hydration and joint lubrication.\n"
                "• **Energy Balance:** High form accuracy during compound lifts burns up to 25% more metabolic calories!"
            )
        elif "routine" in query_lower or "plan" in query_lower or "schedule" in query_lower:
            return (
                f"**AI Pathway Recommendation for {user_name}:**\n\n"
                "I've tailored a structured 7-day routine in your Profile settings! Try starting today's session from the Home Dashboard to log your streak and joint precision score."
            )
        else:
            return (
                f"Hey {user_name}! I'm your GYM STAR AI Fitness Coach. 🏋️‍♂️\n\n"
                "I can assist you with:\n"
                "• **Exercise Form & Joint Angles** (Squats, Push-ups, Curls, Lunges, Planks)\n"
                "• **Yoga Postures & Balance Tracking** (Tree Pose, Warrior II, Downward Dog, Cobra)\n"
                "• **Customized Routine Planning** and Progressive Overload\n"
                "• **Live Camera Coach Guidance & Tips**\n\n"
                "What movement or fitness goal would you like to master today?"
            )

ai_coach_engine = AICoachingEngine()

