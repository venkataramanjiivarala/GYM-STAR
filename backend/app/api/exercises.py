from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from typing import List
from app.core.database import get_db
from app.models.models import Exercise
from app.schemas.schemas import ExerciseSchema

router = APIRouter(prefix="/exercises", tags=["Exercise Engine"])

SEED_EXERCISES = [
    {
        "key": "squat",
        "name": "Bodyweight Squat",
        "category": "Legs",
        "difficulty": "Beginner",
        "target_muscles": "Quadriceps, Glutes, Hamstrings, Core",
        "description": "Fundamental lower-body compound exercise that builds leg strength and hip mobility.",
        "instructions": [
            "Stand with feet shoulder-width apart, toes pointed slightly outward.",
            "Keep your chest upright and core braced.",
            "Lower your hips down and back until knees reach approximately 90 degrees.",
            "Drive through your heels to return to standing position."
        ],
        "common_mistakes": [
            "Knees caving inward (valgus collapse)",
            "Rounding the lower back",
            "Lifting heels off the ground"
        ],
        "calories_per_rep": 0.45,
        "rules_config": {
            "primary_angle": "knee_angle",
            "bottom_threshold": 95,
            "top_threshold": 155,
            "required_landmarks": ["LEFT_HIP", "LEFT_KNEE", "LEFT_ANKLE", "LEFT_SHOULDER"]
        }
    },
    {
        "key": "pushup",
        "name": "Classic Push-Up",
        "category": "Chest",
        "difficulty": "Beginner",
        "target_muscles": "Pectorals, Triceps, Anterior Deltoids, Core",
        "description": "Essential upper-body pushing movement strengthening chest, arms, and core stability.",
        "instructions": [
            "Place hands slightly wider than shoulder-width apart in a rigid high plank position.",
            "Keep body in a straight line from crown of head to heels.",
            "Lower chest until elbows reach 90 degrees.",
            "Push firmly back up to full arm extension."
        ],
        "common_mistakes": [
            "Hips sagging down or arching too high",
            "Elbows flaring excessively at 90 degrees to torso",
            "Incomplete depth"
        ],
        "calories_per_rep": 0.5,
        "rules_config": {
            "primary_angle": "elbow_angle",
            "bottom_threshold": 90,
            "top_threshold": 155,
            "required_landmarks": ["LEFT_SHOULDER", "LEFT_ELBOW", "LEFT_WRIST", "LEFT_HIP"]
        }
    },
    {
        "key": "bicep_curl",
        "name": "Standing Bicep Curl",
        "category": "Arms",
        "difficulty": "Beginner",
        "target_muscles": "Biceps Brachii, Brachialis",
        "description": "Isolated arm exercise building biceps peak and elbow flexion strength.",
        "instructions": [
            "Stand tall holding resistance or dumbbells with palm facing forward.",
            "Keep upper arms pinned stationary by your ribcage.",
            "Curl palms upward towards shoulders contracting biceps.",
            "Lower back down with smooth controlled eccentric motion."
        ],
        "common_mistakes": [
            "Swinging shoulders or momentum",
            "Elbows moving forward away from torso"
        ],
        "calories_per_rep": 0.35,
        "rules_config": {
            "primary_angle": "elbow_angle",
            "top_threshold": 55,
            "bottom_threshold": 145
        }
    },
    {
        "key": "lunge",
        "name": "Forward Lunge",
        "category": "Legs",
        "difficulty": "Intermediate",
        "target_muscles": "Quadriceps, Glutes, Hamstrings, Calves",
        "description": "Unilateral leg exercise developing single-leg stability, strength, and hip flexibility.",
        "instructions": [
            "Step forward with one leg and lower hips until both knees are bent at 90-degree angles.",
            "Keep front knee tracking over ankle, back knee hovering just off the ground.",
            "Push off front foot to return to standing position."
        ],
        "common_mistakes": [
            "Front knee collapsing inward",
            "Torso leaning excessively forward"
        ],
        "calories_per_rep": 0.48,
        "rules_config": {
            "primary_angle": "knee_angle",
            "bottom_threshold": 95
        }
    },
    {
        "key": "plank",
        "name": "Isometric Forearm Plank",
        "category": "Core",
        "difficulty": "Beginner",
        "target_muscles": "Rectus Abdominis, Obliques, Transverse Abdominis",
        "description": "Core stability hold strengthening deep abdominal wall and spine stabilizers.",
        "instructions": [
            "Place forearms on ground with elbows directly under shoulders.",
            "Extend legs straight behind with toes tucked.",
            "Maintain a perfectly straight horizontal line from shoulders to ankles."
        ],
        "common_mistakes": [
            "Hips drooping down toward ground",
            "Piking hips up into inverted V"
        ],
        "calories_per_rep": 0.15,
        "rules_config": {
            "primary_angle": "hip_angle",
            "target_range": [160, 190]
        }
    },
    {
        "key": "overhead_press",
        "name": "Dumbbell Overhead Press",
        "category": "Shoulders",
        "difficulty": "Intermediate",
        "target_muscles": "Anterior & Lateral Deltoids, Triceps, Trapezius",
        "description": "Vertical pressing exercise that develops overhead strength and shoulder stability.",
        "instructions": [
            "Hold weights at shoulder height with palms facing forward.",
            "Press overhead until arms are fully extended without arching back.",
            "Lower slowly with control back to shoulder level."
        ],
        "common_mistakes": [
            "Excessive lower back arching",
            "Incomplete extension overhead"
        ],
        "calories_per_rep": 0.42,
        "rules_config": {
            "primary_angle": "elbow_angle",
            "top_threshold": 165,
            "bottom_threshold": 85
        }
    },
    {
        "key": "lateral_raise",
        "name": "Side Lateral Raise",
        "category": "Shoulders",
        "difficulty": "Beginner",
        "target_muscles": "Lateral Deltoids, Trapezius",
        "description": "Shoulder isolation movement building width and scapular endurance.",
        "instructions": [
            "Stand with slight forward lean holding weights at sides.",
            "Raise arms laterally until parallel to floor at 90 degrees.",
            "Control the descent back to starting position."
        ],
        "common_mistakes": [
            "Using body momentum to swing weights",
            "Raising arms above shoulder level"
        ],
        "calories_per_rep": 0.3,
        "rules_config": {
            "primary_angle": "shoulder_angle",
            "top_threshold": 90,
            "bottom_threshold": 25
        }
    }
]

def seed_exercise_db(db: Session):
    for item in SEED_EXERCISES:
        existing = db.query(Exercise).filter(Exercise.key == item["key"]).first()
        if not existing:
            ex = Exercise(**item)
            db.add(ex)
    db.commit()

@router.get("", response_model=List[ExerciseSchema])
def get_exercises(
    category: str = None,
    q: str = None,
    db: Session = Depends(get_db)
):
    seed_exercise_db(db)
    query = db.query(Exercise)
    if category and category.lower() != "all":
        query = query.filter(Exercise.category.ilike(f"%{category}%"))
    if q:
        query = query.filter(
            (Exercise.name.ilike(f"%{q}%")) |
            (Exercise.target_muscles.ilike(f"%{q}%")) |
            (Exercise.description.ilike(f"%{q}%"))
        )
    return query.all()

@router.get("/{key}", response_model=ExerciseSchema)
def get_exercise_by_key(key: str, db: Session = Depends(get_db)):
    seed_exercise_db(db)
    ex = db.query(Exercise).filter(Exercise.key == key).first()
    if not ex:
        ex = db.query(Exercise).first()
    return ex
