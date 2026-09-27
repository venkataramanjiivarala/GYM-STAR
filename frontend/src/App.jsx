import React, { useState, useEffect } from 'react';
import Header from './components/Header';
import Navigation from './components/Navigation';
import HomeDashboard from './components/HomeDashboard';
import ExerciseLibrary from './components/ExerciseLibrary';
import AiCameraCoach from './components/AiCameraCoach';
import YogaModule from './components/YogaModule';
import ProgressAnalytics from './components/ProgressAnalytics';
import ProfileSettings from './components/ProfileSettings';
import AiCoachChatModal from './components/AiCoachChatModal';
import { fetchExercises, fetchYogaPoses, fetchDashboardAnalytics } from './services/api';
import { Camera, Sparkles, Activity, ShieldCheck } from 'lucide-react';

export default function App() {
  const [activeTab, setActiveTab] = useState('home');
  const [exercises, setExercises] = useState([]);
  const [yogaPoses, setYogaPoses] = useState([]);
  const [dashboardData, setDashboardData] = useState(null);

  const [activeCameraExercise, setActiveCameraExercise] = useState(null);
  const [isCameraYoga, setIsCameraYoga] = useState(false);
  const [showCoachChat, setShowCoachChat] = useState(false);
  const [showProfileModal, setShowProfileModal] = useState(false);

  const reloadDashboard = async () => {
    const dashData = await fetchDashboardAnalytics();
    setDashboardData(dashData);
  };

  useEffect(() => {
    async function loadData() {
      const [exData, yogaData, dashData] = await Promise.all([
        fetchExercises(),
        fetchYogaPoses(),
        fetchDashboardAnalytics()
      ]);
      setExercises(exData);
      setYogaPoses(yogaData);
      setDashboardData(dashData);
    }
    loadData();
  }, []);

  const handleStartCamera = (exerciseKey = 'squat', isYoga = false) => {
    setActiveCameraExercise(exerciseKey);
    setIsCameraYoga(isYoga);
  };

  return (
    <div className="min-h-screen bg-[#0F172A] text-slate-100 flex flex-col font-['Inter'] selection:bg-indigo-500 selection:text-white">
      <Header
        onOpenCoach={() => setShowCoachChat(true)}
        onOpenProfile={() => setShowProfileModal(true)}
      />

      <main className="flex-1 max-w-6xl w-full mx-auto p-4 sm:p-6">
        {activeTab === 'home' && (
          <HomeDashboard
            onSelectExercise={handleStartCamera}
            onStartCamera={handleStartCamera}
            dashboardData={dashboardData}
          />
        )}

        {activeTab === 'workouts' && (
          <ExerciseLibrary
            exercises={exercises}
            onStartCamera={(key) => handleStartCamera(key, false)}
          />
        )}

        {activeTab === 'camera' && (
          <div className="py-12 sm:py-16 text-center space-y-5 max-w-md mx-auto">
            <div className="w-20 h-20 rounded-3xl bg-indigo-600/20 text-indigo-400 border border-indigo-500/30 flex items-center justify-center mx-auto shadow-xl shadow-indigo-600/15 ring-8 ring-indigo-500/10">
              <Camera className="w-10 h-10 animate-pulse" />
            </div>
            <div className="space-y-1.5">
              <h2 className="text-2xl font-black text-white">AI Posture Camera</h2>
              <p className="text-xs text-slate-400 max-w-xs mx-auto leading-relaxed">
                Step into the frame for real-time joint landmark detection, angle calculation, and speech audio coaching.
              </p>
            </div>
            <div className="flex flex-col gap-2.5 pt-2">
              <button
                onClick={() => handleStartCamera('squat', false)}
                className="w-full py-4 rounded-2xl bg-gradient-to-r from-emerald-500 to-teal-600 hover:from-emerald-400 hover:to-teal-500 text-white font-black text-sm shadow-xl shadow-emerald-500/25 transition-all hover:scale-[1.02] active:scale-98"
              >
                Launch AI Squat Coach
              </button>
              <button
                onClick={() => handleStartCamera('tree_pose', true)}
                className="w-full py-3.5 rounded-2xl bg-slate-800 hover:bg-slate-700 text-slate-200 font-bold text-xs border border-slate-700 transition-all"
              >
                🧘 Launch Yoga Balance Coach
              </button>
            </div>
          </div>
        )}

        {activeTab === 'yoga' && (
          <YogaModule
            yogaPoses={yogaPoses}
            onStartCamera={(key) => handleStartCamera(key, true)}
          />
        )}

        {activeTab === 'progress' && (
          <ProgressAnalytics dashboardData={dashboardData} />
        )}
      </main>

      <Navigation activeTab={activeTab} setActiveTab={setActiveTab} />

      {/* Camera Live Overlay */}
      {activeCameraExercise && (
        <AiCameraCoach
          selectedExerciseKey={activeCameraExercise}
          isYoga={isCameraYoga}
          onClose={() => setActiveCameraExercise(null)}
          onWorkoutSaved={() => {
            reloadDashboard();
          }}
        />
      )}

      {/* AI Coach Chat Bot Modal */}
      {showCoachChat && (
        <AiCoachChatModal onClose={() => setShowCoachChat(false)} />
      )}

      {/* Profile Settings Modal */}
      {showProfileModal && (
        <div className="fixed inset-0 z-50 bg-black/85 backdrop-blur-md flex items-center justify-center p-4">
          <div className="max-w-xl w-full max-h-[90vh] overflow-y-auto bg-slate-900 border border-slate-700/80 rounded-3xl p-6 sm:p-7 relative shadow-2xl">
            <button
              onClick={() => setShowProfileModal(false)}
              className="absolute top-5 right-5 text-slate-400 hover:text-white p-1 rounded-xl bg-slate-800"
            >
              ✕
            </button>
            <ProfileSettings onClose={() => setShowProfileModal(false)} />
          </div>
        </div>
      )}
    </div>
  );
}
