from typing import Dict, Any, Tuple

class ExerciseStateMachine:
    def __init__(self):
        self.sessions: Dict[str, Dict[str, Any]] = {}

    def get_session_state(self, session_id: str) -> Dict[str, Any]:
        if session_id not in self.sessions:
            self.sessions[session_id] = {
                "state": "STARTING",
                "rep_count": 0,
                "correct_reps": 0,
                "incorrect_reps": 0,
                "form_scores": [],
                "last_state_change": 0,
                "current_form_valid": True
            }
        return self.sessions[session_id]

    def reset_session(self, session_id: str):
        if session_id in self.sessions:
            del self.sessions[session_id]

    def process_frame(
        self,
        session_id: str,
        exercise_key: str,
        angles: Dict[str, float],
        form_status: str, # GOOD, WARNING, INCORRECT
        form_score: float
    ) -> Tuple[int, str, float]:
        """
        Updates rep state machine based on joint angles.
        Returns: (rep_count, current_state, avg_form_score)
        """
        state_data = self.get_session_state(session_id)
        current_state = state_data["state"]
        rep_count = state_data["rep_count"]

        # Track form score
        state_data["form_scores"].append(form_score)
        if len(state_data["form_scores"]) > 100:
            state_data["form_scores"].pop(0)

        avg_score = round(sum(state_data["form_scores"]) / len(state_data["form_scores"]), 1)

        # Primary angle determination
        left_knee = angles.get("left_knee", 180.0)
        right_knee = angles.get("right_knee", 180.0)
        avg_knee = (left_knee + right_knee) / 2.0

        left_elbow = angles.get("left_elbow", 180.0)
        right_elbow = angles.get("right_elbow", 180.0)
        avg_elbow = (left_elbow + right_elbow) / 2.0

        new_state = current_state

        if exercise_key == "squat":
            if current_state in ["STARTING", "STANDING"]:
                if avg_knee < 140:
                    new_state = "DESCENDING"
                else:
                    new_state = "STANDING"
            elif current_state == "DESCENDING":
                if avg_knee <= 95:
                    new_state = "BOTTOM"
                elif avg_knee > 150:
                    new_state = "STANDING"
            elif current_state == "BOTTOM":
                if avg_knee > 110:
                    new_state = "ASCENDING"
            elif current_state == "ASCENDING":
                if avg_knee >= 155:
                    new_state = "STANDING"
                    rep_count += 1
                    if form_status == "GOOD":
                        state_data["correct_reps"] += 1
                    else:
                        state_data["incorrect_reps"] += 1

        elif exercise_key == "pushup":
            if current_state in ["STARTING", "HIGH_PLANK"]:
                if avg_elbow < 140:
                    new_state = "DESCENDING"
                else:
                    new_state = "HIGH_PLANK"
            elif current_state == "DESCENDING":
                if avg_elbow <= 95:
                    new_state = "BOTTOM"
                elif avg_elbow > 150:
                    new_state = "HIGH_PLANK"
            elif current_state == "BOTTOM":
                if avg_elbow > 110:
                    new_state = "ASCENDING"
            elif current_state == "ASCENDING":
                if avg_elbow >= 155:
                    new_state = "HIGH_PLANK"
                    rep_count += 1
                    if form_status == "GOOD":
                        state_data["correct_reps"] += 1
                    else:
                        state_data["incorrect_reps"] += 1

        elif exercise_key in ["bicep_curl", "dumbbell_curl"]:
            min_elbow = min(left_elbow, right_elbow)
            if current_state in ["STARTING", "EXTENDED"]:
                if min_elbow < 130:
                    new_state = "FLEXING"
                else:
                    new_state = "EXTENDED"
            elif current_state == "FLEXING":
                if min_elbow <= 55:
                    new_state = "TOP"
                elif min_elbow > 145:
                    new_state = "EXTENDED"
            elif current_state == "TOP":
                if min_elbow > 70:
                    new_state = "EXTENDING"
            elif current_state == "EXTENDING":
                if min_elbow >= 145:
                    new_state = "EXTENDED"
                    rep_count += 1
                    if form_status == "GOOD":
                        state_data["correct_reps"] += 1
                    else:
                        state_data["incorrect_reps"] += 1

        elif exercise_key == "lunge":
            lead_knee = min(left_knee, right_knee)
            if current_state in ["STARTING", "STANDING"]:
                if lead_knee < 140:
                    new_state = "LUNGING"
                else:
                    new_state = "STANDING"
            elif current_state == "LUNGING":
                if lead_knee <= 95:
                    new_state = "BOTTOM"
            elif current_state == "BOTTOM":
                if lead_knee > 115:
                    new_state = "ASCENDING"
            elif current_state == "ASCENDING":
                if lead_knee >= 155:
                    new_state = "STANDING"
                    rep_count += 1
                    if form_status == "GOOD":
                        state_data["correct_reps"] += 1
                    else:
                        state_data["incorrect_reps"] += 1
        else:
            # General default rep counter
            if current_state == "STARTING":
                new_state = "ACTIVE"
            elif current_state == "ACTIVE":
                new_state = "ACTIVE"

        state_data["state"] = new_state
        state_data["rep_count"] = rep_count
        return (rep_count, new_state, avg_score)

exercise_fsm_engine = ExerciseStateMachine()
