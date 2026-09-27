import math
from typing import Dict, Tuple, Any

def calculate_angle_3p(a: Tuple[float, float], b: Tuple[float, float], c: Tuple[float, float]) -> float:
    """
    Calculates 2D angle ABC in degrees with vertex at landmark point B.
    Points are (x, y) coordinates normalized [0, 1].
    """
    ba = (a[0] - b[0], a[1] - b[1])
    bc = (c[0] - b[0], c[1] - b[1])
    
    dot_product = ba[0] * bc[0] + ba[1] * bc[1]
    mag_ba = math.sqrt(ba[0]**2 + ba[1]**2)
    mag_bc = math.sqrt(bc[0]**2 + bc[1]**2)
    
    if mag_ba * mag_bc == 0:
        return 0.0
        
    cosine_angle = dot_product / (mag_ba * mag_bc)
    # Clamp cosine angle to prevent precision errors outside [-1, 1]
    cosine_angle = max(-1.0, min(1.0, cosine_angle))
    
    angle = math.degrees(math.acos(cosine_angle))
    return round(angle, 1)

def extract_key_angles(landmarks: Dict[str, Any]) -> Dict[str, float]:
    """
    Extracts standard biometric angles from a normalized landmark dictionary:
    - left_elbow: SHOULDER - ELBOW - WRIST
    - right_elbow: SHOULDER - ELBOW - WRIST
    - left_knee: HIP - KNEE - ANKLE
    - right_knee: HIP - KNEE - ANKLE
    - left_hip: SHOULDER - HIP - KNEE
    - right_hip: SHOULDER - HIP - KNEE
    - left_shoulder: ELBOW - SHOULDER - HIP
    - right_shoulder: ELBOW - SHOULDER - HIP
    - spine: NOSE - HIP - ANKLE
    """
    def get_pt(name: str) -> Tuple[float, float]:
        if name in landmarks:
            lm = landmarks[name]
            if isinstance(lm, dict):
                return (lm.get('x', 0.0), lm.get('y', 0.0))
            else:
                return (getattr(lm, 'x', 0.0), getattr(lm, 'y', 0.0))
        return (0.0, 0.0)

    angles = {}
    
    # Left Elbow
    if 'LEFT_SHOULDER' in landmarks and 'LEFT_ELBOW' in landmarks and 'LEFT_WRIST' in landmarks:
        angles['left_elbow'] = calculate_angle_3p(
            get_pt('LEFT_SHOULDER'), get_pt('LEFT_ELBOW'), get_pt('LEFT_WRIST')
        )
        
    # Right Elbow
    if 'RIGHT_SHOULDER' in landmarks and 'RIGHT_ELBOW' in landmarks and 'RIGHT_WRIST' in landmarks:
        angles['right_elbow'] = calculate_angle_3p(
            get_pt('RIGHT_SHOULDER'), get_pt('RIGHT_ELBOW'), get_pt('RIGHT_WRIST')
        )

    # Left Knee
    if 'LEFT_HIP' in landmarks and 'LEFT_KNEE' in landmarks and 'LEFT_ANKLE' in landmarks:
        angles['left_knee'] = calculate_angle_3p(
            get_pt('LEFT_HIP'), get_pt('LEFT_KNEE'), get_pt('LEFT_ANKLE')
        )
        
    # Right Knee
    if 'RIGHT_HIP' in landmarks and 'RIGHT_KNEE' in landmarks and 'RIGHT_ANKLE' in landmarks:
        angles['right_knee'] = calculate_angle_3p(
            get_pt('RIGHT_HIP'), get_pt('RIGHT_KNEE'), get_pt('RIGHT_ANKLE')
        )

    # Left Hip / Back
    if 'LEFT_SHOULDER' in landmarks and 'LEFT_HIP' in landmarks and 'LEFT_KNEE' in landmarks:
        angles['left_hip'] = calculate_angle_3p(
            get_pt('LEFT_SHOULDER'), get_pt('LEFT_HIP'), get_pt('LEFT_KNEE')
        )

    # Right Hip / Back
    if 'RIGHT_SHOULDER' in landmarks and 'RIGHT_HIP' in landmarks and 'RIGHT_KNEE' in landmarks:
        angles['right_hip'] = calculate_angle_3p(
            get_pt('RIGHT_SHOULDER'), get_pt('RIGHT_HIP'), get_pt('RIGHT_KNEE')
        )

    # Left Shoulder
    if 'LEFT_ELBOW' in landmarks and 'LEFT_SHOULDER' in landmarks and 'LEFT_HIP' in landmarks:
        angles['left_shoulder'] = calculate_angle_3p(
            get_pt('LEFT_ELBOW'), get_pt('LEFT_SHOULDER'), get_pt('LEFT_HIP')
        )

    # Right Shoulder
    if 'RIGHT_ELBOW' in landmarks and 'RIGHT_SHOULDER' in landmarks and 'RIGHT_HIP' in landmarks:
        angles['right_shoulder'] = calculate_angle_3p(
            get_pt('RIGHT_ELBOW'), get_pt('RIGHT_SHOULDER'), get_pt('RIGHT_HIP')
        )

    return angles
