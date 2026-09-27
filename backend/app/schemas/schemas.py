from pydantic import BaseModel, EmailStr, Field, ConfigDict
from typing import Optional, List, Dict, Any
from datetime import datetime

# ================= AUTH SCHEMAS =================
class UserRegister(BaseModel):
    email: EmailStr
    name: str
    password: str

class UserLogin(BaseModel):
    email: EmailStr
    password: str

class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user_id: str
    name: str
    email: str

# ================= PROFILE SCHEMAS =================
class UserProfileSchema(BaseModel):
    age: int = 25
    gender: str = "unspecified"
    height_cm: float = 175.0
    weight_kg: float = 70.0
    fitness_level: str = "Beginner"
    primary_goal: str = "Strength & Form"
    workout_frequency: int = 4
    equipment: str = "Bodyweight"
    voice_coaching: bool = True

class UserProfileResponse(UserProfileSchema):
    id: str
    user_id: str
    updated_at: Optional[datetime] = None

    model_config = ConfigDict(from_attributes=True)

class UserResponse(BaseModel):
    id: str
    email: str
    name: str
    is_active: bool
    created_at: datetime
    profile: Optional[UserProfileResponse] = None

    model_config = ConfigDict(from_attributes=True)

# ================= EXERCISE & YOGA SCHEMAS =================
class ExerciseSchema(BaseModel):
    id: str
    key: str
    name: str
    category: str
    difficulty: str
    target_muscles: str
    description: str
    instructions: List[str] = []
    common_mistakes: List[str] = []
    calories_per_rep: float = 0.45
    rules_config: Dict[str, Any] = {}

    model_config = ConfigDict(from_attributes=True)

class YogaPoseSchema(BaseModel):
    id: str
    key: str
    name: str
    sanskrit_name: Optional[str] = ""
    category: str
    difficulty: str
    description: str
    benefits: List[str] = []
    hold_duration_sec: int = 30
    rules_config: Dict[str, Any] = {}

    model_config = ConfigDict(from_attributes=True)

# ================= REAL-TIME POSE PACKETS =================
class LandmarkPoint(BaseModel):
    name: Optional[str] = None
    x: float
    y: float
    z: float = 0.0
    visibility: float = 1.0

class PoseFramePayload(BaseModel):
    exercise_key: str = "squat"
    landmarks: Dict[str, LandmarkPoint]
    is_yoga: bool = False

class PoseAnalysisResult(BaseModel):
    exercise_key: str
    rep_count: int
    rep_state: str
    form_score: float
    status: str  # GOOD, WARNING, INCORRECT
    feedback_message: str
    joint_affected: Optional[str] = None
    audio_prompt: Optional[str] = None
    current_angles: Dict[str, float]

class YogaAnalysisResult(BaseModel):
    exercise_key: str
    is_holding: bool
    hold_duration_sec: int
    form_score: float
    status: str
    feedback_message: str
    audio_prompt: Optional[str] = None
    current_angles: Dict[str, float]

# ================= WORKOUT SESSIONS =================
class ExerciseSessionCreate(BaseModel):
    exercise_key: str
    exercise_name: str
    total_reps: int = 0
    correct_reps: int = 0
    incorrect_reps: int = 0
    avg_form_score: float = 0.0

class ExerciseSessionResponse(BaseModel):
    id: str
    exercise_key: str
    exercise_name: str
    total_reps: int
    correct_reps: int
    incorrect_reps: int
    avg_form_score: float

    model_config = ConfigDict(from_attributes=True)

class WorkoutSessionCreate(BaseModel):
    workout_type: str = "GYM STAR AI Routine"
    total_duration_sec: int = 0
    total_calories: float = 0.0
    avg_form_score: float = 0.0
    exercises: List[ExerciseSessionCreate] = []

class WorkoutSessionResponse(BaseModel):
    id: str
    workout_type: str
    total_duration_sec: int
    total_calories: float
    avg_form_score: float
    completed_at: datetime
    exercise_sessions: Optional[List[ExerciseSessionResponse]] = []

    model_config = ConfigDict(from_attributes=True)

# ================= ANALYTICS & DASHBOARD =================
class WeeklyTrendItem(BaseModel):
    day: str
    form_score: float
    reps: int
    calories: float

class ProgressDashboardSchema(BaseModel):
    total_workouts: int
    total_reps: int
    total_calories: float
    avg_form_score: float
    streak_days: int
    weekly_form_trend: List[WeeklyTrendItem]
    recent_sessions: List[WorkoutSessionResponse] = []

# ================= AI COACH CHAT & PLAN =================
class AIChatRequest(BaseModel):
    message: str
    user_name: Optional[str] = "Athlete"

class AIChatResponse(BaseModel):
    reply: str
    suggested_actions: Optional[List[str]] = []

class DaySchedule(BaseModel):
    day: str
    focus: str
    duration: str
    exercises: List[str]
    type: str

class PersonalizedPlanResponse(BaseModel):
    title: str
    fitness_level: str
    primary_goal: str
    weekly_schedule: List[DaySchedule]
    coach_tip: str
