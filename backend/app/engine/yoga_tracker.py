from typing import Dict, Any, Tuple, Optional
import time

class YogaHoldTracker:
    def __init__(self):
        self.yoga_sessions: Dict[str, Dict[str, Any]] = {}

    def process_yoga_frame(
        self,
        session_id: str,
        yoga_key: str,
        angles: Dict[str, float],
        landmarks: Dict[str, Any]
    ) -> Tuple[bool, int, float, str, Optional[str]]:
        """
        Evaluates posture correctness for yoga pose holding.
        Returns: (is_holding, hold_duration_sec, pose_accuracy_pct, message, audio_prompt)
        """
        now = time.time()
        if session_id not in self.yoga_sessions:
            self.yoga_sessions[session_id] = {
                "start_time": None,
                "total_held_sec": 0,
                "is_active": False,
                "accuracy_scores": [],
                "last_tick": now
            }

        sess = self.yoga_sessions[session_id]
        is_correct = True
        accuracy = 95.0
        message = "✓ Perfect balance! Maintain hold."
        audio = None

        left_knee = angles.get("left_knee", 180)
        right_knee = angles.get("right_knee", 180)
        left_hip = angles.get("left_hip", 180)
        right_hip = angles.get("right_hip", 180)
        left_elbow = angles.get("left_elbow", 180)
        right_elbow = angles.get("right_elbow", 180)

        if yoga_key == "tree_pose":
            # One leg straight (standing knee ~180°), one leg bent (knee <= 90°)
            straight_knee = max(left_knee, right_knee)
            bent_knee = min(left_knee, right_knee)
            
            if straight_knee < 155:
                is_correct = False
                accuracy -= 30.0
                message = "⚠️ Keep your standing leg straight and grounded."
                audio = "Straighten your standing leg"
            elif bent_knee > 120:
                is_correct = False
                accuracy -= 25.0
                message = "⚠️ Raise your foot higher against your inner thigh."
                audio = "Raise your foot higher"

        elif yoga_key == "warrior_2":
            # Lead leg bent ~90°, back leg straight ~180°, arms extended horizontally ~180°
            lead_knee = min(left_knee, right_knee)
            if lead_knee > 115:
                is_correct = False
                accuracy -= 20.0
                message = "⚠️ Deepen your lunge on the front knee to 90 degrees."
                audio = "Bend your front knee deeper"
            if min(left_elbow, right_elbow) < 140:
                is_correct = False
                accuracy -= 20.0
                message = "⚠️ Extend both arms horizontally straight."
                audio = "Extend your arms straight"

        elif yoga_key == "downward_dog":
            # Hips high, knees straight (~170-180°), shoulders open
            if min(left_knee, right_knee) < 150:
                is_correct = False
                accuracy -= 25.0
                message = "⚠️ Press your heels towards the floor & straighten knees."
                audio = "Straighten your knees"

        elif yoga_key == "cobra_pose":
            # Hips on ground, elbows slightly bent, chest lifted
            if max(left_hip, right_hip) < 130:
                is_correct = False
                accuracy -= 20.0
                message = "⚠️ Press hips down & lift your chest with shoulders back."
                audio = "Lift your chest up"

        accuracy = max(50.0, min(100.0, accuracy))
        sess["accuracy_scores"].append(accuracy)

        # Hold timer state machine
        if is_correct:
            if not sess["is_active"]:
                sess["is_active"] = True
                sess["start_time"] = now
            else:
                elapsed = int(now - sess["start_time"])
                sess["total_held_sec"] = elapsed
        else:
            sess["is_active"] = False
            sess["start_time"] = None
            audio = audio or "Adjust your posture"

        return (sess["is_active"], sess["total_held_sec"], round(accuracy, 1), message, audio)

yoga_hold_tracker = YogaHoldTracker()
