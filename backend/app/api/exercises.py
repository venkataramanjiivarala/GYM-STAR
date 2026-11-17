import os
import json
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from typing import List
from app.core.database import get_db
from app.models.models import Exercise
from app.schemas.schemas import ExerciseSchema

router = APIRouter(prefix="/exercises", tags=["Exercise Engine"])

JSON_PATH = os.path.join(os.path.dirname(__file__), "..", "core", "all_exercises.json")
if os.path.exists(JSON_PATH):
    with open(JSON_PATH, "r", encoding="utf-8") as f:
        SEED_EXERCISES = json.load(f)
else:
    SEED_EXERCISES = []

def seed_exercise_db(db: Session):
    for item in SEED_EXERCISES:
        existing = db.query(Exercise).filter(Exercise.key == item["key"]).first()
        if not existing:
            ex = Exercise(**item)
            db.add(ex)
        else:
            for k, v in item.items():
                if hasattr(existing, k):
                    setattr(existing, k, v)
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
