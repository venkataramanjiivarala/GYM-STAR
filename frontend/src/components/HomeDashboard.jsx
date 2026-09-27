import React from 'react';
import {
  Play, Flame, Award, Zap, ChevronRight, Activity, ShieldCheck,
  CheckCircle2, Clock, Sparkles, Dumbbell, Calendar, ArrowUpRight
} from 'lucide-react';

export default function HomeDashboard({ onSelectExercise, onStartCamera, dashboardData }) {
  const stats = [
    {
      label: 'Workout Streak',
      val: `${dashboardData?.streak_days || 7} Days`,
      icon: Flame,
      color: 'text-amber-400',
      bg: 'bg-amber-500/10 border-amber-500/20'
    },
    {
      label: 'Avg Form Score',
      val: `${dashboardData?.avg_form_score || 94.5}%`,
      icon: ShieldCheck,
      color: 'text-emerald-400',
      bg: 'bg-emerald-500/10 border-emerald-500/20'
    },
    {
      label: 'Total Calories',
      val: `${Math.round(dashboardData?.total_calories || 1850)} kcal`,
      icon: Zap,
      color: 'text-indigo-400',
      bg: 'bg-indigo-500/10 border-indigo-500/20'
    },
    {
      label: 'Total Reps',
      val: `${dashboardData?.total_reps || 397}`,
      icon: Activity,
      color: 'text-purple-400',
      bg: 'bg-purple-500/10 border-purple-500/20'
    },
  ];

  const todayPlans = [
    {
      key: 'squat',
      name: 'Bodyweight Squat',
      category: 'Legs',
      duration: '10 Reps • 3 Sets',
      difficulty: 'Beginner',
      formTarget: '90° Knee Depth',
      tag: 'Strength'
    },
    {
      key: 'pushup',
      name: 'Classic Push-Up',
      category: 'Chest',
      duration: '10 Reps • 3 Sets',
      difficulty: 'Beginner',
      formTarget: 'Spine Alignment',
      tag: 'Upper Body'
    },
    {
      key: 'tree_pose',
      name: 'Tree Pose (Yoga)',
      category: 'Balance & Focus',
      duration: '30s Hold • 2 Sets',
      difficulty: 'Beginner',
      formTarget: 'Ankle Stability',
      tag: 'Yoga'
    },
    {
      key: 'bicep_curl',
      name: 'Standing Bicep Curl',
      category: 'Arms',
      duration: '12 Reps • 3 Sets',
      difficulty: 'Beginner',
      formTarget: 'Elbow Lock',
      tag: 'Arms'
    }
  ];

  return (
    <div className="space-y-6 pb-24 font-['Inter']">
      {/* Hero Welcome Banner */}
      <div className="relative overflow-hidden rounded-3xl bg-gradient-to-r from-indigo-600 via-indigo-700 to-purple-800 p-6 sm:p-8 text-white shadow-2xl shadow-indigo-600/25 border border-indigo-500/30">
        <div className="relative z-10 space-y-4">
          <div className="inline-flex items-center space-x-2 px-3 py-1.5 rounded-full bg-white/15 backdrop-blur-md text-xs font-semibold text-indigo-100 border border-white/20">
            <Sparkles className="w-3.5 h-3.5 text-amber-300" />
            <span>AI Real-Time Biomechanics Enabled</span>
          </div>

          <div className="space-y-1">
            <h1 className="text-2xl sm:text-3xl font-black tracking-tight">
              Welcome Back, Ramanji 👋
            </h1>
            <p className="text-sm text-indigo-100/90 max-w-xl leading-relaxed">
              Your AI posture camera is ready. Calibrate your joint positions, receive live voice feedback, and hit your 94%+ form target today.
            </p>
          </div>

          <div className="flex flex-wrap gap-3 pt-2">
            <button
              onClick={() => onStartCamera('squat')}
              className="inline-flex items-center space-x-2 px-6 py-3.5 rounded-2xl bg-white text-indigo-700 font-black text-sm hover:bg-slate-100 transition-all shadow-xl shadow-black/15 active:scale-95"
            >
              <Play className="w-4 h-4 fill-indigo-700" />
              <span>Start Live AI Squat Session</span>
            </button>

            <button
              onClick={() => onStartCamera('tree_pose', true)}
              className="inline-flex items-center space-x-2 px-5 py-3.5 rounded-2xl bg-white/10 hover:bg-white/20 text-white font-bold text-sm border border-white/20 transition-all backdrop-blur-md"
            >
              <span>🧘 Morning Yoga Balance</span>
            </button>
          </div>
        </div>

        {/* Ambient Gradient Blur */}
        <div className="absolute -right-12 -bottom-12 w-64 h-64 bg-purple-500/30 rounded-full blur-3xl pointer-events-none" />
        <div className="absolute right-32 top-0 w-36 h-36 bg-indigo-400/20 rounded-full blur-2xl pointer-events-none" />
      </div>

      {/* Stats Overview Grid */}
      <div className="grid grid-cols-2 sm:grid-cols-4 gap-3.5">
        {stats.map((s, idx) => {
          const Icon = s.icon;
          return (
            <div key={idx} className={`p-4 rounded-2xl border ${s.bg} glass-card space-y-2 transition-all hover:scale-[1.02]`}>
              <div className="flex items-center justify-between">
                <span className="text-xs text-slate-400 font-semibold uppercase tracking-wider">{s.label}</span>
                <Icon className={`w-4 h-4 ${s.color}`} />
              </div>
              <p className={`text-2xl font-black tracking-tight font-mono ${s.color}`}>{s.val}</p>
            </div>
          );
        })}
      </div>

      {/* AI Coach Insight Card */}
      <div className="p-4 sm:p-5 rounded-2xl bg-indigo-950/40 border border-indigo-500/30 flex items-start space-x-3.5 shadow-lg shadow-indigo-950/30">
        <div className="w-10 h-10 rounded-xl bg-indigo-500/20 border border-indigo-500/30 text-indigo-400 flex items-center justify-center shrink-0 mt-0.5">
          <ShieldCheck className="w-5 h-5" />
        </div>
        <div className="space-y-1">
          <div className="flex items-center space-x-2">
            <h4 className="text-xs font-bold text-indigo-300 uppercase tracking-wider">AI Coach Daily Focus</h4>
            <span className="text-[10px] px-2 py-0.5 rounded-md bg-indigo-500/20 text-indigo-300">Biometric Insight</span>
          </div>
          <p className="text-xs text-slate-300 leading-relaxed">
            "Your squat depth hit 85° knee angle in 90% of reps! Today, keep your chest high during descent and maintain equal weight on both feet."
          </p>
        </div>
      </div>

      {/* Today's Recommended Routine */}
      <div className="space-y-3.5">
        <div className="flex items-center justify-between">
          <div>
            <h3 className="text-base font-bold text-slate-100">Today's AI Workout Schedule</h3>
            <p className="text-xs text-slate-400">Personalized sequence aligned with your fitness goals</p>
          </div>
          <span className="text-xs text-slate-400 font-semibold px-2.5 py-1 rounded-lg bg-slate-800 border border-slate-700">
            4 Exercises
          </span>
        </div>

        <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
          {todayPlans.map((ex) => (
            <div
              key={ex.key}
              onClick={() => onSelectExercise(ex.key, ex.tag === 'Yoga')}
              className="p-4 rounded-2xl bg-slate-800/85 hover:bg-slate-800 border border-slate-700/70 hover:border-indigo-500/50 transition-all flex items-center justify-between cursor-pointer group shadow-sm hover:shadow-indigo-500/10"
            >
              <div className="flex items-center space-x-3.5">
                <div className={`w-11 h-11 rounded-xl flex items-center justify-center font-bold ${
                  ex.tag === 'Yoga'
                    ? 'bg-teal-500/10 border border-teal-500/20 text-teal-400'
                    : 'bg-indigo-500/10 border border-indigo-500/20 text-indigo-400'
                }`}>
                  {ex.tag === 'Yoga' ? '🧘' : <Dumbbell className="w-5 h-5" />}
                </div>
                <div>
                  <h4 className="text-sm font-bold text-slate-100 group-hover:text-indigo-400 transition-colors">
                    {ex.name}
                  </h4>
                  <div className="flex items-center space-x-2 text-xs text-slate-400 mt-1">
                    <span className="text-slate-300 font-medium">{ex.category}</span>
                    <span>•</span>
                    <span className="flex items-center text-slate-300">
                      <Clock className="w-3 h-3 mr-1 text-slate-400" />
                      {ex.duration}
                    </span>
                  </div>
                </div>
              </div>

              <div className="flex items-center space-x-2.5">
                <span className="hidden md:inline font-mono text-[11px] px-2.5 py-1 rounded-lg bg-emerald-500/10 text-emerald-400 border border-emerald-500/20 font-semibold">
                  {ex.formTarget}
                </span>
                <div className="w-8 h-8 rounded-xl bg-slate-700/40 group-hover:bg-indigo-600 group-hover:text-white flex items-center justify-center transition-all text-slate-400">
                  <ArrowUpRight className="w-4 h-4" />
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Recent Workouts Log Card */}
      {dashboardData?.recent_sessions && dashboardData.recent_sessions.length > 0 && (
        <div className="space-y-3">
          <h3 className="text-base font-bold text-slate-100">Recent Completed Sessions</h3>
          <div className="space-y-2">
            {dashboardData.recent_sessions.slice(0, 3).map((sess, idx) => (
              <div
                key={sess.id || idx}
                className="p-3.5 rounded-2xl bg-slate-800/70 border border-slate-700/60 flex items-center justify-between text-xs"
              >
                <div className="flex items-center space-x-3">
                  <div className="w-8 h-8 rounded-lg bg-emerald-500/10 text-emerald-400 flex items-center justify-center font-bold">
                    ✓
                  </div>
                  <div>
                    <h5 className="font-bold text-slate-200">{sess.workout_type}</h5>
                    <span className="text-[10px] text-slate-400">
                      {new Date(sess.completed_at).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })} • {sess.total_duration_sec}s Duration
                    </span>
                  </div>
                </div>
                <div className="flex items-center space-x-2">
                  <span className="font-mono font-bold text-emerald-400">{sess.avg_form_score}% Form</span>
                  <span className="text-slate-500">•</span>
                  <span className="font-mono text-amber-400">{sess.total_calories} kcal</span>
                </div>
              </div>
            ))}
          </div>
        </div>
      )}
    </div>
  );
}
