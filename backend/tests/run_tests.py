import sys
import os
import unittest

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

from app.engine.angle_calculator import calculate_angle_3p
from app.engine.exercise_fsm import exercise_fsm_engine
from app.engine.form_analyzer import form_analyzer_engine

class TestEngine(unittest.TestCase):
    def test_calculate_angle_90_degrees(self):
        a = (0.0, 1.0)
        b = (0.0, 0.0)
        c = (1.0, 0.0)
        angle = calculate_angle_3p(a, b, c)
        self.assertEqual(angle, 90.0)

    def test_calculate_angle_straight_180_degrees(self):
        a = (0.0, 1.0)
        b = (0.0, 0.0)
        c = (0.0, -1.0)
        angle = calculate_angle_3p(a, b, c)
        self.assertEqual(angle, 180.0)

    def test_squat_state_machine_rep_counter(self):
        session_id = "test_squat_01"
        exercise_fsm_engine.reset_session(session_id)

        # Frame 1: Standing (170 degrees)
        r, s, _ = exercise_fsm_engine.process_frame(session_id, "squat", {"left_knee": 170.0, "right_knee": 170.0}, "GOOD", 95.0)
        self.assertEqual(s, "STARTING")

        # Frame 2: Descending (130 degrees)
        r, s, _ = exercise_fsm_engine.process_frame(session_id, "squat", {"left_knee": 130.0, "right_knee": 130.0}, "GOOD", 95.0)
        self.assertEqual(s, "DESCENDING")

        # Frame 3: Bottom (85 degrees <= 95)
        r, s, _ = exercise_fsm_engine.process_frame(session_id, "squat", {"left_knee": 85.0, "right_knee": 85.0}, "GOOD", 95.0)
        self.assertEqual(s, "BOTTOM")

        # Frame 4: Ascending (130 degrees > 110)
        r, s, _ = exercise_fsm_engine.process_frame(session_id, "squat", {"left_knee": 130.0, "right_knee": 130.0}, "GOOD", 95.0)
        self.assertEqual(s, "ASCENDING")

        # Frame 5: Standing (165 degrees >= 155) -> REP COMPLETE
        r, s, _ = exercise_fsm_engine.process_frame(session_id, "squat", {"left_knee": 165.0, "right_knee": 165.0}, "GOOD", 95.0)
        self.assertEqual(s, "STANDING")
        self.assertEqual(r, 1)

    def test_form_analyzer_warning_trigger(self):
        angles = {"left_knee": 90.0, "right_knee": 90.0, "left_hip": 110.0, "right_hip": 110.0}
        status, score, msg, joint, audio = form_analyzer_engine.analyze_form("squat", angles, {}, "BOTTOM")
        self.assertEqual(status, "WARNING")
        self.assertEqual(joint, "HIP")
        self.assertIn("back straight", msg.lower())

if __name__ == "__main__":
    unittest.main()
