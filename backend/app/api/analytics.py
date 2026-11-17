from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from sqlalchemy import func
from datetime import datetime, timedelta, timezone
from typing import List, Optional
from app.core.database import get_db
from app.api.users import get_current_user
from app.models.models import User, WorkoutSession, ExerciseSession, ProgressRecord
from app.schemas.schemas import ProgressDashboardSchema, WeeklyTrendItem, WorkoutSessionResponse

router = APIRouter(prefix="/analytics", tags=["Progress Analytics"])

@router.get("/dashboard", response_model=ProgressDashboardSchema)
def get_analytics_dashboard(
    timeframe: str = Query("7d", description="Timeframe: 7d, 30d, 90d, all"),
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    sessions_query = db.query(WorkoutSession).filter(WorkoutSession.user_id == user.id)
    
    # Filter by timeframe if applicable
    now = datetime.now(timezone.utc)
    if timeframe == "7d":
        start_date = now - timedelta(days=7)
        filtered_sessions = sessions_query.filter(WorkoutSession.completed_at >= start_date).all()
    elif timeframe == "30d":
        start_date = now - timedelta(days=30)
        filtered_sessions = sessions_query.filter(WorkoutSession.completed_at >= start_date).all()
    elif timeframe == "90d":
        start_date = now - timedelta(days=90)
        filtered_sessions = sessions_query.filter(WorkoutSession.completed_at >= start_date).all()
    else:
        filtered_sessions = sessions_query.all()

    all_sessions = sessions_query.order_by(WorkoutSession.completed_at.desc()).all()
    total_workouts = len(all_sessions)

    # Calculate real total reps across all exercise sessions
    reps_result = db.query(func.sum(ExerciseSession.total_reps)).join(
        WorkoutSession, ExerciseSession.workout_session_id == WorkoutSession.id
    ).filter(WorkoutSession.user_id == user.id).scalar()
    
    prog = db.query(ProgressRecord).filter(ProgressRecord.user_id == user.id).order_by(ProgressRecord.date.desc()).first()
    
    total_reps = int(reps_result) if reps_result is not None else 0
    if total_reps == 0 and prog and prog.total_reps:
        total_reps = prog.total_reps

    total_calories = round(sum(s.total_calories for s in all_sessions), 1)
    
    if all_sessions:
        avg_form_score = round(sum(s.avg_form_score for s in all_sessions) / len(all_sessions), 1)
    else:
        avg_form_score = 0.0

    # Calculate dynamic streak from distinct workout completion dates
    session_dates = sorted(
        list({s.completed_at.date() for s in all_sessions if s.completed_at}),
        reverse=True
    )
    streak_count = 0
    if session_dates:
        today = datetime.now().date()
        # If workout was today or yesterday, streak is active
        first_date = session_dates[0]
        if (today - first_date).days <= 1:
            streak_count = 1
            for i in range(len(session_dates) - 1):
                if (session_dates[i] - session_dates[i + 1]).days == 1:
                    streak_count += 1
                else:
                    break
        elif prog and prog.streak_count:
            streak_count = prog.streak_count
    elif prog and prog.streak_count:
        streak_count = prog.streak_count

    # Build weekly trend over the last 7 calendar days dynamically
    days_map = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    weekly_trend: List[WeeklyTrendItem] = []
    
    # Generate list for the last 7 days ending today
    for i in range(6, -1, -1):
        target_day = (datetime.now() - timedelta(days=i)).date()
        day_name = days_map[target_day.weekday()]
        
        # Aggregate real sessions on target_day
        day_sessions = [s for s in all_sessions if s.completed_at and s.completed_at.date() == target_day]
        day_reps = 0
        for ds in day_sessions:
            for es in ds.exercise_sessions:
                day_reps += es.total_reps
        day_cals = round(sum(s.total_calories for s in day_sessions), 1)
        day_form = round(sum(s.avg_form_score for s in day_sessions) / len(day_sessions), 1) if day_sessions else 0.0
        
        weekly_trend.append(WeeklyTrendItem(
            day=day_name,
            form_score=day_form,
            reps=day_reps,
            calories=day_cals
        ))

    recent_sessions = all_sessions[:10]

    return ProgressDashboardSchema(
        total_workouts=total_workouts,
        total_reps=total_reps,
        total_calories=total_calories,
        avg_form_score=avg_form_score,
        streak_days=streak_count,
        weekly_form_trend=weekly_trend,
        recent_sessions=recent_sessions
    )
