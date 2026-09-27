import pytest
from app.engine.angle_calculator import calculate_angle_3p, extract_key_angles
from app.engine.exercise_fsm import exercise_fsm_engine
from app.engine.form_analyzer import form_analyzer_engine

def test_calculate_angle_90_degrees():
    a = (0.0, 1.0)
    b = (0.0, 0.0)
    c = (1.0, 0.0)
    angle = calculate_angle_3p(a, b, c)
    assert angle == 90.0

def test_calculate_angle_straight_180_degrees():
    a = (0.0, 1.0)
    b = (0.0, 0.0)
    c = (0.0, -1.0)
    angle = calculate_angle_3p(a, b, c)
    assert angle == 180.0

def test_squat_state_machine_rep_counter():
    session_id = "test_squat_01"
    exercise_fsm_engine.reset_session(session_id)

    # Frame 1: Standing
    angles = {"left_knee": 170.0, "right_knee": 170.0}
    reps, state, score = exercise_fsm_engine.process_frame(session_id, "squat", angles, "GOOD", 95.0)
    assert state == "STANDING"
    assert reps == 0

    # Frame 2: Descending
    angles = {"left_knee": 120.0, "right_knee": 120.0}
    reps, state, score = exercise_fsm_engine.process_frame(session_id, "squat", angles, "GOOD", 95.0)
    assert state == "DESCENDING"
    assert reps == 0

    # Frame 3: Bottom (knees <= 95)
    angles = {"left_knee": 85.0, "right_knee": 85.0}
    reps, state, score = exercise_fsm_engine.process_frame(session_id, "squat", angles, "GOOD", 95.0)
    assert state == "BOTTOM"
    assert reps == 0

    # Frame 4: Ascending
    angles = {"left_knee": 130.0, "right_knee": 130.0}
    reps, state, score = exercise_fsm_engine.process_frame(session_id, "squat", angles, "GOOD", 95.0)
    assert state == "ASCENDING"
    assert reps == 0

    # Frame 5: Standing (Rep Complete)
    angles = {"left_knee": 165.0, "right_knee": 165.0}
    reps, state, score = exercise_fsm_engine.process_frame(session_id, "squat", angles, "GOOD", 95.0)
    assert state == "STANDING"
    assert reps == 1

def test_form_analyzer_warning_trigger():
    angles = {"left_knee": 90.0, "right_knee": 90.0, "left_hip": 110.0, "right_hip": 110.0}
    status, score, msg, joint, audio = form_analyzer_engine.analyze_form("squat", angles, {}, "BOTTOM")
    assert status == "WARNING"
    assert joint == "HIP"
    assert "back straight" in msg.lower()
