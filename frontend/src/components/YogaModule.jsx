import React, { useState, useEffect } from 'react';
import {
  Activity, Clock, ShieldCheck, Play, Award, Sparkles,
  Search, X, CheckCircle, Info, Heart, Pause, RotateCcw, Wind
} from 'lucide-react';

export default function YogaModule({ yogaPoses, onStartCamera }) {
  const [selectedCategory, setSelectedCategory] = useState('All');
  const [searchQuery, setSearchQuery] = useState('');

  // 4-4-4 Pranayama Guided Breathing Pacer
  const [isBreathingActive, setIsBreathingActive] = useState(false);
  const [breathPhase, setBreathPhase] = useState('Inhale'); // Inhale, Hold, Exhale
  const [breathSecondsLeft, setBreathSecondsLeft] = useState(4);
  const [breathCycles, setBreathCycles] = useState(0);

  const categories = ['All', 'Balance & Focus', 'Strength & Stamina', 'Flexibility & Energy', 'Back Relief'];

  useEffect(() => {
    let interval = null;
    if (isBreathingActive) {
      interval = setInterval(() => {
        setBreathSecondsLeft((prev) => {
          if (prev <= 1) {
            setBreathPhase((currentPhase) => {
              if (currentPhase === 'Inhale') return 'Hold';
              if (currentPhase === 'Hold') return 'Exhale';
              setBreathCycles((c) => c + 1);
              return 'Inhale';
            });
            return 4;
          }
          return prev - 1;
        });
      }, 1000);
    }
    return () => {
      if (interval) clearInterval(interval);
    };
  }, [isBreathingActive]);

  const filtered = yogaPoses.filter((pose) => {
    const matchesCat = selectedCategory === 'All' || pose.category.toLowerCase().includes(selectedCategory.toLowerCase());
    const matchesSearch = !searchQuery ||
      pose.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
      (pose.sanskrit_name && pose.sanskrit_name.toLowerCase().includes(searchQuery.toLowerCase())) ||
      pose.description.toLowerCase().includes(searchQuery.toLowerCase());
    return matchesCat && matchesSearch;
  });

  return (
    <div className="space-y-6 pb-24 font-['Inter']">
      {/* Hero Header */}
      <div className="relative overflow-hidden p-6 sm:p-8 rounded-3xl bg-gradient-to-r from-teal-900 via-emerald-900 to-[#0B0F19] border border-emerald-500/40 text-white space-y-3 shadow-2xl shadow-emerald-950/50">
        <div className="relative z-10 space-y-3">
          <div className="inline-flex items-center space-x-2 px-3 py-1 rounded-full bg-emerald-500/20 text-emerald-300 text-xs font-semibold border border-emerald-500/30">
            <Sparkles className="w-3.5 h-3.5" />
            <span>AI Yoga Posture & Balance Studio</span>
          </div>
          <h2 className="text-2xl sm:text-3xl font-black">🧘 Mindful Yoga & Stability Studio</h2>
          <p className="text-xs sm:text-sm text-emerald-100/90 leading-relaxed max-w-xl">
            Align your mind, body, and breath. GYM STAR monitors joint alignment, hold duration timer, and balance stability in real-time.
          </p>
        </div>

        {/* Ambient Blur */}
        <div className="absolute -right-10 -bottom-10 w-48 h-48 bg-emerald-400/20 rounded-full blur-3xl pointer-events-none" />
      </div>

      {/* 4-4-4 Pranayama Guided Breathing Pacer Card */}
      <div className="p-6 rounded-3xl bg-[#121A2D] border border-emerald-500/30 shadow-xl">
        <div className="flex flex-col md:flex-row items-center justify-between gap-6">
          <div className="flex items-center space-x-5">
            {/* Animated Breathing Circle */}
            <div className="relative w-28 h-28 flex items-center justify-center">
              <div
                className={`absolute inset-0 rounded-full transition-all duration-1000 ${
                  isBreathingActive
                    ? breathPhase === 'Inhale'
                      ? 'scale-100 bg-emerald-500/30 border-2 border-emerald-400'
                      : breathPhase === 'Hold'
                      ? 'scale-90 bg-indigo-500/30 border-2 border-indigo-400'
                      : 'scale-75 bg-purple-500/20 border-2 border-purple-400'
                    : 'scale-75 bg-slate-800 border-2 border-slate-700'
                }`}
              />
              <div className="relative text-center z-10">
                <span className="text-xl font-black font-mono text-white block">
                  {isBreathingActive ? `${breathSecondsLeft}s` : '4-4-4'}
                </span>
                <span className="text-[10px] uppercase font-bold text-emerald-400 tracking-wider">
                  {isBreathingActive ? breathPhase : 'Pranayama'}
                </span>
              </div>
            </div>

            <div className="space-y-1">
              <div className="flex items-center space-x-2">
                <Wind className="w-4 h-4 text-emerald-400" />
                <h3 className="text-base font-bold text-white">4-4-4 Guided Breathing</h3>
              </div>
              <p className="text-xs text-slate-300 max-w-sm">
                Inhale for 4s, Hold for 4s, Exhale for 4s. Regulates heart rate and calms nervous system before holding poses.
              </p>
              {isBreathingActive && (
                <div className="text-[11px] text-emerald-400 font-semibold pt-1">
                  Completed Cycles: {breathCycles}
                </div>
              )}
            </div>
          </div>

          <div className="flex items-center space-x-3">
            <button
              onClick={() => setIsBreathingActive(!isBreathingActive)}
              className={`px-5 py-2.5 rounded-xl text-xs font-bold transition-all flex items-center space-x-2 shadow-lg ${
                isBreathingActive
                  ? 'bg-amber-600 hover:bg-amber-500 text-white shadow-amber-600/30'
                  : 'bg-emerald-600 hover:bg-emerald-500 text-white shadow-emerald-600/30'
              }`}
            >
              {isBreathingActive ? <Pause className="w-4 h-4" /> : <Play className="w-4 h-4" />}
              <span>{isBreathingActive ? 'Pause Pacer' : 'Start Guided Breath'}</span>
            </button>
            {isBreathingActive && (
              <button
                onClick={() => {
                  setIsBreathingActive(false);
                  setBreathPhase('Inhale');
                  setBreathSecondsLeft(4);
                  setBreathCycles(0);
                }}
                className="p-2.5 rounded-xl bg-slate-800 hover:bg-slate-700 text-slate-300 border border-slate-700 transition-all"
              >
                <RotateCcw className="w-4 h-4" />
              </button>
            )}
          </div>
        </div>
      </div>

      {/* Filter and Search Bar */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3">
        {/* Category Pills */}
        <div className="flex items-center space-x-2 overflow-x-auto pb-1 scrollbar-none flex-1">
          {categories.map((cat) => (
            <button
              key={cat}
              onClick={() => setSelectedCategory(cat)}
              className={`px-4 py-2 rounded-xl text-xs font-bold transition-all whitespace-nowrap ${
                selectedCategory === cat
                  ? 'bg-emerald-600 text-white shadow-lg shadow-emerald-600/30'
                  : 'bg-[#121A2D] text-slate-400 hover:bg-slate-700 hover:text-slate-200 border border-[#263554]'
              }`}
            >
              {cat}
            </button>
          ))}
        </div>

        {/* Search */}
        <div className="relative max-w-xs w-full">
          <Search className="w-4 h-4 text-slate-400 absolute left-3.5 top-1/2 -translate-y-1/2" />
          <input
            type="text"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            placeholder="Search yoga poses..."
            className="w-full bg-[#121A2D] border border-[#263554] rounded-xl pl-9 pr-3.5 py-2 text-xs text-slate-100 placeholder-slate-500 focus:outline-none focus:border-emerald-500 transition-all"
          />
          {searchQuery && (
            <button
              onClick={() => setSearchQuery('')}
              className="absolute right-3 top-1/2 -translate-y-1/2 text-slate-400 hover:text-white"
            >
              <X className="w-3.5 h-3.5" />
            </button>
          )}
        </div>
      </div>

      {/* Yoga Pose Grid */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
        {filtered.map((pose) => (
          <div
            key={pose.key}
            className="p-5 rounded-2xl bg-[#121A2D] hover:bg-slate-800 border border-[#263554] hover:border-emerald-500/50 transition-all flex flex-col justify-between space-y-4 group shadow-sm hover:shadow-emerald-500/10"
          >
            <div className="space-y-3">
              <div className="flex items-start justify-between">
                <div className="space-y-1">
                  <span className="text-[10px] font-black uppercase tracking-wider px-2.5 py-0.5 rounded-full bg-emerald-500/15 text-emerald-400 border border-emerald-500/30">
                    {pose.category}
                  </span>
                  <h3 className="text-base font-bold text-slate-100 group-hover:text-emerald-400 transition-colors">
                    {pose.name}
                  </h3>
                  {pose.sanskrit_name && (
                    <p className="text-xs italic text-emerald-400/80">{pose.sanskrit_name}</p>
                  )}
                </div>
                <div className="w-9 h-9 rounded-xl bg-emerald-500/10 flex items-center justify-center text-emerald-400 shrink-0">
                  <Activity className="w-4 h-4" />
                </div>
              </div>

              <p className="text-xs text-slate-400 line-clamp-2 leading-relaxed">
                {pose.description}
              </p>
            </div>

            <div className="pt-3 flex items-center justify-between border-t border-[#263554]">
              <div className="flex items-center space-x-1 text-xs font-mono text-emerald-400 font-bold">
                <Clock className="w-3.5 h-3.5" />
                <span>{pose.hold_duration_sec || 30}s Hold Goal</span>
              </div>

              <button
                onClick={() => onStartCamera(pose.key, true)}
                className="inline-flex items-center space-x-1.5 px-4 py-2 rounded-xl bg-emerald-600 hover:bg-emerald-500 text-white font-bold text-xs shadow-md shadow-emerald-600/25 transition-all active:scale-95"
              >
                <Play className="w-3.5 h-3.5 fill-white" />
                <span>Start Session</span>
              </button>
            </div>
          </div>
        ))}
      </div>

      {filtered.length === 0 && (
        <div className="py-16 text-center text-slate-400 space-y-2">
          <p className="text-sm font-semibold">No yoga poses match your search.</p>
          <p className="text-xs text-slate-500">Try adjusting your search query or category filter.</p>
        </div>
      )}
    </div>
  );
}
