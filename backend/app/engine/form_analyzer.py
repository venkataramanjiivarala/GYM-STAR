from typing import Dict, Any, Tuple, Optional

class FormAnalyzerEngine:
    def __init__(self):
        self.cooldowns: Dict[str, float] = {}

    def analyze_form(
        self,
        exercise_key: str,
        angles: Dict[str, float],
        landmarks: Dict[str, Any],
        rep_state: str
    ) -> Tuple[str, float, str, Optional[str], Optional[str]]:
        """
        Analyzes body posture & biometric angles for the specified exercise.
        Returns: (status, form_score, feedback_message, joint_affected, audio_prompt)
        """
        status = "GOOD"
        score = 95.0
        message = "✓ Perfect form! Keep it up!"
        joint = None
        audio = None

        if exercise_key == "squat":
            left_knee = angles.get("left_knee", 180)
            right_knee = angles.get("right_knee", 180)
            left_hip = angles.get("left_hip", 180)
            right_hip = angles.get("right_hip", 180)
            avg_knee = (left_knee + right_knee) / 2.0
            avg_hip = (left_hip + right_hip) / 2.0

            # Rule 1: Back Bending Check (Hip angle too small)
            if avg_hip < 130 and rep_state in ["DESCENDING", "BOTTOM"]:
                status = "WARNING"
                score -= 25.0
                message = "⚠️ Keep your chest up & back straight!"
                joint = "HIP"
                audio = "Keep your back straight"

            # Rule 2: Asymmetric Knees Check
            elif abs(left_knee - right_knee) > 25:
                status = "WARNING"
                score -= 20.0
                message = "⚠️ Keep equal weight on both legs!"
                joint = "KNEE"
                audio = "Balance your weight evenly"

            # Rule 3: Depth check at bottom state
            elif rep_state == "BOTTOM" and avg_knee > 105:
                status = "WARNING"
                score -= 15.0
                message = "⚠️ Go a little lower for full range of motion."
                joint = "KNEE"
                audio = "Go a bit lower"

        elif exercise_key == "pushup":
            left_elbow = angles.get("left_elbow", 180)
            right_elbow = angles.get("right_elbow", 180)
            left_hip = angles.get("left_hip", 180)
            avg_elbow = (left_elbow + right_elbow) / 2.0

            # Rule 1: Sagging Hips (Hip angle bent)
            if left_hip < 150:
                status = "WARNING"
                score -= 30.0
                message = "⚠️ Keep your core tight and body straight in a line!"
                joint = "HIP"
                audio = "Keep your body in a straight line"

            # Rule 2: Elbow Flare
            elif avg_elbow < 70 and rep_state == "DESCENDING":
                status = "WARNING"
                score -= 20.0
                message = "⚠️ Keep your elbows at a 45-degree angle to your body."
                joint = "ELBOW"
                audio = "Tuck your elbows slightly"

        elif exercise_key in ["bicep_curl", "dumbbell_curl"]:
            left_shoulder = angles.get("left_shoulder", 0)
            right_shoulder = angles.get("right_shoulder", 0)
            
            # Swinging shoulders
            if left_shoulder > 35 or right_shoulder > 35:
                status = "WARNING"
                score -= 25.0
                message = "⚠️ Keep your upper arm still! Avoid swinging shoulders."
                joint = "SHOULDER"
                audio = "Do not swing your arms"

        elif exercise_key == "plank":
            left_hip = angles.get("left_hip", 180)
            if left_hip < 155:
                status = "WARNING"
                score -= 25.0
                message = "⚠️ Don't let your hips sag! Engage your core."
                joint = "HIP"
                audio = "Engage your core"
            elif left_hip > 195:
                status = "WARNING"
                score -= 20.0
                message = "⚠️ Lower your hips into a straight plank position."
                joint = "HIP"
                audio = "Lower your hips"

        score = max(40.0, min(100.0, score))
        return (status, round(score, 1), message, joint, audio)

form_analyzer_engine = FormAnalyzerEngine()
