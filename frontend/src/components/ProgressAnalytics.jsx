import React, { useState } from 'react';
import {
  Award, TrendingUp, Flame, Zap, ShieldCheck, Calendar,
  Activity, CheckCircle2, ChevronRight, Target, Sparkles
} from 'lucide-react';

export default function ProgressAnalytics({ dashboardData }) {
  const [activeMetric, setActiveMetric] = useState('form');

  const trend = dashboardData?.weekly_form_trend || [
    { day: 'Mon', form_score: 78, reps: 32, calories: 140 },
    { day: 'Tue', form_score: 81, reps: 45, calories: 190 },
    { day: 'Wed', form_score: 85, reps: 50, calories: 210 },
    { day: 'Thu', form_score: 88, reps: 60, calories: 260 },
    { day: 'Fri', form_score: 92, reps: 65, calories: 320 },
    { day: 'Sat', form_score: 94, reps: 70, calories: 350 },
    { day: 'Sun', form_score: 95, reps: 75, calories: 380 }
  ];

  const badges = [
    { id: 'b1', name: '7-Day Streak Warrior', desc: 'Maintained consecutive daily training', icon: '🔥', unlocked: true },
    { id: 'b2', name: 'Form Precision Master', desc: 'Achieved >94% form accuracy across sessions', icon: '🛡️', unlocked: true },
    { id: 'b3', name: 'Century Rep Club', desc: 'Completed over 350 total biometric reps', icon: '⚡', unlocked: true },
    { id: 'b4', name: 'Yoga Zen Hold', desc: 'Held balance posture flawlessly for 45s', icon: '🧘', unlocked: true },
    { id: 'b5', name: 'Calorie Crusher', desc: 'Burned 1,500+ estimated metabolic kcal', icon: '🏆', unlocked: true },
    { id: 'b6', name: 'Flawless Centurion', desc: 'Complete 100 reps with zero warnings', icon: '👑', unlocked: false }
  ];

  const muscleBreakdown = [
    { name: 'Quadriceps & Glutes', pct: 42, color: 'bg-emerald-500' },
    { name: 'Chest & Triceps', pct: 28, color: 'bg-indigo-500' },
    { name: 'Core & Abdominals', pct: 18, color: 'bg-purple-500' },
    { name: 'Biceps & Forearms', pct: 12, color: 'bg-amber-500' }
  ];

  return (
    <div className="space-y-6 pb-24 font-['Inter']">
      <div>
        <h2 className="text-xl sm:text-2xl font-black text-slate-100">Performance & Biometric Analytics</h2>
        <p className="text-xs text-slate-400">Track your posture progression, joint accuracy, and workout milestones</p>
      </div>

      {/* KPI Stats Grid */}
      <div className="grid grid-cols-2 sm:grid-cols-4 gap-3.5">
        <div className="p-4 rounded-2xl bg-slate-800/85 border border-slate-700/70 glass-card">
          <span className="text-[10px] text-slate-400 font-semibold block uppercase tracking-wider">Form Accuracy</span>
          <span className="text-2xl font-black text-emerald-400 mt-1 block font-mono">
            {dashboardData?.avg_form_score || 94.5}%
          </span>
          <span className="text-[10px] text-emerald-400 font-medium flex items-center mt-1">
            <TrendingUp className="w-3 h-3 mr-1" /> +12% this week
          </span>
        </div>

        <div className="p-4 rounded-2xl bg-slate-800/85 border border-slate-700/70 glass-card">
          <span className="text-[10px] text-slate-400 font-semibold block uppercase tracking-wider">Workout Streak</span>
          <span className="text-2xl font-black text-amber-400 mt-1 block font-mono">
            {dashboardData?.streak_days || 7} Days
          </span>
          <span className="text-[10px] text-amber-400 font-medium flex items-center mt-1">
            <Flame className="w-3 h-3 mr-1" /> Personal best record!
          </span>
        </div>

        <div className="p-4 rounded-2xl bg-slate-800/85 border border-slate-700/70 glass-card">
          <span className="text-[10px] text-slate-400 font-semibold block uppercase tracking-wider">Total Workouts</span>
          <span className="text-2xl font-black text-indigo-400 mt-1 block font-mono">
            {dashboardData?.total_workouts || 14} Sessions
          </span>
          <span className="text-[10px] text-indigo-400 font-medium flex items-center mt-1">
            <Activity className="w-3 h-3 mr-1" /> 100% On track
          </span>
        </div>

        <div className="p-4 rounded-2xl bg-slate-800/85 border border-slate-700/70 glass-card">
          <span className="text-[10px] text-slate-400 font-semibold block uppercase tracking-wider">Calories Burned</span>
          <span className="text-2xl font-black text-purple-400 mt-1 block font-mono">
            {Math.round(dashboardData?.total_calories || 1850)} kcal
          </span>
          <span className="text-[10px] text-purple-400 font-medium flex items-center mt-1">
            <Zap className="w-3 h-3 mr-1" /> Weekly target met
          </span>
        </div>
      </div>

      {/* Weekly Form Score Progression Chart */}
      <div className="p-6 rounded-3xl bg-slate-800/85 border border-slate-700/70 glass-card space-y-4 shadow-xl">
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-2">
          <div>
            <h3 className="text-base font-bold text-white">Weekly Biomechanical Form Score</h3>
            <p className="text-xs text-slate-400">Postural accuracy recorded across all AI camera sessions</p>
          </div>

          <div className="flex items-center space-x-2">
            <button
              onClick={() => setActiveMetric('form')}
              className={`px-3 py-1.5 rounded-xl text-xs font-bold transition-all ${
                activeMetric === 'form'
                  ? 'bg-emerald-500/20 text-emerald-300 border border-emerald-500/40'
                  : 'text-slate-400 hover:text-white'
              }`}
            >
              Form %
            </button>
            <button
              onClick={() => setActiveMetric('reps')}
              className={`px-3 py-1.5 rounded-xl text-xs font-bold transition-all ${
                activeMetric === 'reps'
                  ? 'bg-indigo-500/20 text-indigo-300 border border-indigo-500/40'
                  : 'text-slate-400 hover:text-white'
              }`}
            >
              Reps
            </button>
            <button
              onClick={() => setActiveMetric('calories')}
              className={`px-3 py-1.5 rounded-xl text-xs font-bold transition-all ${
                activeMetric === 'calories'
                  ? 'bg-amber-500/20 text-amber-300 border border-amber-500/40'
                  : 'text-slate-400 hover:text-white'
              }`}
            >
              Calories
            </button>
          </div>
        </div>

        {/* Custom Interactive SVG / HTML Bar Chart */}
        <div className="h-48 flex items-end justify-between gap-2 pt-6 pb-2 border-b border-slate-700/60 px-2">
          {trend.map((item, idx) => {
            let val = item.form_score;
            let displayVal = `${item.form_score}%`;
            let heightPct = ((item.form_score - 50) / 50) * 100;
            let barColor = 'from-indigo-600 to-emerald-400';

            if (activeMetric === 'reps') {
              val = item.reps;
              displayVal = `${item.reps} reps`;
              heightPct = (item.reps / 80) * 100;
              barColor = 'from-indigo-600 to-purple-400';
            } else if (activeMetric === 'calories') {
              val = item.calories;
              displayVal = `${item.calories} kcal`;
              heightPct = (item.calories / 400) * 100;
              barColor = 'from-amber-600 to-yellow-400';
            }

            return (
              <div key={idx} className="flex-1 flex flex-col items-center gap-2 group cursor-pointer">
                <span className="text-[10px] font-mono font-bold text-slate-300 opacity-0 group-hover:opacity-100 transition-opacity">
                  {displayVal}
                </span>
                <div className="w-full max-w-[32px] bg-slate-700/40 rounded-t-xl overflow-hidden h-32 flex items-end">
                  <div
                    className={`w-full bg-gradient-to-t ${barColor} rounded-t-xl transition-all duration-500 group-hover:brightness-125`}
                    style={{ height: `${Math.max(15, Math.min(100, heightPct))}%` }}
                  />
                </div>
                <span className="text-xs text-slate-400 font-semibold">{item.day}</span>
              </div>
            );
          })}
        </div>
      </div>

      {/* Muscle Focus Breakdown & Achievement Badges Grid */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
        {/* Muscle Focus */}
        <div className="p-5 rounded-3xl bg-slate-800/85 border border-slate-700/70 glass-card space-y-4">
          <div className="flex items-center space-x-2 text-white">
            <Target className="w-4 h-4 text-indigo-400" />
            <h3 className="text-sm font-bold">Target Muscle Volume Distribution</h3>
          </div>

          <div className="space-y-3 pt-1">
            {muscleBreakdown.map((m, idx) => (
              <div key={idx} className="space-y-1">
                <div className="flex justify-between text-xs font-semibold">
                  <span className="text-slate-300">{m.name}</span>
                  <span className="text-slate-400 font-mono">{m.pct}%</span>
                </div>
                <div className="h-2 w-full bg-slate-700/50 rounded-full overflow-hidden">
                  <div className={`h-full ${m.color} rounded-full`} style={{ width: `${m.pct}%` }} />
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Milestone Badges */}
        <div className="p-5 rounded-3xl bg-slate-800/85 border border-slate-700/70 glass-card space-y-4">
          <div className="flex items-center space-x-2 text-white">
            <Award className="w-4 h-4 text-amber-400" />
            <h3 className="text-sm font-bold">Earned Milestones & Badges</h3>
          </div>

          <div className="grid grid-cols-2 sm:grid-cols-3 gap-2.5">
            {badges.map((b) => (
              <div
                key={b.id}
                className={`p-3 rounded-2xl border flex flex-col items-center text-center space-y-1.5 transition-all ${
                  b.unlocked
                    ? 'bg-slate-800/90 border-amber-500/30 text-white'
                    : 'bg-slate-900/50 border-slate-800 text-slate-600 opacity-60'
                }`}
              >
                <div className="text-2xl">{b.icon}</div>
                <h5 className="text-[11px] font-bold leading-tight">{b.name}</h5>
                <span className="text-[9px] text-slate-400 leading-tight line-clamp-2">
                  {b.desc}
                </span>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}
