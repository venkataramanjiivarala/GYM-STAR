import React, { useState } from 'react';
import {
  Camera, Activity, AlertTriangle, CheckCircle, Info, Dumbbell,
  Play, Search, X, Sparkles, Target, ShieldCheck
} from 'lucide-react';

export default function ExerciseLibrary({ exercises, onStartCamera }) {
  const [selectedCategory, setSelectedCategory] = useState('All');
  const [searchQuery, setSearchQuery] = useState('');
  const [activeModalExercise, setActiveModalExercise] = useState(null);

  const categories = ['All', 'Legs', 'Chest', 'Arms', 'Core', 'Shoulders'];

  const filtered = exercises.filter((e) => {
    const matchesCat = selectedCategory === 'All' || e.category.toLowerCase().includes(selectedCategory.toLowerCase());
    const matchesSearch = !searchQuery ||
      e.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
      e.target_muscles.toLowerCase().includes(searchQuery.toLowerCase()) ||
      e.description.toLowerCase().includes(searchQuery.toLowerCase());
    return matchesCat && matchesSearch;
  });

  return (
    <div className="space-y-6 pb-24 font-['Inter']">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3">
        <div>
          <h2 className="text-xl sm:text-2xl font-black text-slate-100">Exercise Library</h2>
          <p className="text-xs text-slate-400">Explore computer-vision evaluated movements & posture guidelines</p>
        </div>

        {/* Search Bar */}
        <div className="relative max-w-xs w-full">
          <Search className="w-4 h-4 text-slate-400 absolute left-3.5 top-1/2 -translate-y-1/2" />
          <input
            type="text"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            placeholder="Search exercises or muscles..."
            className="w-full bg-slate-800/80 border border-slate-700/80 rounded-xl pl-9 pr-3.5 py-2 text-xs text-slate-100 placeholder-slate-500 focus:outline-none focus:border-indigo-500 transition-all"
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

      {/* Category Pills */}
      <div className="flex items-center space-x-2 overflow-x-auto pb-1 scrollbar-none">
        {categories.map((cat) => (
          <button
            key={cat}
            onClick={() => setSelectedCategory(cat)}
            className={`px-4 py-2 rounded-xl text-xs font-bold transition-all whitespace-nowrap ${
              selectedCategory === cat
                ? 'bg-indigo-600 text-white shadow-lg shadow-indigo-600/30'
                : 'bg-slate-800/90 text-slate-400 hover:bg-slate-700 hover:text-slate-200 border border-slate-700/50'
            }`}
          >
            {cat}
          </button>
        ))}
      </div>

      {/* Exercise Cards Grid */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
        {filtered.map((ex) => (
          <div
            key={ex.key}
            className="p-5 rounded-2xl bg-slate-800/85 hover:bg-slate-800 border border-slate-700/70 hover:border-indigo-500/50 transition-all flex flex-col justify-between space-y-4 glass-card group shadow-sm hover:shadow-indigo-500/10"
          >
            <div className="space-y-3">
              <div className="flex items-start justify-between">
                <div className="space-y-1">
                  <span className="text-[10px] font-black uppercase tracking-wider px-2.5 py-0.5 rounded-full bg-indigo-500/10 text-indigo-400 border border-indigo-500/20">
                    {ex.category}
                  </span>
                  <h3 className="text-base font-bold text-slate-100 group-hover:text-indigo-400 transition-colors">
                    {ex.name}
                  </h3>
                </div>
                <div className="w-9 h-9 rounded-xl bg-slate-700/50 flex items-center justify-center text-indigo-400 shrink-0">
                  <Dumbbell className="w-4 h-4" />
                </div>
              </div>

              <p className="text-xs text-slate-400 line-clamp-2 leading-relaxed">
                {ex.description}
              </p>

              <div className="flex items-center space-x-1.5 text-[11px] text-slate-300 font-medium">
                <Target className="w-3.5 h-3.5 text-indigo-400 shrink-0" />
                <span className="truncate">{ex.target_muscles}</span>
              </div>
            </div>

            <div className="pt-3 flex items-center justify-between border-t border-slate-700/50">
              <button
                onClick={() => setActiveModalExercise(ex)}
                className="text-xs text-indigo-400 hover:text-indigo-300 font-semibold flex items-center space-x-1"
              >
                <Info className="w-3.5 h-3.5" />
                <span>Guide</span>
              </button>

              <button
                onClick={() => onStartCamera(ex.key)}
                className="inline-flex items-center space-x-1.5 px-4 py-2 rounded-xl bg-gradient-to-r from-emerald-500 to-teal-600 hover:from-emerald-400 hover:to-teal-500 text-white font-bold text-xs shadow-md shadow-emerald-500/20 transition-all active:scale-95"
              >
                <Camera className="w-3.5 h-3.5" />
                <span>Start Coach</span>
              </button>
            </div>
          </div>
        ))}
      </div>

      {filtered.length === 0 && (
        <div className="py-16 text-center text-slate-400 space-y-2">
          <Dumbbell className="w-10 h-10 mx-auto text-slate-600" />
          <p className="text-sm font-semibold">No exercises match your search.</p>
          <p className="text-xs text-slate-500">Try changing your search query or category filter.</p>
        </div>
      )}

      {/* Exercise Detail Guide Modal */}
      {activeModalExercise && (
        <div className="fixed inset-0 z-50 bg-black/85 backdrop-blur-md flex items-center justify-center p-4">
          <div className="max-w-lg w-full max-h-[90vh] overflow-y-auto bg-slate-900 border border-indigo-500/40 rounded-3xl p-6 relative space-y-5 shadow-2xl">
            <button
              onClick={() => setActiveModalExercise(null)}
              className="absolute top-5 right-5 text-slate-400 hover:text-white p-1 rounded-xl bg-slate-800"
            >
              <X className="w-5 h-5" />
            </button>

            <div className="space-y-1">
              <span className="text-[10px] font-black uppercase tracking-wider px-2.5 py-0.5 rounded-full bg-indigo-500/15 text-indigo-400 border border-indigo-500/30">
                {activeModalExercise.category} • {activeModalExercise.difficulty}
              </span>
              <h2 className="text-xl font-black text-white">{activeModalExercise.name}</h2>
              <p className="text-xs text-slate-300">{activeModalExercise.description}</p>
            </div>

            <div className="p-3.5 rounded-2xl bg-slate-800/80 border border-slate-700/80 space-y-1.5">
              <h4 className="text-xs font-bold text-indigo-300 uppercase tracking-wider flex items-center">
                <Target className="w-4 h-4 mr-1.5 text-indigo-400" />
                Target Muscles
              </h4>
              <p className="text-xs text-slate-200">{activeModalExercise.target_muscles}</p>
            </div>

            {activeModalExercise.instructions && activeModalExercise.instructions.length > 0 && (
              <div className="space-y-2">
                <h4 className="text-xs font-bold text-emerald-400 uppercase tracking-wider flex items-center">
                  <CheckCircle className="w-4 h-4 mr-1.5 text-emerald-400" />
                  Step-by-Step Instructions
                </h4>
                <ul className="space-y-1.5 text-xs text-slate-300">
                  {activeModalExercise.instructions.map((inst, i) => (
                    <li key={i} className="flex items-start space-x-2">
                      <span className="w-4 h-4 rounded-full bg-emerald-500/20 text-emerald-400 text-[10px] font-bold flex items-center justify-center shrink-0 mt-0.5">
                        {i + 1}
                      </span>
                      <span>{inst}</span>
                    </li>
                  ))}
                </ul>
              </div>
            )}

            {activeModalExercise.common_mistakes && activeModalExercise.common_mistakes.length > 0 && (
              <div className="p-4 rounded-2xl bg-rose-950/30 border border-rose-500/30 space-y-2">
                <h4 className="text-xs font-bold text-rose-300 uppercase tracking-wider flex items-center">
                  <AlertTriangle className="w-4 h-4 mr-1.5 text-rose-400" />
                  Common Mistakes to Avoid
                </h4>
                <ul className="space-y-1 text-xs text-rose-200/90">
                  {activeModalExercise.common_mistakes.map((mis, i) => (
                    <li key={i} className="flex items-center space-x-1.5">
                      <span>•</span>
                      <span>{mis}</span>
                    </li>
                  ))}
                </ul>
              </div>
            )}

            <button
              onClick={() => {
                const k = activeModalExercise.key;
                setActiveModalExercise(null);
                onStartCamera(k);
              }}
              className="w-full py-3.5 rounded-2xl bg-gradient-to-r from-emerald-500 to-teal-600 hover:from-emerald-400 hover:to-teal-500 text-white font-black text-sm shadow-xl shadow-emerald-500/25 transition-all flex items-center justify-center space-x-2"
            >
              <Camera className="w-4 h-4" />
              <span>Launch AI Camera Coach</span>
            </button>
          </div>
        </div>
      )}
    </div>
  );
}
