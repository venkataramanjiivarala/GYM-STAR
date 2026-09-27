import React from 'react';
import { Home, Dumbbell, Camera, Activity, Award } from 'lucide-react';

export default function Navigation({ activeTab, setActiveTab }) {
  const tabs = [
    { id: 'home', label: 'Home', icon: Home },
    { id: 'workouts', label: 'Workouts', icon: Dumbbell },
    { id: 'camera', label: 'AI Coach', icon: Camera, highlight: true },
    { id: 'yoga', label: 'Yoga', icon: Activity },
    { id: 'progress', label: 'Progress', icon: Award },
  ];

  return (
    <nav className="fixed bottom-0 left-0 right-0 z-40 bg-[#0F172A]/95 backdrop-blur-lg border-t border-slate-800 px-3 py-2">
      <div className="max-w-md mx-auto flex items-center justify-around">
        {tabs.map((t) => {
          const Icon = t.icon;
          const isActive = activeTab === t.id;

          if (t.highlight) {
            return (
              <button
                key={t.id}
                onClick={() => setActiveTab(t.id)}
                className={`flex flex-col items-center -mt-6 ${
                  isActive ? 'scale-105' : 'hover:scale-105'
                } transition-all duration-200`}
              >
                <div className="w-14 h-14 rounded-2xl bg-gradient-to-tr from-emerald-500 to-teal-600 flex items-center justify-center shadow-lg shadow-emerald-500/30 border-2 border-[#0F172A]">
                  <Camera className="w-7 h-7 text-white" />
                </div>
                <span className="text-[11px] font-bold text-emerald-400 mt-1">AI Coach</span>
              </button>
            );
          }

          return (
            <button
              key={t.id}
              onClick={() => setActiveTab(t.id)}
              className={`flex flex-col items-center py-1 px-3 rounded-xl transition-all ${
                isActive
                  ? 'text-indigo-400 font-semibold bg-indigo-500/10'
                  : 'text-slate-400 hover:text-slate-200'
              }`}
            >
              <Icon className="w-5 h-5 mb-0.5" />
              <span className="text-[11px]">{t.label}</span>
            </button>
          );
        })}
      </div>
    </nav>
  );
}
