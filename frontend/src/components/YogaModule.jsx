import React, { useState } from 'react';
import {
  Activity, Clock, ShieldCheck, Play, Award, Sparkles,
  Search, X, CheckCircle, Info, Heart
} from 'lucide-react';

export default function YogaModule({ yogaPoses, onStartCamera }) {
  const [selectedCategory, setSelectedCategory] = useState('All');
  const [searchQuery, setSearchQuery] = useState('');
  const [activeModalPose, setActiveModalPose] = useState(null);

  const categories = ['All', 'Balance & Focus', 'Strength & Stamina', 'Flexibility & Energy', 'Back Relief'];

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
      <div className="relative overflow-hidden p-6 sm:p-8 rounded-3xl bg-gradient-to-r from-teal-800 via-emerald-800 to-slate-900 border border-emerald-500/40 text-white space-y-3 shadow-2xl shadow-emerald-950/50">
        <div className="relative z-10 space-y-3">
          <div className="inline-flex items-center space-x-2 px-3 py-1 rounded-full bg-emerald-500/20 text-emerald-300 text-xs font-semibold border border-emerald-500/30">
            <Sparkles className="w-3.5 h-3.5" />
            <span>AI Yoga Posture & Balance Studio</span>
          </div>
          <h2 className="text-2xl sm:text-3xl font-black">🧘 Mindful Yoga & Mobility Studio</h2>
          <p className="text-xs sm:text-sm text-emerald-100/90 leading-relaxed max-w-xl">
            Align your mind, body, and breath. GYM STAR monitors joint alignment, hold duration timer, and balance stability in real-time.
          </p>
        </div>

        {/* Ambient Blur */}
        <div className="absolute -right-10 -bottom-10 w-48 h-48 bg-emerald-400/20 rounded-full blur-3xl pointer-events-none" />
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
                  : 'bg-slate-800/90 text-slate-400 hover:bg-slate-700 hover:text-slate-200 border border-slate-700/60'
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
            className="w-full bg-slate-800/80 border border-slate-700/80 rounded-xl pl-9 pr-3.5 py-2 text-xs text-slate-100 placeholder-slate-500 focus:outline-none focus:border-emerald-500 transition-all"
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
            className="p-5 rounded-2xl bg-slate-800/85 hover:bg-slate-800 border border-slate-700/70 hover:border-emerald-500/50 transition-all flex flex-col justify-between space-y-4 glass-card group shadow-sm hover:shadow-emerald-500/10"
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

            <div className="pt-3 flex items-center justify-between border-t border-slate-700/50">
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
