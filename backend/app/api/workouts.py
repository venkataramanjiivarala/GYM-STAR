from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from app.core.database import get_db
from app.api.users import get_current_user
from app.models.models import User, WorkoutSession, ExerciseSession, ProgressRecord
from app.schemas.schemas import WorkoutSessionCreate, WorkoutSessionResponse

router = APIRouter(prefix="/workouts", tags=["Workout Management"])

@router.post("/complete", response_model=WorkoutSessionResponse)
def complete_workout_session(
    payload: WorkoutSessionCreate,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    session = WorkoutSession(
        user_id=user.id,
        workout_type=payload.workout_type,
        total_duration_sec=payload.total_duration_sec,
        total_calories=payload.total_calories,
        avg_form_score=payload.avg_form_score
    )
    db.add(session)
    db.commit()
    db.refresh(session)

    total_reps = 0
    for ex in payload.exercises:
        total_reps += ex.total_reps
        ex_sess = ExerciseSession(
            workout_session_id=session.id,
            exercise_key=ex.exercise_key,
            exercise_name=ex.exercise_name,
            total_reps=ex.total_reps,
            correct_reps=ex.correct_reps,
            incorrect_reps=ex.incorrect_reps,
            avg_form_score=ex.avg_form_score
        )
        db.add(ex_sess)

    # Update or create daily progress record
    prog = db.query(ProgressRecord).filter(ProgressRecord.user_id == user.id).order_by(ProgressRecord.date.desc()).first()
    if prog:
        prog.workouts_completed += 1
        prog.total_reps += total_reps
        prog.calories_burned += payload.total_calories
        prog.avg_form_score = round((prog.avg_form_score + payload.avg_form_score) / 2.0, 1)
        prog.streak_count += 1
    else:
        prog = ProgressRecord(
            user_id=user.id,
            workouts_completed=1,
            total_reps=total_reps,
            calories_burned=payload.total_calories,
            avg_form_score=payload.avg_form_score,
            streak_count=1
        )
        db.add(prog)

    db.commit()
    return session

@router.get("/history", response_model=List[WorkoutSessionResponse])
def get_workout_history(
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    return db.query(WorkoutSession).filter(WorkoutSession.user_id == user.id).order_by(WorkoutSession.completed_at.desc()).limit(20).all()
