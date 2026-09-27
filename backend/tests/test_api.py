import pytest
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_root_endpoint():
    response = client.get("/")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "online"
    assert "GYM STAR" in data["app"]

def test_get_exercises_list_and_filter():
    response = client.get("/api/v1/exercises")
    assert response.status_code == 200
    exercises = response.json()
    assert len(exercises) >= 5
    keys = [e["key"] for e in exercises]
    assert "squat" in keys
    assert "pushup" in keys

    # Category filter
    resp_legs = client.get("/api/v1/exercises?category=Legs")
    assert resp_legs.status_code == 200
    legs_exercises = resp_legs.json()
    assert all("Legs" in e["category"] for e in legs_exercises)

def test_get_exercise_detail():
    response = client.get("/api/v1/exercises/squat")
    assert response.status_code == 200
    data = response.json()
    assert data["key"] == "squat"
    assert "knee_angle" in str(data["rules_config"])

def test_get_yoga_poses_and_detail():
    response = client.get("/api/v1/yoga")
    assert response.status_code == 200
    poses = response.json()
    assert len(poses) >= 4
    keys = [p["key"] for p in poses]
    assert "tree_pose" in keys
    assert "warrior_2" in keys

    resp_pose = client.get("/api/v1/yoga/tree_pose")
    assert resp_pose.status_code == 200
    assert resp_pose.json()["key"] == "tree_pose"

def test_analytics_dashboard():
    response = client.get("/api/v1/analytics/dashboard")
    assert response.status_code == 200
    data = response.json()
    assert "total_workouts" in data
    assert "weekly_form_trend" in data
    assert len(data["weekly_form_trend"]) == 7

def test_pose_analyze_endpoint():
    dummy_landmarks = {
        "LEFT_SHOULDER": {"x": 0.4, "y": 0.3, "z": 0.0, "visibility": 1.0},
        "RIGHT_SHOULDER": {"x": 0.6, "y": 0.3, "z": 0.0, "visibility": 1.0},
        "LEFT_ELBOW": {"x": 0.35, "y": 0.45, "z": 0.0, "visibility": 1.0},
        "RIGHT_ELBOW": {"x": 0.65, "y": 0.45, "z": 0.0, "visibility": 1.0},
        "LEFT_WRIST": {"x": 0.32, "y": 0.6, "z": 0.0, "visibility": 1.0},
        "RIGHT_WRIST": {"x": 0.68, "y": 0.6, "z": 0.0, "visibility": 1.0},
        "LEFT_HIP": {"x": 0.42, "y": 0.55, "z": 0.0, "visibility": 1.0},
        "RIGHT_HIP": {"x": 0.58, "y": 0.55, "z": 0.0, "visibility": 1.0},
        "LEFT_KNEE": {"x": 0.43, "y": 0.75, "z": 0.0, "visibility": 1.0},
        "RIGHT_KNEE": {"x": 0.57, "y": 0.75, "z": 0.0, "visibility": 1.0},
        "LEFT_ANKLE": {"x": 0.43, "y": 0.9, "z": 0.0, "visibility": 1.0},
        "RIGHT_ANKLE": {"x": 0.57, "y": 0.9, "z": 0.0, "visibility": 1.0}
    }

    payload = {
        "exercise_key": "squat",
        "landmarks": dummy_landmarks,
        "is_yoga": False
    }
    response = client.post("/api/v1/pose/analyze", json=payload)
    assert response.status_code == 200
    data = response.json()
    assert data["exercise_key"] == "squat"
    assert "form_score" in data
    assert "status" in data

def test_ai_coach_chat():
    response = client.post("/api/v1/ai/chat", json={"message": "How do I do a squat?", "user_name": "Raman"})
    assert response.status_code == 200
    data = response.json()
    assert "reply" in data
    assert "squat" in data["reply"].lower()

def test_user_profile_and_ai_plan():
    # Test GET user profile
    resp_me = client.get("/api/v1/users/me")
    assert resp_me.status_code == 200
    user_data = resp_me.json()
    assert "email" in user_data

    # Test update profile
    update_payload = {
        "age": 26,
        "gender": "male",
        "height_cm": 178.0,
        "weight_kg": 72.5,
        "fitness_level": "Intermediate",
        "primary_goal": "Muscle Gain",
        "workout_frequency": 5,
        "equipment": "Dumbbells",
        "voice_coaching": True
    }
    resp_update = client.put("/api/v1/users/me/profile", json=update_payload)
    assert resp_update.status_code == 200
    updated_data = resp_update.json()
    assert updated_data["profile"]["fitness_level"] == "Intermediate"

    # Test AI plan generation
    resp_plan = client.post("/api/v1/users/me/ai-plan")
    assert resp_plan.status_code == 200
    plan_data = resp_plan.json()
    assert "weekly_schedule" in plan_data
    assert len(plan_data["weekly_schedule"]) == 7

def test_complete_workout_and_history():
    payload = {
        "workout_type": "GYM STAR Squat Session",
        "total_duration_sec": 180,
        "total_calories": 25.5,
        "avg_form_score": 94.0,
        "exercises": [
            {
                "exercise_key": "squat",
                "exercise_name": "Bodyweight Squat",
                "total_reps": 12,
                "correct_reps": 11,
                "incorrect_reps": 1,
                "avg_form_score": 94.0
            }
        ]
    }
    response = client.post("/api/v1/workouts/complete", json=payload)
    assert response.status_code == 200
    session_data = response.json()
    assert session_data["total_reps"] if "total_reps" in session_data else session_data["total_calories"] == 25.5

    # Check history
    resp_hist = client.get("/api/v1/workouts/history")
    assert resp_hist.status_code == 200
    history = resp_hist.json()
    assert len(history) >= 1
