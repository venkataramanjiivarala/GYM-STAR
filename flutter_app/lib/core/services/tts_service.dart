import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/foundation.dart';

class TtsService {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;
  TtsService._internal();

  FlutterTts? _flutterTts;
  bool _isInitialized = false;
  bool _isMuted = false;
  DateTime _lastSpokenTime = DateTime.now().subtract(const Duration(seconds: 10));
  String _lastSpokenText = '';

  bool get isMuted => _isMuted;
  void toggleMute() {
    _isMuted = !_isMuted;
  }

  Future<void> init() async {
    if (_isInitialized) return;
    try {
      _flutterTts = FlutterTts();
      await _flutterTts?.setLanguage("en-US");
      await _flutterTts?.setSpeechRate(0.5);
      await _flutterTts?.setVolume(1.0);
      await _flutterTts?.setPitch(1.0);
      _isInitialized = true;
    } catch (e) {
      debugPrint("TTS init error (non-fatal): $e");
    }
  }

  Future<void> speak(String text, {bool force = false}) async {
    if (_isMuted || text.trim().isEmpty) return;
    
    // Throttle speech so coach doesn't talk over itself (minimum 3 seconds between repeated prompts)
    final now = DateTime.now();
    if (!force && text == _lastSpokenText && now.difference(_lastSpokenTime).inSeconds < 3) {
      return;
    }

    _lastSpokenText = text;
    _lastSpokenTime = now;

    if (!_isInitialized) {
      await init();
    }

    try {
      await _flutterTts?.stop();
      await _flutterTts?.speak(text);
    } catch (e) {
      debugPrint("TTS speak error: $e");
    }
  }

  Future<void> stop() async {
    try {
      await _flutterTts?.stop();
    } catch (_) {}
  }
}
