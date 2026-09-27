import uuid
from datetime import datetime, timezone
from sqlalchemy import Column, String, Integer, Float, Boolean, DateTime, ForeignKey, Text, JSON
from sqlalchemy.orm import relationship
from app.core.database import Base

def generate_uuid():
    return str(uuid.uuid4())

def get_utc_now():
    return datetime.now(timezone.utc)

class User(Base):
    __tablename__ = "users"

    id = Column(String, primary_key=True, default=generate_uuid)
    email = Column(String, unique=True, index=True, nullable=False)
    name = Column(String, nullable=False)
    hashed_password = Column(String, nullable=False)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime, default=get_utc_now)

    profile = relationship("UserProfile", back_populates="user", uselist=False, cascade="all, delete-orphan")
    workout_sessions = relationship("WorkoutSession", back_populates="user", cascade="all, delete-orphan")
    progress_records = relationship("ProgressRecord", back_populates="user", cascade="all, delete-orphan")

class UserProfile(Base):
    __tablename__ = "user_profiles"

    id = Column(String, primary_key=True, default=generate_uuid)
    user_id = Column(String, ForeignKey("users.id"), nullable=False, unique=True)
    age = Column(Integer, default=25)
    gender = Column(String, default="unspecified")
    height_cm = Column(Float, default=175.0)
    weight_kg = Column(Float, default=70.0)
    fitness_level = Column(String, default="Beginner")  # Beginner, Intermediate, Advanced
    primary_goal = Column(String, default="Strength & Form") # Weight Loss, Muscle Gain, Flexibility, General Fitness
    workout_frequency = Column(Integer, default=4) # days per week
    equipment = Column(String, default="Bodyweight")
    voice_coaching = Column(Boolean, default=True)
    updated_at = Column(DateTime, default=get_utc_now, onupdate=get_utc_now)

    user = relationship("User", back_populates="profile")

class Exercise(Base):
    __tablename__ = "exercises"

    id = Column(String, primary_key=True, default=generate_uuid)
    key = Column(String, unique=True, nullable=False) # e.g. 'squat', 'pushup', 'bicep_curl'
    name = Column(String, nullable=False)
    category = Column(String, nullable=False) # Chest, Legs, Core, Arms, Shoulders, Full Body
    difficulty = Column(String, default="Beginner")
    target_muscles = Column(String, nullable=False)
    description = Column(Text, nullable=False)
    instructions = Column(JSON, default=list) # List of instruction strings
    common_mistakes = Column(JSON, default=list)
    calories_per_rep = Column(Float, default=0.4)
    rules_config = Column(JSON, nullable=False) # FSM thresholds, target angles, joint landmarks

class YogaPose(Base):
    __tablename__ = "yoga_poses"

    id = Column(String, primary_key=True, default=generate_uuid)
    key = Column(String, unique=True, nullable=False) # e.g. 'tree_pose', 'warrior_2', 'downward_dog'
    name = Column(String, nullable=False)
    sanskrit_name = Column(String, default="")
    category = Column(String, nullable=False) # Flexibility, Strength, Balance, Morning Yoga
    difficulty = Column(String, default="Beginner")
    description = Column(Text, nullable=False)
    benefits = Column(JSON, default=list)
    hold_duration_sec = Column(Integer, default=30)
    rules_config = Column(JSON, nullable=False)

class WorkoutSession(Base):
    __tablename__ = "workout_sessions"

    id = Column(String, primary_key=True, default=generate_uuid)
    user_id = Column(String, ForeignKey("users.id"), nullable=False)
    workout_type = Column(String, default="Custom Workout") # Gym Star Dynamic Routine, Yoga Flow, etc.
    total_duration_sec = Column(Integer, default=0)
    total_calories = Column(Float, default=0.0)
    avg_form_score = Column(Float, default=0.0)
    completed_at = Column(DateTime, default=get_utc_now)

    user = relationship("User", back_populates="workout_sessions")
    exercise_sessions = relationship("ExerciseSession", back_populates="workout_session", cascade="all, delete-orphan")

class ExerciseSession(Base):
    __tablename__ = "exercise_sessions"

    id = Column(String, primary_key=True, default=generate_uuid)
    workout_session_id = Column(String, ForeignKey("workout_sessions.id"), nullable=False)
    exercise_key = Column(String, nullable=False)
    exercise_name = Column(String, nullable=False)
    total_reps = Column(Integer, default=0)
    correct_reps = Column(Integer, default=0)
    incorrect_reps = Column(Integer, default=0)
    avg_form_score = Column(Float, default=0.0)

    workout_session = relationship("WorkoutSession", back_populates="exercise_sessions")

class ProgressRecord(Base):
    __tablename__ = "progress_records"

    id = Column(String, primary_key=True, default=generate_uuid)
    user_id = Column(String, ForeignKey("users.id"), nullable=False)
    date = Column(DateTime, default=get_utc_now)
    workouts_completed = Column(Integer, default=1)
    total_reps = Column(Integer, default=0)
    calories_burned = Column(Float, default=0.0)
    avg_form_score = Column(Float, default=0.0)
    streak_count = Column(Integer, default=1)

    user = relationship("User", back_populates="progress_records")
