import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/services/api_service.dart';
import '../core/services/tts_service.dart';
import '../models/chat_message_model.dart';
import '../models/user_profile_model.dart';

class AiCoachChatModal extends StatefulWidget {
  final String userName;
  final UserProfile? profile;
  const AiCoachChatModal({super.key, this.userName = 'Ramanji', this.profile});

  @override
  State<AiCoachChatModal> createState() => _AiCoachChatModalState();
}

class _AiCoachChatModalState extends State<AiCoachChatModal> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isListening = false;

  final List<String> _suggestedQuestions = [
    "Create my daily workout.",
    "How can I improve my squat form?",
    "Analyze my weekly progress.",
    "Suggest a beginner workout.",
    "Which muscles should I train today?",
  ];

  @override
  void initState() {
    super.initState();
    _messages.add(
      ChatMessage(
        text: "Hey ${widget.userName}! 👋 I'm your GYM STAR AI Personal Trainer.\n\n"
            "I'm tuned to your profile (${widget.profile?.fitnessLevel ?? 'Intermediate'} • ${widget.profile?.primaryGoal ?? 'Strength & Form'}).\n\n"
            "Ask me to analyze your posture angles, build custom circuits, or analyze your workout consistency!",
        isUser: false,
      ),
    );
  }

  void _sendMessage(String text) async {
    final query = text.trim();
    if (query.isEmpty) return;

    _textController.clear();
    setState(() {
      _messages.add(ChatMessage(text: query, isUser: true));
      _isLoading = true;
    });

    _scrollToBottom();

    final reply = await ApiService().sendChatMessage(
      query,
      userName: widget.userName,
      profile: widget.profile,
    );

    if (mounted) {
      setState(() {
        _messages.add(ChatMessage(text: reply, isUser: false));
        _isLoading = false;
      });
      _scrollToBottom();

      // Speak key opening line via TTS
      final firstLine = reply.split('\n').first.replaceAll('*', '');
      TtsService().speak(firstLine);
    }
  }

  void _toggleMic() {
    setState(() => _isListening = !_isListening);
    if (_isListening) {
      // Simulate quick voice transcription prompt
      _textController.text = "How can I improve my squat form?";
      Future.delayed(const Duration(milliseconds: 1400), () {
        if (mounted && _isListening) {
          final recorded = _textController.text;
          setState(() => _isListening = false);
          _sendMessage(recorded);
        }
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        border: Border(
          top: BorderSide(color: AppColors.borderDark, width: 1.5),
        ),
      ),
      child: Column(
        children: [
          // Drag Handle
          const SizedBox(height: 12),
          Container(
            width: 44,
            height: 4.5,
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 12),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'GYM STAR AI Trainer',
                        style: TextStyle(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Real-Time Biometric & Coaching Intelligence',
                        style: TextStyle(fontSize: 11, color: AppColors.accentNeon, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Divider(color: AppColors.borderDark, height: 1),

          // Quick Suggested Questions Horizontal Carousel
          Container(
            height: 44,
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _suggestedQuestions.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (ctx, idx) {
                final q = _suggestedQuestions[idx];
                return ActionChip(
                  label: Text(q),
                  onPressed: () => _sendMessage(q),
                  backgroundColor: AppColors.bgDark,
                  labelStyle: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  side: const BorderSide(color: AppColors.borderDark),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                );
              },
            ),
          ),
          const Divider(color: AppColors.borderDark, height: 1),

          // Chat Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (ctx, idx) {
                final msg = _messages[idx];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14.0),
                  child: Row(
                    mainAxisAlignment: msg.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!msg.isUser) ...[
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.fitness_center_rounded, size: 14, color: Colors.white),
                        ),
                        const SizedBox(width: 10),
                      ],
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: msg.isUser ? AppColors.primary : AppColors.bgDark,
                            borderRadius: BorderRadius.circular(20).copyWith(
                              topLeft: !msg.isUser ? const Radius.circular(4) : null,
                              topRight: msg.isUser ? const Radius.circular(4) : null,
                            ),
                            border: Border.all(
                              color: msg.isUser ? AppColors.primary : AppColors.borderDark,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              )
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                msg.text,
                                style: TextStyle(
                                  fontSize: 13.5,
                                  color: msg.isUser ? Colors.white : AppColors.textPrimary,
                                  height: 1.4,
                                ),
                              ),
                              if (!msg.isUser) ...[
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    InkWell(
                                      onTap: () => TtsService().speak(msg.text.replaceAll('*', '')),
                                      borderRadius: BorderRadius.circular(6),
                                      child: Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.volume_up_rounded,
                                              size: 14,
                                              color: AppColors.primary.withValues(alpha: 0.8),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Listen',
                                              style: TextStyle(
                                                fontSize: 10.5,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.primary.withValues(alpha: 0.8),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      if (msg.isUser) const SizedBox(width: 10),
                    ],
                  ),
                );
              },
            ),
          ),

          // Loading indicator
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.only(bottom: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                  ),
                  SizedBox(width: 10),
                  Text(
                    'AI Coach is analyzing...',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

          // Input Bar with Voice Mic
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            decoration: const BoxDecoration(
              color: AppColors.surfaceDark,
              border: Border(top: BorderSide(color: AppColors.borderDark)),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: _toggleMic,
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _isListening
                          ? AppColors.errorRed.withValues(alpha: 0.25)
                          : AppColors.surfaceElevated,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _isListening ? AppColors.errorRed : AppColors.borderDark,
                      ),
                    ),
                    child: Icon(
                      _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                      color: _isListening ? AppColors.errorRed : AppColors.textSecondary,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _textController,
                    onSubmitted: _sendMessage,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: _isListening ? 'Listening to voice prompt...' : 'Ask AI Coach anything...',
                      hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                      filled: true,
                      fillColor: AppColors.bgDark,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: AppColors.borderDark),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: AppColors.borderDark),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _sendMessage(_textController.text),
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
