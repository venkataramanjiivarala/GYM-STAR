# GYM-STAR 🌟

> **Train Smarter. Move Better.**

GYM-STAR is a comprehensive AI-powered Personal Fitness & Yoga Coach platform. It uses cutting-edge machine learning for real-time pose detection, analyzing your form as you work out, and providing immediate voice and visual feedback.

The platform is split into three main components: a powerful **Python/FastAPI Backend**, a **Flutter Mobile Application**, and a **React/Vite Web Dashboard**.

## 🚀 Features

- **Real-Time AI Pose Detection**: Leverages Google ML Kit to analyze your form during workouts and yoga sessions.
- **Audio & Visual Feedback**: Uses Text-to-Speech (TTS) to provide real-time coaching adjustments.
- **Yoga & Exercise Modules**: Tailored routines for both high-intensity workouts and yoga mindfulness.
- **Progress Analytics**: Tracks your workouts and visualizes your progress over time using interactive charts.
- **Web Dashboard & Mobile App**: Access your profile and coaching anywhere, on any device.

---

## 🏗️ Architecture & Tech Stack

### 1. Mobile Application (`/flutter_app`)
The primary interface for users to get AI coaching.
- **Framework**: Flutter (Dart)
- **State Management**: Riverpod
- **Routing**: Go Router
- **AI/ML**: `google_mlkit_pose_detection` & `camera`
- **Other Tools**: `web_socket_channel` (for real-time data streaming), `flutter_tts` (for coaching voice), `fl_chart` (analytics).

### 2. Backend API (`/backend`)
The brain of the platform, handling authentication, data storage, and WebSocket streaming.
- **Framework**: FastAPI (Python)
- **Database**: SQLite with SQLAlchemy ORM
- **Validation**: Pydantic
- **Authentication**: JWT (python-jose, passlib)
- **Real-time**: WebSockets

### 3. Web Dashboard (`/frontend`)
A sleek, modern web interface for users to view analytics and manage their profile.
- **Framework**: React 18 & Vite
- **Styling**: Tailwind CSS
- **Icons**: Lucide React

---

## 🛠️ Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (>=3.0.0)
- [Python 3.9+](https://www.python.org/downloads/)
- [Node.js & npm](https://nodejs.org/)

### 1. Running the Backend
Navigate to the `backend` directory and start the FastAPI server:
```bash
cd backend
pip install -r requirements.txt
python -m app.main
```
> The API will be available at `http://127.0.0.1:8000`. You can view the swagger documentation at `/docs`.

### 2. Running the Web Frontend
Navigate to the `frontend` directory and start the Vite dev server:
```bash
cd frontend
npm install
npm run dev
```
> The web dashboard will be available at `http://localhost:3000`.

### 3. Running the Flutter App
Navigate to the `flutter_app` directory:
```bash
cd flutter_app
flutter pub get
flutter run
```
> Select your target device (Chrome, Windows Desktop, or Mobile Emulator).

---

## 📜 License
This project is open-source and available under standard licenses.
