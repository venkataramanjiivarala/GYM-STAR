import http.server
import socketserver
import json
import urllib.parse

PORT = 8000

class GymStarRequestHandler(http.server.BaseHTTPRequestHandler):
    def _set_headers(self, status=200):
        self.send_response(status)
        self.send_header('Content-type', 'application/json')
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS, PUT, DELETE')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type, Authorization')
        self.end_headers()

    def do_OPTIONS(self):
        self._set_headers(200)

    def do_GET(self):
        parsed = urllib.parse.urlparse(self.path)
        path = parsed.path

        if path in ['/', '']:
            self._set_headers(200)
            self.wfile.write(json.dumps({
                "app": "GYM STAR API",
                "tagline": "Train Smarter. Move Better.",
                "status": "online",
                "version": "1.0.0"
            }).encode('utf-8'))
        elif path == '/api/v1/exercises':
            self._set_headers(200)
            exercises = [
                {
                    "id": "ex_1",
                    "key": "squat",
                    "name": "Bodyweight Squat",
                    "category": "Legs",
                    "difficulty": "Beginner",
                    "target_muscles": "Quadriceps, Glutes, Core",
                    "description": "Fundamental lower-body compound exercise evaluating knee depth and back straightness.",
                    "instructions": ["Stand shoulder-width apart", "Lower hips to 90 degrees", "Drive through heels"],
                    "common_mistakes": ["Knees caving inward", "Rounding lower back"],
                    "calories_per_rep": 0.45,
                    "rules_config": {"primary_angle": "knee_angle"}
                },
                {
                    "id": "ex_2",
                    "key": "pushup",
                    "name": "Classic Push-Up",
                    "category": "Chest",
                    "difficulty": "Beginner",
                    "target_muscles": "Chest, Triceps, Core",
                    "description": "Upper-body pressing movement evaluating spine straightness and elbow flex.",
                    "instructions": ["Rigid plank position", "Lower chest to 90-deg elbows", "Push to lockout"],
                    "common_mistakes": ["Sagging hips", "Elbow flaring"],
                    "calories_per_rep": 0.5,
                    "rules_config": {"primary_angle": "elbow_angle"}
                },
                {
                    "id": "ex_3",
                    "key": "bicep_curl",
                    "name": "Standing Bicep Curl",
                    "category": "Arms",
                    "difficulty": "Beginner",
                    "target_muscles": "Biceps, Forearms",
                    "description": "Isolated arm flexion ensuring shoulder stability.",
                    "instructions": ["Keep elbows pinned to ribs", "Curl upward", "Lower under control"],
                    "common_mistakes": ["Swinging shoulders"],
                    "calories_per_rep": 0.35,
                    "rules_config": {"primary_angle": "elbow_angle"}
                },
                {
                    "id": "ex_4",
                    "key": "lunge",
                    "name": "Forward Lunge",
                    "category": "Legs",
                    "difficulty": "Intermediate",
                    "target_muscles": "Quads, Glutes",
                    "description": "Single-leg stability exercise tracking lead knee angle.",
                    "instructions": ["Step forward", "Lower back knee near ground", "Push back to standing"],
                    "common_mistakes": ["Knee collapsing inward"],
                    "calories_per_rep": 0.48,
                    "rules_config": {"primary_angle": "knee_angle"}
                },
                {
                    "id": "ex_5",
                    "key": "plank",
                    "name": "Isometric Forearm Plank",
                    "category": "Core",
                    "difficulty": "Beginner",
                    "target_muscles": "Abs, Core Stabilizers",
                    "description": "Core stability hold tracking hip alignment and sagging prevention.",
                    "instructions": ["Forearms grounded", "Rigid body line", "Brace core"],
                    "common_mistakes": ["Hips drooping down"],
                    "calories_per_rep": 0.15,
                    "rules_config": {"primary_angle": "hip_angle"}
                }
            ]
            self.wfile.write(json.dumps(exercises).encode('utf-8'))

        elif path == '/api/v1/yoga':
            self._set_headers(200)
            yoga = [
                {
                    "id": "yg_1",
                    "key": "tree_pose",
                    "name": "Tree Pose (Vrikshasana)",
                    "sanskrit_name": "Vrikshasana",
                    "category": "Balance & Focus",
                    "difficulty": "Beginner",
                    "description": "Standing balance pose strengthening ankle stability and leg grounding.",
                    "benefits": ["Improves physical balance", "Strengthens ankles and calves"],
                    "hold_duration_sec": 30,
                    "rules_config": {}
                },
                {
                    "id": "yg_2",
                    "key": "warrior_2",
                    "name": "Warrior II (Virabhadrasana II)",
                    "sanskrit_name": "Virabhadrasana II",
                    "category": "Strength & Stamina",
                    "difficulty": "Intermediate",
                    "description": "Powerful standing stance building hip openness and leg endurance.",
                    "benefits": ["Strengthens legs and core", "Opens hips"],
                    "hold_duration_sec": 45,
                    "rules_config": {}
                },
                {
                    "id": "yg_3",
                    "key": "downward_dog",
                    "name": "Downward-Facing Dog",
                    "sanskrit_name": "Adho Mukha Svanasana",
                    "category": "Flexibility & Energy",
                    "difficulty": "Beginner",
                    "description": "Inverted V pose lengthening hamstrings and shoulder alignment.",
                    "benefits": ["Stretches hamstrings and shoulders"],
                    "hold_duration_sec": 45,
                    "rules_config": {}
                },
                {
                    "id": "yg_4",
                    "key": "cobra_pose",
                    "name": "Cobra Pose (Bhujangasana)",
                    "sanskrit_name": "Bhujangasana",
                    "category": "Back Relief",
                    "difficulty": "Beginner",
                    "description": "Gentle backbend expanding chest cavity and spine extensor strength.",
                    "benefits": ["Strengthens spine", "Opens chest"],
                    "hold_duration_sec": 30,
                    "rules_config": {}
                }
            ]
            self.wfile.write(json.dumps(yoga).encode('utf-8'))

        elif path == '/api/v1/analytics/dashboard':
            self._set_headers(200)
            data = {
                "total_workouts": 14,
                "total_reps": 397,
                "total_calories": 1850.0,
                "avg_form_score": 94.5,
                "streak_days": 7,
                "weekly_form_trend": [
                    {"day": "Mon", "form_score": 78, "reps": 32, "calories": 140},
                    {"day": "Tue", "form_score": 81, "reps": 45, "calories": 190},
                    {"day": "Wed", "form_score": 85, "reps": 50, "calories": 210},
                    {"day": "Thu", "form_score": 88, "reps": 60, "calories": 260},
                    {"day": "Fri", "form_score": 92, "reps": 65, "calories": 320},
                    {"day": "Sat", "form_score": 94, "reps": 70, "calories": 350},
                    {"day": "Sun", "form_score": 95, "reps": 75, "calories": 380}
                ],
                "recent_sessions": []
            }
            self.wfile.write(json.dumps(data).encode('utf-8'))
        else:
            self._set_headers(404)
            self.wfile.write(json.dumps({"detail": "Not found"}).encode('utf-8'))

    def do_POST(self):
        parsed = urllib.parse.urlparse(self.path)
        path = parsed.path
        length = int(self.headers.get('Content-Length', 0))
        body_data = self.rfile.read(length) if length > 0 else b'{}'

        if path == '/api/v1/ai/chat':
            self._set_headers(200)
            req = json.loads(body_data.decode('utf-8'))
            msg = req.get("message", "").lower()
            if "squat" in msg:
                reply = "For squats, keep your chest upright, press firmly through your heels, and ensure your knees trace inline with your toes without caving inward!"
            elif "pushup" in msg:
                reply = "For push-ups, brace your core in a rigid plank, position hands slightly wider than shoulder-width, and lower chest to 90-degree elbows."
            else:
                reply = "I'm your GYM STAR AI Coach! Focus on smooth controlled reps and maintaining a Form Score above 85% for optimal results."
            self.wfile.write(json.dumps({"reply": reply}).encode('utf-8'))
        else:
            self._set_headers(200)
            self.wfile.write(json.dumps({"status": "success"}).encode('utf-8'))

if __name__ == "__main__":
    with socketserver.TCPServer(("127.0.0.1", PORT), GymStarRequestHandler) as httpd:
        print(f"GYM STAR API Lightweight Server running at http://127.0.0.1:{PORT}")
        httpd.serve_forever()
