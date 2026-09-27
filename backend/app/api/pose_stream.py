from fastapi import APIRouter, WebSocket, WebSocketDisconnect
from pydantic import BaseModel
from typing import Dict, Any, Optional
import json
from app.schemas.schemas import PoseFramePayload, PoseAnalysisResult
from app.engine.angle_calculator import extract_key_angles
from app.engine.exercise_fsm import exercise_fsm_engine
from app.engine.form_analyzer import form_analyzer_engine
from app.engine.yoga_tracker import yoga_hold_tracker
from app.engine.ai_coach import ai_coach_engine

router = APIRouter(tags=["Real-Time Computer Vision Pipeline"])

class ChatRequest(BaseModel):
    message: str
    user_name: Optional[str] = "Athlete"

@router.post("/pose/analyze", response_model=PoseAnalysisResult)
def analyze_single_pose(payload: PoseFramePayload):
    session_id = "rest_session_default"
    angles = extract_key_angles(payload.landmarks)

    if payload.is_yoga:
        is_held, duration, accuracy, msg, audio = yoga_hold_tracker.process_yoga_frame(
            session_id, payload.exercise_key, angles, payload.landmarks
        )
        return PoseAnalysisResult(
            exercise_key=payload.exercise_key,
            rep_count=duration,
            rep_state="HOLDING" if is_held else "ADJUSTING",
            form_score=accuracy,
            status="GOOD" if is_held else "WARNING",
            feedback_message=msg,
            joint_affected=None,
            audio_prompt=audio,
            current_angles=angles
        )

    # Form evaluation for rep-based workouts
    status, form_score, msg, joint, audio = form_analyzer_engine.analyze_form(
        payload.exercise_key, angles, payload.landmarks, "ACTIVE"
    )
    
    # Rep calculation
    reps, state, avg_score = exercise_fsm_engine.process_frame(
        session_id, payload.exercise_key, angles, status, form_score
    )

    return PoseAnalysisResult(
        exercise_key=payload.exercise_key,
        rep_count=reps,
        rep_state=state,
        form_score=form_score,
        status=status,
        feedback_message=msg,
        joint_affected=joint,
        audio_prompt=audio,
        current_angles=angles
    )

@router.post("/ai/chat")
def ai_coach_chat(payload: ChatRequest):
    reply = ai_coach_engine.chat_response(payload.message, payload.user_name or "Athlete")
    return {
        "reply": reply,
        "suggested_actions": [
            "How do I keep my back straight in squats?",
            "What is the 90/90 rule in lunges?",
            "How to hold Tree Pose without wobbling?",
            "Give me a 15-minute routine"
        ]
    }

@router.websocket("/ws/pose-stream")
async def pose_stream_websocket(websocket: WebSocket):
    await websocket.accept()
    session_id = str(id(websocket))
    try:
        while True:
            data = await websocket.receive_text()
            packet = json.loads(data)
            exercise_key = packet.get("exercise_key", "squat")
            landmarks = packet.get("landmarks", {})
            is_yoga = packet.get("is_yoga", False)

            angles = extract_key_angles(landmarks)

            if is_yoga:
                is_held, duration, accuracy, msg, audio = yoga_hold_tracker.process_yoga_frame(
                    session_id, exercise_key, angles, landmarks
                )
                response = {
                    "type": "YOGA_FEEDBACK",
                    "exercise_key": exercise_key,
                    "is_holding": is_held,
                    "hold_duration_sec": duration,
                    "form_score": accuracy,
                    "status": "GOOD" if is_held else "WARNING",
                    "feedback_message": msg,
                    "audio_prompt": audio,
                    "current_angles": angles
                }
            else:
                status, form_score, msg, joint, audio = form_analyzer_engine.analyze_form(
                    exercise_key, angles, landmarks, "ACTIVE"
                )
                reps, state, avg_score = exercise_fsm_engine.process_frame(
                    session_id, exercise_key, angles, status, form_score
                )
                response = {
                    "type": "WORKOUT_FEEDBACK",
                    "exercise_key": exercise_key,
                    "rep_count": reps,
                    "rep_state": state,
                    "form_score": form_score,
                    "status": status,
                    "feedback_message": msg,
                    "joint_affected": joint,
                    "audio_prompt": audio,
                    "current_angles": angles
                }

            await websocket.send_text(json.dumps(response))
    except WebSocketDisconnect:
        exercise_fsm_engine.reset_session(session_id)
