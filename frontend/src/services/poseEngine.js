// Client-Side AI Computer Vision Geometry Engine & Speech/Audio Coach

export function calculateAngle(a, b, c) {
  if (!a || !b || !c) return 180;
  const ba = { x: a.x - b.x, y: a.y - b.y };
  const bc = { x: c.x - b.x, y: c.y - b.y };

  const dot = ba.x * bc.x + ba.y * bc.y;
  const magBA = Math.sqrt(ba.x * ba.x + ba.y * ba.y);
  const magBC = Math.sqrt(bc.x * bc.x + bc.y * bc.y);

  if (magBA * magBC === 0) return 180;

  let cosAngle = dot / (magBA * magBC);
  cosAngle = Math.max(-1, Math.min(1, cosAngle));
  const angle = Math.acos(cosAngle) * (180 / Math.PI);
  return Math.round(angle);
}

// Built-in Web Audio API Sound Synthesizer for instant haptic/sound cues
export class SoundEffects {
  constructor() {
    this.ctx = null;
    this.enabled = true;
  }

  init() {
    if (!this.ctx && typeof window !== 'undefined') {
      const AudioContextClass = window.AudioContext || window.webkitAudioContext;
      if (AudioContextClass) this.ctx = new AudioContextClass();
    }
  }

  playRepBeep() {
    if (!this.enabled) return;
    try {
      this.init();
      if (!this.ctx) return;
      const osc = this.ctx.createOscillator();
      const gain = this.ctx.createGain();
      osc.type = 'sine';
      osc.frequency.setValueAtTime(587.33, this.ctx.currentTime); // D5
      osc.frequency.exponentialRampToValueAtTime(880, this.ctx.currentTime + 0.12); // A5
      gain.gain.setValueAtTime(0.15, this.ctx.currentTime);
      gain.gain.exponentialRampToValueAtTime(0.001, this.ctx.currentTime + 0.15);
      osc.connect(gain);
      gain.connect(this.ctx.destination);
      osc.start();
      osc.stop(this.ctx.currentTime + 0.15);
    } catch (e) {
      // Audio context might be restricted before interaction
    }
  }

  playWarningBeep() {
    if (!this.enabled) return;
    try {
      this.init();
      if (!this.ctx) return;
      const osc = this.ctx.createOscillator();
      const gain = this.ctx.createGain();
      osc.type = 'triangle';
      osc.frequency.setValueAtTime(320, this.ctx.currentTime);
      gain.gain.setValueAtTime(0.1, this.ctx.currentTime);
      gain.gain.exponentialRampToValueAtTime(0.001, this.ctx.currentTime + 0.2);
      osc.connect(gain);
      gain.connect(this.ctx.destination);
      osc.start();
      osc.stop(this.ctx.currentTime + 0.2);
    } catch (e) {}
  }

  playVictoryFanfare() {
    if (!this.enabled) return;
    try {
      this.init();
      if (!this.ctx) return;
      const notes = [523.25, 659.25, 783.99, 1046.50]; // C5, E5, G5, C6
      notes.forEach((freq, idx) => {
        const osc = this.ctx.createOscillator();
        const gain = this.ctx.createGain();
        osc.type = 'sine';
        osc.frequency.setValueAtTime(freq, this.ctx.currentTime + idx * 0.1);
        gain.gain.setValueAtTime(0.15, this.ctx.currentTime + idx * 0.1);
        gain.gain.exponentialRampToValueAtTime(0.001, this.ctx.currentTime + idx * 0.1 + 0.3);
        osc.connect(gain);
        gain.connect(this.ctx.destination);
        osc.start(this.ctx.currentTime + idx * 0.1);
        osc.stop(this.ctx.currentTime + idx * 0.1 + 0.3);
      });
    } catch (e) {}
  }

  toggle(enabled) {
    this.enabled = enabled;
  }
}

export class SpeechCoach {
  constructor() {
    this.synth = typeof window !== 'undefined' && 'speechSynthesis' in window ? window.speechSynthesis : null;
    this.lastSpokenText = '';
    this.lastSpokenTime = 0;
    this.enabled = true;
    this.sfx = new SoundEffects();
  }

  speak(text, isWarning = false) {
    if (isWarning) {
      this.sfx.playWarningBeep();
    }
    if (!this.synth || !this.enabled) return;
    const now = Date.now();
    // 3-second cooldown to prevent repetitive spam
    if (text === this.lastSpokenText && now - this.lastSpokenTime < 3200) return;

    this.synth.cancel(); // Clear queued speech
    const utterance = new SpeechSynthesisUtterance(text);
    utterance.rate = 1.05;
    utterance.pitch = 1.0;
    this.synth.speak(utterance);
    this.lastSpokenText = text;
    this.lastSpokenTime = now;
  }

  toggle(enabled) {
    this.enabled = enabled;
    this.sfx.toggle(enabled);
  }
}

export function drawSkeletonOverlay(ctx, width, height, landmarks, status = 'GOOD', primaryAngle = null, primaryJointKey = 'LEFT_KNEE') {
  if (!ctx || !landmarks || Object.keys(landmarks).length === 0) return;

  ctx.clearRect(0, 0, width, height);

  const colorMap = {
    GOOD: '#10B981',    // Neon Emerald Green
    WARNING: '#F59E0B', // Amber Yellow
    INCORRECT: '#EF4444'// Crimson Red
  };

  const mainColor = colorMap[status] || '#10B981';

  // Bone Connections
  const connections = [
    ['LEFT_SHOULDER', 'RIGHT_SHOULDER'],
    ['LEFT_SHOULDER', 'LEFT_ELBOW'],
    ['LEFT_ELBOW', 'LEFT_WRIST'],
    ['RIGHT_SHOULDER', 'RIGHT_ELBOW'],
    ['RIGHT_ELBOW', 'RIGHT_WRIST'],
    ['LEFT_SHOULDER', 'LEFT_HIP'],
    ['RIGHT_SHOULDER', 'RIGHT_HIP'],
    ['LEFT_HIP', 'RIGHT_HIP'],
    ['LEFT_HIP', 'LEFT_KNEE'],
    ['LEFT_KNEE', 'LEFT_ANKLE'],
    ['RIGHT_HIP', 'RIGHT_KNEE'],
    ['RIGHT_KNEE', 'RIGHT_ANKLE'],
  ];

  ctx.lineWidth = 4;
  ctx.strokeStyle = mainColor;
  ctx.lineCap = 'round';
  ctx.lineJoin = 'round';

  // Draw Wireframe Bones
  connections.forEach(([p1Key, p2Key]) => {
    const p1 = landmarks[p1Key];
    const p2 = landmarks[p2Key];
    if (p1 && p2) {
      ctx.beginPath();
      ctx.moveTo(p1.x * width, p1.y * height);
      ctx.lineTo(p2.x * width, p2.y * height);
      ctx.stroke();
    }
  });

  // Render Joint Nodes
  Object.entries(landmarks).forEach(([key, lm]) => {
    const x = lm.x * width;
    const y = lm.y * height;

    const isPrimary = key === primaryJointKey;

    // Outer Halo
    ctx.beginPath();
    ctx.arc(x, y, isPrimary ? 12 : 8, 0, 2 * Math.PI);
    ctx.fillStyle = mainColor + '55';
    ctx.fill();

    // Joint Outline
    ctx.beginPath();
    ctx.arc(x, y, isPrimary ? 7 : 5, 0, 2 * Math.PI);
    ctx.fillStyle = mainColor;
    ctx.fill();

    // Center Core
    ctx.beginPath();
    ctx.arc(x, y, isPrimary ? 3.5 : 2.5, 0, 2 * Math.PI);
    ctx.fillStyle = '#FFFFFF';
    ctx.fill();
  });

  // Draw Angle Bubble near active primary joint
  if (primaryAngle !== null && landmarks[primaryJointKey]) {
    const pj = landmarks[primaryJointKey];
    const jx = pj.x * width + 20;
    const jy = pj.y * height - 10;

    ctx.save();
    ctx.fillStyle = 'rgba(15, 23, 42, 0.85)';
    ctx.strokeStyle = mainColor;
    ctx.lineWidth = 1.5;
    ctx.beginPath();
    ctx.roundRect(jx - 6, jy - 14, 52, 22, 6);
    ctx.fill();
    ctx.stroke();

    ctx.fillStyle = mainColor;
    ctx.font = 'bold 12px monospace';
    ctx.fillText(`${primaryAngle}°`, jx, jy + 2);
    ctx.restore();
  }
}
