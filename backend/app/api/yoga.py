from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from typing import List
from app.core.database import get_db
from app.models.models import YogaPose
from app.schemas.schemas import YogaPoseSchema

router = APIRouter(prefix="/yoga", tags=["Yoga Module Engine"])

SEED_YOGA_POSES = [
    {
        "key": "tree_pose",
        "name": "Tree Pose",
        "sanskrit_name": "Vrikshasana",
        "category": "Balance & Focus",
        "difficulty": "Beginner",
        "description": "Standing balance pose strengthening ankle stability, pelvic balance, and mental focus.",
        "benefits": [
            "Improves physical balance and postural stability",
            "Strengthens thighs, calves, ankles, and spine",
            "Relieves sciatica and tones core"
        ],
        "hold_duration_sec": 30,
        "rules_config": {
            "standing_knee_min_angle": 160,
            "bent_knee_max_angle": 100
        }
    },
    {
        "key": "warrior_2",
        "name": "Warrior II Pose",
        "sanskrit_name": "Virabhadrasana II",
        "category": "Strength & Stamina",
        "difficulty": "Intermediate",
        "description": "Powerful standing stance building hip openness, leg stamina, and arm extension.",
        "benefits": [
            "Strengthens legs, ankles, and core",
            "Opens hips, chest, and lungs",
            "Increases stamina and concentration"
        ],
        "hold_duration_sec": 45,
        "rules_config": {
            "front_knee_target_angle": 90,
            "arms_horizontal_angle": 180
        }
    },
    {
        "key": "downward_dog",
        "name": "Downward-Facing Dog",
        "sanskrit_name": "Adho Mukha Svanasana",
        "category": "Flexibility & Energy",
        "difficulty": "Beginner",
        "description": "Inverted V pose lengthening posterior hamstrings, calves, and shoulders.",
        "benefits": [
            "Stretches shoulders, hamstrings, calves, and hands",
            "Energizes the entire body and calms the brain"
        ],
        "hold_duration_sec": 45,
        "rules_config": {
            "hip_peak_angle": 70,
            "knee_straightness": 170
        }
    },
    {
        "key": "cobra_pose",
        "name": "Cobra Pose",
        "sanskrit_name": "Bhujangasana",
        "category": "Back Flexibility & Relief",
        "difficulty": "Beginner",
        "description": "Gentle backbend expanding chest cavity and strengthening spine extensors.",
        "benefits": [
            "Strengthens spine and tones abdomen",
            "Opens chest and shoulders",
            "Decreases stiffness in lower back"
        ],
        "hold_duration_sec": 30,
        "rules_config": {
            "spine_extension_angle": 140
        }
    },
    {
        "key": "triangle_pose",
        "name": "Extended Triangle Pose",
        "sanskrit_name": "Utthita Trikonasana",
        "category": "Flexibility & Energy",
        "difficulty": "Intermediate",
        "description": "Standing lateral stretch lengthening hamstrings, opening chest, and relieving back tension.",
        "benefits": [
            "Stretches hips, groins, hamstrings, and calves",
            "Opens chest and shoulders",
            "Stimulates abdominal organs"
        ],
        "hold_duration_sec": 30,
        "rules_config": {
            "lead_knee_straightness": 175,
            "torso_lateral_angle": 135
        }
    },
    {
        "key": "bridge_pose",
        "name": "Bridge Pose",
        "sanskrit_name": "Setu Bandha Sarvangasana",
        "category": "Strength & Stamina",
        "difficulty": "Beginner",
        "description": "Supine backbend strengthening glutes, spine, and opening the chest.",
        "benefits": [
            "Strengthens back muscles, glutes, and thighs",
            "Calms the brain and rejuvenates tired legs",
            "Opens heart and hip flexors"
        ],
        "hold_duration_sec": 35,
        "rules_config": {
            "hip_elevation_angle": 150
        }
    },
    {
        "key": "child_pose",
        "name": "Child's Pose",
        "sanskrit_name": "Balasana",
        "category": "Back Flexibility & Relief",
        "difficulty": "Beginner",
        "description": "Restorative resting posture gently stretching lower back, hips, thighs, and ankles.",
        "benefits": [
            "Releases tension in back, neck, and shoulders",
            "Promotes relaxation and steady breathing",
            "Stretches hips and ankles"
        ],
        "hold_duration_sec": 40,
        "rules_config": {
            "hip_crease_angle": 45
        }
    }
]

def seed_yoga_db(db: Session):
    for item in SEED_YOGA_POSES:
        existing = db.query(YogaPose).filter(YogaPose.key == item["key"]).first()
        if not existing:
            pose = YogaPose(**item)
            db.add(pose)
    db.commit()

@router.get("", response_model=List[YogaPoseSchema])
def get_yoga_poses(
    category: str = None,
    q: str = None,
    db: Session = Depends(get_db)
):
    seed_yoga_db(db)
    query = db.query(YogaPose)
    if category and category.lower() != "all":
        query = query.filter(YogaPose.category.ilike(f"%{category}%"))
    if q:
        query = query.filter(
            (YogaPose.name.ilike(f"%{q}%")) |
            (YogaPose.sanskrit_name.ilike(f"%{q}%")) |
            (YogaPose.description.ilike(f"%{q}%"))
        )
    return query.all()

@router.get("/{key}", response_model=YogaPoseSchema)
def get_yoga_pose_by_key(key: str, db: Session = Depends(get_db)):
    seed_yoga_db(db)
    pose = db.query(YogaPose).filter(YogaPose.key == key).first()
    if not pose:
        pose = db.query(YogaPose).first()
    return pose
