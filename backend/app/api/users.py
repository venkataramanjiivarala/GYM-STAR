from fastapi import APIRouter, Depends, HTTPException, status, Header
from sqlalchemy.orm import Session
from typing import Optional
from app.core.database import get_db
from app.core.security import decode_token
from app.models.models import User, UserProfile
from app.schemas.schemas import UserResponse, UserProfileSchema
from app.engine.ai_coach import ai_coach_engine

router = APIRouter(prefix="/users", tags=["Users & Profiles"])

def get_current_user(authorization: Optional[str] = Header(None), db: Session = Depends(get_db)) -> User:
    if not authorization or not authorization.startswith("Bearer "):
        # Return fallback demo user for quick start testing
        user = db.query(User).first()
        if not user:
            user = User(email="raman@gymstar.ai", name="Raman", hashed_password="hashed_demo_pw")
            db.add(user)
            db.commit()
            db.refresh(user)
            profile = UserProfile(user_id=user.id)
            db.add(profile)
            db.commit()
        return user

    token = authorization.split(" ")[1]
    user_id = decode_token(token)
    if not user_id:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token")
    
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")
    return user

@router.get("/me", response_model=UserResponse)
def get_user_profile(user: User = Depends(get_current_user)):
    return user

@router.put("/me/profile", response_model=UserResponse)
def update_user_profile(
    payload: UserProfileSchema,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    profile = db.query(UserProfile).filter(UserProfile.user_id == user.id).first()
    if not profile:
        profile = UserProfile(user_id=user.id)
        db.add(profile)

    for field, val in payload.model_dump().items():
        setattr(profile, field, val)

    db.commit()
    db.refresh(user)
    return user

@router.post("/me/ai-plan")
def get_personalized_plan(user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    profile = db.query(UserProfile).filter(UserProfile.user_id == user.id).first()
    profile_dict = {
        "fitness_level": profile.fitness_level if profile else "Beginner",
        "primary_goal": profile.primary_goal if profile else "Strength & Form"
    }
    return ai_coach_engine.generate_personalized_plan(profile_dict)
