import React, { useState } from 'react';
import {
  Camera, Activity, AlertTriangle, CheckCircle, Info, Dumbbell,
  Play, Search, X, Sparkles, Target, ShieldCheck, Star, Repeat, Flame
} from 'lucide-react';
import { getExerciseImage } from '../constants/exerciseImages';

export default function ExerciseLibrary({ exercises, onStartCamera }) {
  const [selectedCategory, setSelectedCategory] = useState('All');
  const [selectedDifficulty, setSelectedDifficulty] = useState('All');
  const [selectedEquipment, setSelectedEquipment] = useState('All');
  const [activeTab, setActiveTab] = useState('All'); // 'All', 'AI Monitored', 'Favorites'
  const [searchQuery, setSearchQuery] = useState('');
  const [activeModalExercise, setActiveModalExercise] = useState(null);
  const [favorites, setFavorites] = useState(new Set(['preacher_curl', 'squat', 'pushup', 'standing_dumbbell_curl']));

  const categories = [
    'All',
    'Chest',
    'Back',
    'Shoulders',
    'Biceps',
    'Triceps',
    'Forearms',
    'Legs',
    'Abs and Core',
    'Glutes',
    'Full Body',
    'Cardio',
  ];

  const equipments = ['All', 'Barbell', 'Dumbbell', 'Bodyweight', 'Cable', 'Machine'];
  const difficulties = ['All', 'Beginner', 'Intermediate', 'Advanced'];

  const toggleFavorite = (key) => {
    setFavorites((prev) => {
      const next = new Set(prev);
      if (next.has(key)) next.delete(key);
      else next.add(key);
      return next;
    });
  };

  const filtered = exercises.filter((e) => {
    // 1. Tab filter
    if (activeTab === 'Favorites' && !favorites.has(e.key)) return false;
    if (activeTab === 'AI Monitored' && !e.is_ai_supported) return false;

    // 2. Category
    const matchesCat =
      selectedCategory === 'All' ||
      e.category.toLowerCase().includes(selectedCategory.toLowerCase());

    // 3. Difficulty
    const matchesDiff =
      selectedDifficulty === 'All' ||
      (e.difficulty && e.difficulty.toLowerCase() === selectedDifficulty.toLowerCase());

    // 4. Equipment
    const matchesEquip =
      selectedEquipment === 'All' ||
      (e.equipment && e.equipment.toLowerCase().includes(selectedEquipment.toLowerCase()));

    // 5. Search
    const q = searchQuery.toLowerCase().trim();
    const matchesSearch =
      !q ||
      e.name.toLowerCase().includes(q) ||
      (e.target_muscles && e.target_muscles.toLowerCase().includes(q)) ||
      (e.primary_muscles && e.primary_muscles.toLowerCase().includes(q)) ||
      (e.description && e.description.toLowerCase().includes(q));

    return matchesCat && matchesDiff && matchesEquip && matchesSearch;
  });

  const getCategoryCount = (cat) => {
    if (cat === 'All') return exercises.length;
    return exercises.filter((e) => e.category.toLowerCase() === cat.toLowerCase()).length;
  };

  return (
    <div className="space-y-6 pb-24 font-['Inter']">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3">
        <div>
          <h2 className="text-xl sm:text-2xl font-black text-slate-100 flex items-center gap-2">
            <span className="p-1.5 rounded-xl bg-gradient-to-br from-indigo-500 to-purple-600 text-white inline-block">
              <Dumbbell className="w-5 h-5" />
            </span>
            Exercise Library
          </h2>
          <p className="text-xs text-slate-400">
            Explore 80 computer-vision evaluated movements with dedicated demonstration images & biomechanics
          </p>
        </div>

        {/* Search Bar */}
        <div className="relative max-w-xs w-full">
          <Search className="w-4 h-4 text-slate-400 absolute left-3.5 top-1/2 -translate-y-1/2" />
          <input
            type="text"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            placeholder="Search Preacher Curl, Squat, Lats..."
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

      {/* High-Level Filter Tabs */}
      <div className="flex items-center space-x-2">
        <button
          onClick={() => setActiveTab('All')}
          className={`px-3.5 py-1.5 rounded-xl text-xs font-bold transition-all flex items-center space-x-1.5 ${
            activeTab === 'All'
              ? 'bg-indigo-600 text-white shadow-md shadow-indigo-600/30'
              : 'bg-slate-800/80 text-slate-400 hover:bg-slate-700 hover:text-white border border-slate-700/50'
          }`}
        >
          <span>All Movements ({exercises.length})</span>
        </button>

        <button
          onClick={() => setActiveTab('AI Monitored')}
          className={`px-3.5 py-1.5 rounded-xl text-xs font-bold transition-all flex items-center space-x-1.5 ${
            activeTab === 'AI Monitored'
              ? 'bg-emerald-600 text-white shadow-md shadow-emerald-600/30'
              : 'bg-slate-800/80 text-slate-400 hover:bg-slate-700 hover:text-white border border-slate-700/50'
          }`}
        >
          <Camera className="w-3.5 h-3.5 text-emerald-400" />
          <span>AI Vision Monitored</span>
        </button>

        <button
          onClick={() => setActiveTab('Favorites')}
          className={`px-3.5 py-1.5 rounded-xl text-xs font-bold transition-all flex items-center space-x-1.5 ${
            activeTab === 'Favorites'
              ? 'bg-amber-600 text-white shadow-md shadow-amber-600/30'
              : 'bg-slate-800/80 text-slate-400 hover:bg-slate-700 hover:text-white border border-slate-700/50'
          }`}
        >
          <Star className="w-3.5 h-3.5 text-amber-400 fill-amber-400" />
          <span>Favorites ({favorites.size})</span>
        </button>
      </div>

      {/* Category Pills with Count Badges */}
      <div className="flex items-center space-x-2 overflow-x-auto pb-1 scrollbar-none">
        {categories.map((cat) => {
          const count = getCategoryCount(cat);
          const isSelected = selectedCategory === cat;
          return (
            <button
              key={cat}
              onClick={() => setSelectedCategory(cat)}
              className={`px-3.5 py-1.5 rounded-xl text-xs font-bold transition-all whitespace-nowrap flex items-center space-x-1.5 ${
                isSelected
                  ? 'bg-indigo-600 text-white shadow-lg shadow-indigo-600/30'
                  : 'bg-slate-800/90 text-slate-400 hover:bg-slate-700 hover:text-slate-200 border border-slate-700/50'
              }`}
            >
              <span>{cat}</span>
              <span className={`text-[10px] px-1.5 py-0.2 rounded-full ${isSelected ? 'bg-black/30 text-white' : 'bg-slate-700 text-slate-400'}`}>
                {count}
              </span>
            </button>
          );
        })}
      </div>

      {/* Equipment & Difficulty Filter Pills */}
      <div className="flex flex-wrap items-center gap-3 text-xs">
        <div className="flex items-center space-x-1.5 overflow-x-auto">
          <span className="text-slate-500 font-bold uppercase text-[10px] tracking-wider">Apparatus:</span>
          {equipments.map((eq) => (
            <button
              key={eq}
              onClick={() => setSelectedEquipment(eq)}
              className={`px-2.5 py-0.5 rounded-lg font-medium transition-all ${
                selectedEquipment === eq
                  ? 'bg-indigo-600/30 text-indigo-300 border border-indigo-500/50 font-bold'
                  : 'text-slate-400 hover:text-slate-200 border border-transparent'
              }`}
            >
              {eq}
            </button>
          ))}
        </div>

        <div className="flex items-center space-x-1.5 overflow-x-auto">
          <span className="text-slate-500 font-bold uppercase text-[10px] tracking-wider">Level:</span>
          {difficulties.map((diff) => (
            <button
              key={diff}
              onClick={() => setSelectedDifficulty(diff)}
              className={`px-2.5 py-0.5 rounded-lg font-medium transition-all ${
                selectedDifficulty === diff
                  ? 'bg-purple-600/30 text-purple-300 border border-purple-500/50 font-bold'
                  : 'text-slate-400 hover:text-slate-200 border border-transparent'
              }`}
            >
              {diff}
            </button>
          ))}
        </div>
      </div>

      {/* Exercise Cards Grid */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-5">
        {filtered.map((ex) => {
          const imgUrl = ex.image_url || getExerciseImage(ex.key);
          const isFav = favorites.has(ex.key);

          return (
            <div
              key={ex.key}
              className="rounded-2xl bg-slate-900 border border-slate-800 hover:border-indigo-500/50 transition-all flex flex-col justify-between overflow-hidden shadow-lg group hover:shadow-indigo-500/10"
            >
              {/* Top Demonstration Image Banner */}
              <div className="relative h-44 w-full bg-slate-950 overflow-hidden">
                <img
                  src={imgUrl}
                  alt={ex.name}
                  loading="lazy"
                  className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500"
                />
                <div className="absolute inset-0 bg-gradient-to-t from-slate-900 via-transparent to-black/40" />

                {/* Apparatus Badge */}
                <div className="absolute top-3 left-3 px-2 py-0.5 rounded-lg bg-black/70 backdrop-blur-md text-[10px] font-bold text-slate-200 border border-white/10 uppercase tracking-wider">
                  {ex.equipment || 'Bodyweight'}
                </div>

                {/* AI / Guided Badge */}
                <div className="absolute top-3 right-3 flex items-center space-x-1.5">
                  <span
                    className={`px-2 py-0.5 rounded-lg text-[9px] font-black uppercase tracking-wider flex items-center space-x-1 ${
                      ex.is_ai_supported
                        ? 'bg-emerald-500/90 text-white shadow-sm'
                        : 'bg-black/60 text-slate-300 border border-white/10'
                    }`}
                  >
                    <span className={`w-1.5 h-1.5 rounded-full ${ex.is_ai_supported ? 'bg-white animate-pulse' : 'bg-slate-400'}`} />
                    <span>{ex.is_ai_supported ? 'AI Monitored' : 'Guided'}</span>
                  </span>

                  {/* Favorite button */}
                  <button
                    onClick={(e) => {
                      e.stopPropagation();
                      toggleFavorite(ex.key);
                    }}
                    className="p-1 rounded-lg bg-black/60 text-slate-300 hover:text-amber-400 transition-colors"
                  >
                    <Star className={`w-3.5 h-3.5 ${isFav ? 'text-amber-400 fill-amber-400' : ''}`} />
                  </button>
                </div>

                {/* Primary Muscle Pin */}
                <div className="absolute bottom-2.5 left-3">
                  <span className="text-[10px] font-bold text-emerald-400 bg-emerald-950/70 border border-emerald-500/30 px-2 py-0.5 rounded-md">
                    {ex.primary_muscles || ex.target_muscles?.split(',')[0] || ex.category}
                  </span>
                </div>
              </div>

              {/* Card Body */}
              <div className="p-4 space-y-3 flex-1 flex flex-col justify-between">
                <div className="space-y-1.5">
                  <div className="flex items-start justify-between gap-2">
                    <h3 className="text-base font-black text-slate-100 group-hover:text-indigo-400 transition-colors">
                      {ex.name}
                    </h3>
                    <span className="text-[10px] font-bold px-2 py-0.5 rounded-md bg-slate-800 text-slate-400 border border-slate-700/60 uppercase shrink-0">
                      {ex.difficulty || 'Beginner'}
                    </span>
                  </div>

                  <p className="text-xs text-slate-400 line-clamp-2 leading-relaxed">
                    {ex.description}
                  </p>

                  <div className="flex items-center space-x-2 text-[11px] text-slate-400 font-medium pt-1">
                    <span className="text-indigo-400 font-bold">{ex.recommended_sets || '3 Sets'}</span>
                    <span>•</span>
                    <span className="text-slate-300 font-bold">{ex.recommended_reps || '10-12 Reps'}</span>
                    <span>•</span>
                    <span className="text-slate-400">{ex.estimated_duration || '8-10 min'}</span>
                  </div>
                </div>

                <div className="pt-3 flex items-center justify-between border-t border-slate-800 gap-2">
                  <button
                    onClick={() => setActiveModalExercise(ex)}
                    className="px-3 py-1.5 rounded-xl border border-slate-700 hover:border-indigo-500/50 text-xs text-slate-300 hover:text-white font-bold transition-all flex items-center space-x-1"
                  >
                    <Info className="w-3.5 h-3.5 text-indigo-400" />
                    <span>Details</span>
                  </button>

                  <button
                    onClick={() => onStartCamera(ex.key)}
                    className="flex-1 inline-flex items-center justify-center space-x-1.5 px-4 py-2 rounded-xl bg-gradient-to-r from-emerald-500 to-teal-600 hover:from-emerald-400 hover:to-teal-500 text-white font-black text-xs shadow-md shadow-emerald-500/20 transition-all active:scale-95"
                  >
                    <Camera className="w-3.5 h-3.5" />
                    <span>{ex.is_ai_supported ? 'Start AI Coach' : 'Start Workout'}</span>
                  </button>
                </div>
              </div>
            </div>
          );
        })}
      </div>

      {filtered.length === 0 && (
        <div className="py-16 text-center text-slate-400 space-y-3 bg-slate-900/60 rounded-3xl border border-slate-800 p-8">
          <Dumbbell className="w-12 h-12 mx-auto text-slate-600" />
          <h4 className="text-base font-bold text-slate-200">No exercises match your filter criteria</h4>
          <p className="text-xs text-slate-500 max-w-sm mx-auto">
            Try resetting your search query or selecting "All" to browse all 80 exercises across 9 muscle groups.
          </p>
          <button
            onClick={() => {
              setSearchQuery('');
              setSelectedCategory('All');
              setSelectedDifficulty('All');
              setSelectedEquipment('All');
              setActiveTab('All');
            }}
            className="px-4 py-2 rounded-xl bg-indigo-600 text-white text-xs font-bold shadow-md shadow-indigo-600/30"
          >
            Reset All Filters
          </button>
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

            {/* Modal Image Hero */}
            <div className="relative h-48 w-full rounded-2xl overflow-hidden border border-slate-800">
              <img
                src={activeModalExercise.image_url || getExerciseImage(activeModalExercise.key)}
                alt={activeModalExercise.name}
                className="w-full h-full object-cover"
              />
              <div className="absolute inset-0 bg-gradient-to-t from-slate-900 via-transparent to-transparent" />
              <div className="absolute bottom-3 left-3">
                <span className="text-[10px] font-black uppercase tracking-wider px-2.5 py-0.5 rounded-full bg-indigo-500/20 text-indigo-400 border border-indigo-500/30">
                  {activeModalExercise.category} • {activeModalExercise.equipment}
                </span>
              </div>
            </div>

            <div className="space-y-1">
              <h2 className="text-xl font-black text-white">{activeModalExercise.name}</h2>
              <p className="text-xs text-slate-300 leading-relaxed">{activeModalExercise.description}</p>
            </div>

            {/* Muscles Activated Section */}
            <div className="p-4 rounded-2xl bg-slate-800/80 border border-slate-700/80 space-y-2">
              <h4 className="text-xs font-bold text-indigo-300 uppercase tracking-wider flex items-center">
                <Target className="w-4 h-4 mr-1.5 text-indigo-400" />
                Muscles Activated
              </h4>
              <div className="space-y-1 text-xs">
                <div className="flex items-center gap-2">
                  <span className="text-[10px] font-black text-emerald-400 bg-emerald-950/80 border border-emerald-500/40 px-2 py-0.5 rounded">
                    PRIMARY
                  </span>
                  <span className="text-slate-100 font-bold">
                    {activeModalExercise.primary_muscles || activeModalExercise.target_muscles}
                  </span>
                </div>
                {activeModalExercise.secondary_muscles && (
                  <div className="flex items-center gap-2 pt-1">
                    <span className="text-[10px] font-black text-sky-400 bg-sky-950/80 border border-sky-500/40 px-2 py-0.5 rounded">
                      SECONDARY
                    </span>
                    <span className="text-slate-300 font-medium">
                      {activeModalExercise.secondary_muscles}
                    </span>
                  </div>
                )}
              </div>
            </div>

            {/* Step-by-Step Instructions */}
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

            {/* Common Mistakes */}
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
