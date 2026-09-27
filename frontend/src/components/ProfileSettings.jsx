import React, { useState, useEffect } from 'react';
import {
  User, ShieldCheck, Volume2, Bell, Settings, Award, Lock,
  Save, Sparkles, CheckCircle2, Calendar, Target, Activity
} from 'lucide-react';
import { fetchUserProfile, updateUserProfile, fetchAIPersonalizedPlan } from '../services/api';

export default function ProfileSettings({ onClose }) {
  const [profile, setProfile] = useState({
    name: 'Ramanji',
    email: 'raman@gymstar.ai',
    age: 25,
    gender: 'male',
    height_cm: 175,
    weight_kg: 70,
    fitness_level: 'Beginner',
    primary_goal: 'Strength & Form',
    workout_frequency: 4,
    equipment: 'Bodyweight',
    voice_coaching: true
  });

  const [aiPlan, setAiPlan] = useState(null);
  const [saving, setSaving] = useState(false);
  const [saveSuccess, setSaveSuccess] = useState(false);

  useEffect(() => {
    async function load() {
      const user = await fetchUserProfile();
      if (user?.profile) {
        setProfile({
          name: user.name || 'Ramanji',
          email: user.email || 'raman@gymstar.ai',
          ...user.profile
        });
      }
      const plan = await fetchAIPersonalizedPlan();
      setAiPlan(plan);
    }
    load();
  }, []);

  const handleSave = async (e) => {
    e.preventDefault();
    setSaving(true);
    await updateUserProfile(profile);
    const updatedPlan = await fetchAIPersonalizedPlan();
    setAiPlan(updatedPlan);
    setSaving(false);
    setSaveSuccess(true);
    setTimeout(() => setSaveSuccess(false), 3000);
  };

  return (
    <div className="space-y-6 pb-20 font-['Inter']">
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-xl font-black text-slate-100">Athlete Profile & AI Coaching</h2>
          <p className="text-xs text-slate-400">Configure biometric parameters and personalized coaching routines</p>
        </div>
      </div>

      {/* Profile Header Card */}
      <div className="p-5 rounded-3xl bg-gradient-to-r from-slate-800 to-indigo-950/60 border border-slate-700/60 glass-card flex items-center space-x-4 shadow-xl">
        <div className="w-16 h-16 rounded-2xl bg-gradient-to-tr from-indigo-500 to-purple-600 flex items-center justify-center text-white font-black text-2xl shadow-lg shadow-indigo-500/20 shrink-0">
          R
        </div>
        <div className="space-y-1">
          <div className="flex items-center space-x-2">
            <h3 className="text-lg font-bold text-white">{profile.name}</h3>
            <span className="text-[10px] font-black uppercase tracking-wider px-2 py-0.5 rounded-full bg-emerald-500/20 text-emerald-400 border border-emerald-500/30">
              Pro Athlete
            </span>
          </div>
          <p className="text-xs text-indigo-300 font-medium">{profile.email}</p>
        </div>
      </div>

      {/* Profile Parameters Form */}
      <form onSubmit={handleSave} className="space-y-4">
        <div className="p-5 rounded-3xl bg-slate-800/85 border border-slate-700/70 glass-card space-y-4">
          <h4 className="text-xs font-bold uppercase tracking-wider text-indigo-400 flex items-center">
            <Target className="w-4 h-4 mr-1.5" />
            Biometric & Fitness Parameters
          </h4>

          <div className="grid grid-cols-1 sm:grid-cols-2 gap-3.5">
            <div>
              <label className="text-xs text-slate-300 font-medium block mb-1">Primary Fitness Goal</label>
              <select
                value={profile.primary_goal}
                onChange={(e) => setProfile({ ...profile, primary_goal: e.target.value })}
                className="w-full bg-slate-900 border border-slate-700 rounded-xl px-3.5 py-2.5 text-xs text-slate-100 focus:outline-none focus:border-indigo-500 transition-all"
              >
                <option value="Strength & Form">Strength & Form Optimization</option>
                <option value="Weight Loss">Weight Loss & HIIT Burn</option>
                <option value="Flexibility">Yoga & Mobility Alignment</option>
                <option value="Muscle Gain">Hypertrophy & Muscle Gain</option>
              </select>
            </div>

            <div>
              <label className="text-xs text-slate-300 font-medium block mb-1">Experience Level</label>
              <select
                value={profile.fitness_level}
                onChange={(e) => setProfile({ ...profile, fitness_level: e.target.value })}
                className="w-full bg-slate-900 border border-slate-700 rounded-xl px-3.5 py-2.5 text-xs text-slate-100 focus:outline-none focus:border-indigo-500 transition-all"
              >
                <option value="Beginner">Beginner (Guided AI Prompts)</option>
                <option value="Intermediate">Intermediate (Standard Tolerances)</option>
                <option value="Advanced">Advanced (Strict Biomechanics)</option>
              </select>
            </div>

            <div>
              <label className="text-xs text-slate-300 font-medium block mb-1">Height (cm)</label>
              <input
                type="number"
                value={profile.height_cm}
                onChange={(e) => setProfile({ ...profile, height_cm: parseFloat(e.target.value) || 0 })}
                className="w-full bg-slate-900 border border-slate-700 rounded-xl px-3.5 py-2.5 text-xs text-slate-100 focus:outline-none focus:border-indigo-500"
              />
            </div>

            <div>
              <label className="text-xs text-slate-300 font-medium block mb-1">Weight (kg)</label>
              <input
                type="number"
                value={profile.weight_kg}
                onChange={(e) => setProfile({ ...profile, weight_kg: parseFloat(e.target.value) || 0 })}
                className="w-full bg-slate-900 border border-slate-700 rounded-xl px-3.5 py-2.5 text-xs text-slate-100 focus:outline-none focus:border-indigo-500"
              />
            </div>

            <div>
              <label className="text-xs text-slate-300 font-medium block mb-1">Target Frequency (Days/Wk)</label>
              <select
                value={profile.workout_frequency}
                onChange={(e) => setProfile({ ...profile, workout_frequency: parseInt(e.target.value) || 4 })}
                className="w-full bg-slate-900 border border-slate-700 rounded-xl px-3.5 py-2.5 text-xs text-slate-100 focus:outline-none focus:border-indigo-500"
              >
                <option value={3}>3 Days / Week (Foundation)</option>
                <option value={4}>4 Days / Week (Optimal)</option>
                <option value={5}>5 Days / Week (Accelerated)</option>
                <option value={6}>6 Days / Week (Athlete)</option>
              </select>
            </div>

            <div>
              <label className="text-xs text-slate-300 font-medium block mb-1">Equipment Setup</label>
              <select
                value={profile.equipment}
                onChange={(e) => setProfile({ ...profile, equipment: e.target.value })}
                className="w-full bg-slate-900 border border-slate-700 rounded-xl px-3.5 py-2.5 text-xs text-slate-100 focus:outline-none focus:border-indigo-500"
              >
                <option value="Bodyweight">Bodyweight & Mat Only</option>
                <option value="Dumbbells">Dumbbells & Resistance Bands</option>
                <option value="Full Gym">Full Commercial Gym</option>
              </select>
            </div>
          </div>
        </div>

        {/* Audio Coach Settings */}
        <div className="p-5 rounded-3xl bg-slate-800/85 border border-slate-700/70 glass-card flex items-center justify-between">
          <div className="space-y-0.5">
            <h4 className="text-sm font-bold text-white flex items-center">
              <Volume2 className="w-4 h-4 mr-2 text-indigo-400" />
              Real-Time Speech Synthesis Voice Coach
            </h4>
            <p className="text-xs text-slate-400">Audible rep counting and instant posture correction prompts</p>
          </div>
          <button
            type="button"
            onClick={() => setProfile({ ...profile, voice_coaching: !profile.voice_coaching })}
            className={`w-12 h-6 rounded-full transition-colors relative p-0.5 ${
              profile.voice_coaching ? 'bg-indigo-600' : 'bg-slate-700'
            }`}
          >
            <div
              className={`w-5 h-5 rounded-full bg-white transition-transform duration-200 ${
                profile.voice_coaching ? 'translate-x-6' : 'translate-x-0'
              }`}
            />
          </button>
        </div>

        <div className="flex items-center space-x-3">
          <button
            type="submit"
            disabled={saving}
            className="flex-1 py-3.5 rounded-2xl bg-indigo-600 hover:bg-indigo-500 text-white font-bold text-xs shadow-lg shadow-indigo-600/30 flex items-center justify-center space-x-2 transition-all active:scale-98"
          >
            <Save className="w-4 h-4" />
            <span>{saving ? 'Saving Profile...' : 'Save Profile Changes'}</span>
          </button>

          {saveSuccess && (
            <span className="text-xs text-emerald-400 font-bold flex items-center animate-fade-in">
              <CheckCircle2 className="w-4 h-4 mr-1" />
              Saved!
            </span>
          )}
        </div>
      </form>

      {/* Dynamic 7-Day AI Routine Preview */}
      {aiPlan && (
        <div className="p-5 rounded-3xl bg-slate-800/85 border border-indigo-500/30 glass-card space-y-4 shadow-xl">
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-2">
              <Sparkles className="w-4 h-4 text-amber-300" />
              <h4 className="text-sm font-bold text-white">{aiPlan.title}</h4>
            </div>
            <span className="text-[10px] uppercase font-mono px-2 py-0.5 rounded-md bg-indigo-500/20 text-indigo-300">
              7-Day Cycle
            </span>
          </div>

          <p className="text-xs text-slate-300 leading-relaxed italic bg-indigo-950/40 p-3 rounded-2xl border border-indigo-500/20">
            "{aiPlan.coach_tip}"
          </p>

          <div className="space-y-2">
            {aiPlan.weekly_schedule?.map((item, idx) => (
              <div
                key={idx}
                className="p-3 rounded-2xl bg-slate-900/70 border border-slate-700/60 flex items-center justify-between text-xs"
              >
                <div className="flex items-center space-x-2.5">
                  <span className="font-bold text-slate-200 w-20">{item.day}</span>
                  <span className="text-slate-400">•</span>
                  <span className="text-slate-300">{item.focus}</span>
                </div>
                <div className="flex items-center space-x-2">
                  <span className={`font-semibold px-2 py-0.5 rounded-lg text-[10px] ${
                    item.type === 'Yoga'
                      ? 'bg-teal-500/10 text-teal-400 border border-teal-500/20'
                      : item.type === 'Rest'
                      ? 'bg-slate-700/40 text-slate-400'
                      : 'bg-indigo-500/10 text-indigo-400 border border-indigo-500/20'
                  }`}>
                    {item.type}
                  </span>
                  <span className="text-[11px] font-mono text-slate-400">{item.duration}</span>
                </div>
              </div>
            ))}
          </div>
        </div>
      )}
    </div>
  );
}
