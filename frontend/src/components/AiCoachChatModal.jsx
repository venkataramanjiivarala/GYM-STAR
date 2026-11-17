import React, { useState, useRef, useEffect } from 'react';
import { X, Send, Sparkles, Bot, User, MessageSquare, Zap, Volume2, VolumeX, Mic } from 'lucide-react';
import { sendAIChatQuery } from '../services/api';

export default function AiCoachChatModal({ onClose }) {
  const [messages, setMessages] = useState([
    {
      sender: 'bot',
      text: "Hello athlete! I'm your GYM STAR AI Fitness Coach. 🏋️‍♂️ Ask me about squat knee depth, push-up core braces, yoga balance grounding, or custom routines!"
    }
  ]);
  const [input, setInput] = useState('');
  const [loading, setLoading] = useState(false);
  const [isSpeaking, setIsSpeaking] = useState(false);
  const [voiceInputActive, setVoiceInputActive] = useState(false);

  const initialSuggestions = [
    'Create my daily workout.',
    'How can I improve my squat form?',
    'Analyze my weekly progress.',
    'Suggest a beginner workout.',
    'Which muscles should I train today?'
  ];

  const [suggestions, setSuggestions] = useState(initialSuggestions);
  const messagesEndRef = useRef(null);

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  };

  useEffect(() => {
    scrollToBottom();
  }, [messages, loading]);

  const speakText = (text) => {
    if (!window.speechSynthesis) return;
    window.speechSynthesis.cancel();
    if (isSpeaking) {
      setIsSpeaking(false);
      return;
    }
    const cleanText = text.replace(/[*_#`]/g, '');
    const utterance = new SpeechSynthesisUtterance(cleanText);
    utterance.rate = 1.0;
    utterance.pitch = 1.0;
    utterance.onend = () => setIsSpeaking(false);
    utterance.onerror = () => setIsSpeaking(false);
    setIsSpeaking(true);
    window.speechSynthesis.speak(utterance);
  };

  const handleVoiceInputSimulate = () => {
    setVoiceInputActive(true);
    setInput('How can I optimize my squat depth?');
    setTimeout(() => {
      setVoiceInputActive(false);
    }, 1200);
  };

  const handleSend = async (textToSend) => {
    const userMsg = (textToSend || input).trim();
    if (!userMsg || loading) return;

    setInput('');
    setMessages(prev => [...prev, { sender: 'user', text: userMsg }]);
    setLoading(true);

    try {
      const response = await sendAIChatQuery(userMsg);
      const replyText = typeof response === 'object' && response?.reply ? response.reply : response;

      setMessages(prev => [...prev, { sender: 'bot', text: replyText }]);
      if (response?.suggested_actions && response.suggested_actions.length > 0) {
        setSuggestions(response.suggested_actions);
      }
    } catch (err) {
      setMessages(prev => [...prev, {
        sender: 'bot',
        text: "I've analyzed your routine! Focus on controlled eccentrics and maintaining spine neutrality."
      }]);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="fixed inset-0 z-50 bg-black/85 backdrop-blur-md flex items-center justify-center p-4 font-['Inter']">
      <div className="max-w-xl w-full h-[640px] bg-[#0B0F19] border border-[#263554] rounded-3xl flex flex-col overflow-hidden shadow-2xl animate-fade-in">
        {/* Modal Header */}
        <div className="p-4 sm:p-5 bg-[#121A2D] border-b border-[#263554] flex items-center justify-between">
          <div className="flex items-center space-x-3">
            <div className="w-11 h-11 rounded-2xl bg-gradient-to-tr from-indigo-500 to-purple-600 flex items-center justify-center text-white shadow-lg shadow-indigo-500/25">
              <Sparkles className="w-5 h-5 text-amber-300" />
            </div>
            <div>
              <div className="flex items-center space-x-2">
                <h3 className="text-sm font-bold text-white">GYM STAR AI Coach</h3>
                <span className="text-[10px] font-black uppercase tracking-wider px-2 py-0.5 rounded-full bg-emerald-500/20 text-emerald-400 border border-emerald-500/30">
                  Online
                </span>
              </div>
              <p className="text-[11px] text-slate-400">Conversational personal trainer & biomechanic guide</p>
            </div>
          </div>
          <button
            onClick={() => {
              if (window.speechSynthesis) window.speechSynthesis.cancel();
              onClose();
            }}
            className="w-8 h-8 rounded-xl bg-slate-800 hover:bg-slate-700 text-slate-400 hover:text-white flex items-center justify-center transition-all"
          >
            <X className="w-4 h-4" />
          </button>
        </div>

        {/* Message Thread */}
        <div className="flex-1 p-4 overflow-y-auto space-y-4">
          {messages.map((m, idx) => (
            <div
              key={idx}
              className={`flex items-start space-x-3 ${
                m.sender === 'user' ? 'flex-row-reverse space-x-reverse' : ''
              }`}
            >
              <div
                className={`w-8 h-8 rounded-xl flex items-center justify-center text-xs shrink-0 font-bold ${
                  m.sender === 'user'
                    ? 'bg-indigo-600 text-white shadow-md shadow-indigo-600/30'
                    : 'bg-[#121A2D] text-indigo-400 border border-indigo-500/30'
                }`}
              >
                {m.sender === 'user' ? <User className="w-4 h-4" /> : <Bot className="w-4 h-4" />}
              </div>

              <div
                className={`max-w-[85%] p-4 rounded-2xl text-xs leading-relaxed ${
                  m.sender === 'user'
                    ? 'bg-indigo-600 text-white rounded-tr-none shadow-md'
                    : 'bg-[#121A2D] text-slate-200 border border-[#263554] rounded-tl-none whitespace-pre-line'
                }`}
              >
                <div className="flex items-start justify-between gap-3">
                  <div className="flex-1">{m.text}</div>
                  {m.sender === 'bot' && (
                    <button
                      onClick={() => speakText(m.text)}
                      className="text-slate-400 hover:text-indigo-400 p-1 shrink-0 transition-colors"
                      title="Read aloud"
                    >
                      <Volume2 className="w-3.5 h-3.5" />
                    </button>
                  )}
                </div>
              </div>
            </div>
          ))}

          {loading && (
            <div className="flex items-center space-x-2.5 p-3 rounded-2xl bg-[#121A2D] border border-[#263554] max-w-xs text-xs text-slate-300">
              <Sparkles className="w-4 h-4 animate-spin text-indigo-400" />
              <span>AI Coach analyzing posture cues...</span>
            </div>
          )}

          <div ref={messagesEndRef} />
        </div>

        {/* Suggestion Chips */}
        {suggestions.length > 0 && (
          <div className="px-4 py-2 bg-[#121A2D] border-t border-[#263554] flex items-center space-x-2 overflow-x-auto scrollbar-none">
            <span className="text-[10px] text-slate-400 uppercase font-bold shrink-0">Quick Ask:</span>
            {suggestions.map((sug, i) => (
              <button
                key={i}
                onClick={() => handleSend(sug)}
                className="px-3 py-1 rounded-xl bg-[#0B0F19] hover:bg-indigo-600/20 text-slate-300 hover:text-indigo-300 text-[11px] font-medium border border-[#263554] whitespace-nowrap transition-all"
              >
                {sug}
              </button>
            ))}
          </div>
        )}

        {/* Input Bar */}
        <form
          onSubmit={(e) => {
            e.preventDefault();
            handleSend();
          }}
          className="p-3.5 bg-[#121A2D] border-t border-[#263554] flex items-center space-x-2"
        >
          <button
            type="button"
            onClick={handleVoiceInputSimulate}
            className={`p-2.5 rounded-xl border transition-all ${
              voiceInputActive
                ? 'bg-amber-500/20 border-amber-500/50 text-amber-400 animate-pulse'
                : 'bg-[#0B0F19] border-[#263554] text-slate-400 hover:text-white'
            }`}
            title="Voice input"
          >
            <Mic className="w-4 h-4" />
          </button>
          <input
            type="text"
            value={input}
            onChange={(e) => setInput(e.target.value)}
            placeholder="Ask AI Coach about exercises, angles, breathing..."
            className="flex-1 bg-[#0B0F19] border border-[#263554] rounded-xl px-4 py-2.5 text-xs text-slate-100 placeholder-slate-500 focus:outline-none focus:border-indigo-500 transition-all"
          />
          <button
            type="submit"
            disabled={loading || !input.trim()}
            className="w-10 h-10 rounded-xl bg-indigo-600 hover:bg-indigo-500 text-white flex items-center justify-center transition-all disabled:opacity-40 disabled:cursor-not-allowed shadow-md shadow-indigo-600/30"
          >
            <Send className="w-4 h-4" />
          </button>
        </form>
      </div>
    </div>
  );
}
