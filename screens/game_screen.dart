// lib/screens/game_screen.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_tts/flutter_tts.dart'; // Added TTS

import '../core/theme/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../utils/sound_manager.dart';
import '../core/services/app_review_service.dart';
import '../core/services/analytics_service.dart';
import '../models/question_model.dart';
import '../models/game_state.dart';
import '../models/multiplayer_room.dart';

// Services
import '../services/gemini_service.dart'; // Switched from OpenAI
import '../services/location_service.dart';
import '../services/voice_recognition_service.dart';
import '../services/accessibility_service.dart'; // Added Accessibility

// Controllers
import '../controllers/multiplayer_controller.dart'; // Added Controller

// Widgets
import '../widgets/gradient_button.dart';
import '../widgets/timer_widget.dart';
import '../widgets/voice_input_button.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  // Game State
  final GameState _gameState = GameState();
  final AccessibilityService _a11y = AccessibilityService();
  
  // Multiplayer
  MultiplayerController? _multiplayerController;
  String? _roomId;
  String? _playerId;

  // Question & Timer
  Question? _currentQuestion;
  bool _isPlaying = false;
  bool _showingResult = false;
  int _timeLeft = AppConstants.defaultTimerDuration;
  Timer? _timer;
  DateTime? _startTime;

  // Game Mode Configuration
  String _gameMode = 'Solo Challenge';
  bool _useAI = false;
  bool _useLocation = false;
  bool _useVoice = false;
  bool _isMultiplayer = false;

  // Animation Controllers
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  // Voice & TTS
  final FlutterTts _tts = FlutterTts();
  bool _isListening = false;
  String _voiceInput = '';
  
  // Accessibility Visuals
  Color _overlayColor = Colors.transparent;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeTTS();
    _loadGameSettings();
    _initializeServices();
  }

  void _initializeAnimations() {
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOut),
    );
  }

  Future<void> _initializeTTS() async {
    await _tts.setLanguage("en-US");
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
  }

  void _loadGameSettings() {
    final args = Get.arguments as Map<String, dynamic>?;
    
    if (args != null) {
      _gameMode = args['mode'] ?? 'Solo Challenge';
      _useAI = args['useAI'] ?? false;
      _useLocation = args['useLocation'] ?? false;
      _useVoice = args['useVoice'] ?? false;
      _isMultiplayer = args['isMultiplayer'] ?? false;
      _roomId = args['roomId'];
      _playerId = args['playerId'];
    }

    // Initialize Multiplayer if needed
    if (_isMultiplayer && _roomId != null) {
      _initializeMultiplayer();
    }
  }

  void _initializeMultiplayer() {
    _multiplayerController = MultiplayerController(
      onRoomUpdate: _handleMultiplayerUpdate,
      onError: (error) => Get.snackbar('Error', error, backgroundColor: AppColors.danger),
      onGameEnded: _handleTimeUp,
    );
    _multiplayerController!.subscribeToRoom(_roomId!);
  }

  void _handleMultiplayerUpdate(MultiplayerRoom room) {
    // Sync state with room updates
    // Implementation depends on specific multiplayer logic requirements
  }

  Future<void> _initializeServices() async {
    if (_useVoice) {
      await VoiceRecognitionService().initialize();
    }
    
    // Initialize Gemini if AI is enabled
    if (_useAI) {
      GeminiService().initialize();
    }

    await _gameState.loadFromStorage();
  }

  // ==================== CORE GAME LOGIC ====================

  Future<void> _loadNextQuestion() async {
    try {
      Question? question;

      // 1. Determine Source
      if (_useAI && _useLocation) {
        // AI + Location
        final locationInfo = await LocationService().getLocationInfo();
        if (locationInfo != null) {
          // Use Gemini for location questions
          final questions = await GeminiService().generateQuestions(
            category: 'Location',
            count: 1,
            difficulty: 'medium',
            language: 'English', // Could be dynamic based on locale
          );
          // Customize the generic question with specific city info if needed
          // Or rely on Gemini's context if passed correctly
          question = questions.isNotEmpty ? questions.first : null;
        }
      } else if (_useAI) {
        // AI Mode (Gemini)
        final questions = await GeminiService().generateQuestions(
          category: 'General',
          count: 1,
        );
        question = questions.isNotEmpty ? questions.first : null;
      } else {
        // Standard Offline Mode
        question = _gameState.getRandomQuestion();
      }

      setState(() {
        _currentQuestion = question;
        _timeLeft = AppConstants.defaultTimerDuration;
        _voiceInput = '';
        _isListening = false;
      });

      // 2. Accessibility: Read Question Aloud
      if (_a11y.isScreenReaderEnabled && _currentQuestion != null) {
        await _tts.speak(_currentQuestion!.question);
      }

      // Track analytics
      if (_isPlaying) {
        await AnalyticsService().trackScreenView('game_screen');
      }
    } catch (e) {
      print('Error loading question: $e');
      // Fallback
      setState(() {
        _currentQuestion = _gameState.getRandomQuestion();
        _timeLeft = AppConstants.defaultTimerDuration;
      });
    }
  }

  void _startGame() {
    setState(() {
      _isPlaying = true;
      _gameState.reset();
    });
    
    _loadNextQuestion();
    SoundManager().playButtonClick();
    
    AnalyticsService().trackGameStarted(
      mode: _gameMode,
      category: _useAI ? 'Gemini AI' : 'Standard',
    );
  }

  Future<void> _handleCorrect() async {
    if (!_isPlaying || _showingResult) return;
    
    _timer?.cancel();
    
    // Sounds & Haptics
    await SoundManager().playCorrect();
    await SoundManager().playCoin();
    
    // Animation
    _scaleController.forward().then((_) => _scaleController.reverse());
    
    // Update State
    _gameState.addCorrectAnswer();
    _gameState.addCoins(AppConstants.coinsPerCorrectAnswer);
    _gameState.addXP(AppConstants.xpPerCorrectAnswer);
    
    // Multiplayer Score Submit
    if (_isMultiplayer && _roomId != null && _playerId != null) {
      _multiplayerController?.submitAnswer(
        roomId: _roomId!,
        playerId: _playerId!,
        isCorrect: true,
      );
    }

    setState(() {
      _showingResult = true;
    });
    
    await AnalyticsService().trackScreenView('game_correct_answer');
    await Future.delayed(const Duration(milliseconds: 800));
    
    setState(() {
      _showingResult = false;
    });
    
    await _loadNextQuestion();
  }

  Future<void> _handleSkip() async {
    if (!_isPlaying || _showingResult) return;
    
    _timer?.cancel();
    await SoundManager().playButtonClick();
    _gameState.incrementRound();
    await _loadNextQuestion();
  }

  Future<void> _handleTimeUp() async {
    if (!_isPlaying) return;
    
    // 1. Audio & Haptics
    await SoundManager().playWrong();
    await SoundManager().vibrate();
    
    // 2. Visual Haptics (Accessibility)
    if (_a11y.visualHapticsEnabled) {
      setState(() => _overlayColor = AppColors.danger.withOpacity(0.3));
      await Future.delayed(const Duration(milliseconds: 200));
      if (mounted) setState(() => _overlayColor = Colors.transparent);
    }

    // 3. Animation
    _shakeController.forward().then((_) => _shakeController.reverse());
    
    _gameState.resetStreak();
    
    await Future.delayed(const Duration(milliseconds: 1000));
    
    setState(() {
      _isPlaying = false;
    });
    
    await _gameState.saveToStorage();
    
    final sessionDuration = _startTime != null
        ? DateTime.now().difference(_startTime!).inSeconds
        : 0;
    
    await AnalyticsService().trackGameCompleted(
      mode: _gameMode,
      score: _gameState.score,
      correctAnswers: _gameState.correctAnswers,
      totalQuestions: _gameState.round,
      duration: sessionDuration,
    );
    
    await AppReviewService().checkAndRequestReview();
    
    Get.offNamed('/result', arguments: {
      'score': _gameState.score,
      'round': _gameState.round,
      'correctAnswers': _gameState.correctAnswers,
      'coins': _gameState.coins,
      'xp': _gameState.xp,
      'streak': _gameState.bestStreak,
      'mode': _gameMode,
      'useAI': _useAI,
      'useLocation': _useLocation,
      'useVoice': _useVoice,
    });
  }

  // ==================== UI BUILDERS ====================

  @override
  void dispose() {
    _timer?.cancel();
    _shakeController.dispose();
    _scaleController.dispose();
    _multiplayerController?.dispose();
    _tts.stop();
    VoiceRecognitionService().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isPlaying && _gameState.round == 0) {
      return _buildStartScreen();
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _pauseGame,
        ),
        title: Text(
          _gameMode,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.pause),
            onPressed: _pauseGame,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Main Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  _buildStatsHeader(),
                  const SizedBox(height: 20),
                  
                  if (_useAI || _useLocation || _useVoice)
                    _buildModeIndicators(),
                  
                  const Spacer(),
                  
                  // Timer
                  if (_isPlaying && !_showingResult)
                    TimerWidget(
                      duration: AppConstants.defaultTimerDuration,
                      onComplete: _handleTimeUp,
                      onTick: (time) {
                        setState(() {
                          _timeLeft = time;
                        });
                      },
                    ).animate().scale(duration: 300.ms, curve: Curves.easeOut),
                  
                  const Spacer(),
                  
                  // Success Message
                  if (_showingResult)
                    _buildSuccessMessage().animate().fadeIn().scale(),
                  
                  // Question Card
                  if (_currentQuestion != null && _isPlaying && !_showingResult)
                    AnimatedBuilder(
                      animation: _shakeAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(
                            _shakeAnimation.value * sin(_shakeController.value * 2 * pi),
                            0,
                          ),
                          child: child,
                        );
                      },
                      child: AnimatedBuilder(
                        animation: _scaleAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _scaleAnimation.value,
                            child: child,
                          );
                        },
                        child: _buildQuestionCard(),
                      ),
                    ),
                  
                  const Spacer(),
                  
                  // Voice Input Display
                  if (_useVoice && _voiceInput.isNotEmpty)
                    _buildVoiceInputDisplay(),
                  
                  // Action Buttons
                  if (_isPlaying && !_showingResult) _buildActionButtons(),
                  
                  const SizedBox(height: 20),
                  
                  // Tips
                  if (_isPlaying && !_showingResult) _buildTips(),
                ],
              ),
            ),
          ),
          
          // Accessibility Visual Haptics Overlay
          IgnorePointer(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              color: _overlayColor,
            ),
          ),
        ],
      ),
    );
  }

  void _pauseGame() {
    _timer?.cancel();
    // (Existing pause dialog logic...)
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('⏸️ Game Paused', style: TextStyle(color: Colors.white)),
        content: const Text('Take a breather!', style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Get.back();
            },
            child: const Text('Quit', style: TextStyle(color: AppColors.danger)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context), // Timer resumes on rebuild if managed correctly
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Resume'),
          ),
        ],
      ),
    );
  }

  // ... (Keep existing _buildStartScreen, _buildStatsHeader, etc. as they are standard UI)
  // Re-implementing simplified versions for completeness of the file:

  Widget _buildStartScreen() {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.background, AppColors.backgroundLight],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon
                Container(
                  width: 120, height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(colors: AppColors.gradientPurple),
                    boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.5), blurRadius: 30)],
                  ),
                  child: const Center(child: Text('🎮', style: TextStyle(fontSize: 60))),
                ).animate(onPlay: (c) => c.repeat()).scale(duration: 2000.ms, begin: const Offset(1,1), end: const Offset(1.1,1.1)).then().scale(begin: const Offset(1.1,1.1), end: const Offset(1,1)),
                
                const SizedBox(height: 40),
                const Text('Ready to Play?', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white)),
                const SizedBox(height: 16),
                Text(_gameMode, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.primary)),
                const SizedBox(height: 16),
                
                // Features
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: AppColors.gradientOcean),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: [
                      _buildFeatureItem('⚡', '5 Seconds', 'Per question'),
                      const SizedBox(height: 16),
                      if (_useAI) _buildFeatureItem('🤖', 'Gemini AI', 'Powered Questions'),
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),
                GradientButton(
                  text: 'Start Game',
                  onPressed: () {
                    _startTime = DateTime.now();
                    _startGame();
                  },
                  gradient: AppColors.gradientSunset,
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('Go Back', style: TextStyle(color: AppColors.textMuted)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String emoji, String value, String label) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 32)),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white)),
              Text(label, style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.8))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStatBadge('Round ${_gameState.round}'),
        _buildStatBadge('🏆 ${_gameState.score}'),
        _buildStatBadge('🔥 ${_gameState.currentStreak}'),
      ],
    );
  }

  Widget _buildStatBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
    );
  }

  Widget _buildModeIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (_useAI) _buildModeChip('🤖 Gemini'),
        if (_useAI && (_useLocation || _useVoice)) const SizedBox(width: 8),
        if (_useLocation) _buildModeChip('🌍 Local'),
        if (_useLocation && _useVoice) const SizedBox(width: 8),
        if (_useVoice) _buildModeChip('🎤 Voice'),
      ],
    );
  }

  Widget _buildModeChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: AppColors.gradientPurple),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildSuccessMessage() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: AppColors.gradientForest),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        children: [
          const Text('✓', style: TextStyle(fontSize: 64, color: Colors.white)),
          const Text('Correct!', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  Widget _buildQuestionCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.gradientOcean,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Your Question:', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          // Accessibility: High Contrast Text Support handled by theme or specific widget wrapping if needed
          Text(
            _currentQuestion!.question,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700, height: 1.3),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(_currentQuestion!.category, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceInputDisplay() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _isListening ? AppColors.primary : AppColors.border, width: 2),
      ),
      child: Row(
        children: [
          Icon(_isListening ? Icons.mic : Icons.mic_none, color: _isListening ? AppColors.primary : AppColors.textMuted),
          const SizedBox(width: 12),
          Expanded(child: Text(_voiceInput.isEmpty ? 'Tap microphone to speak' : _voiceInput, style: const TextStyle(color: Colors.white))),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        if (_useVoice)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: VoiceInputButton(
              isListening: _isListening,
              onPressed: _handleVoiceInput,
            ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2, end: 0),
          ),
        
        // Wrap with Semantics for Blind Users
        Semantics(
          label: 'I got the answer',
          button: true,
          child: GradientButton(
            text: '✓ Got It!',
            onPressed: _handleCorrect,
            gradient: AppColors.gradientForest,
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
        ),
        
        const SizedBox(height: 12),
        
        Semantics(
          label: 'Skip question',
          button: true,
          child: GradientButton(
            text: '→ Skip',
            onPressed: _handleSkip,
            gradient: AppColors.gradientFire,
          ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),
        ),
      ],
    );
  }

  Future<void> _handleVoiceInput() async {
    if (_isListening) return;

    setState(() {
      _isListening = true;
      _voiceInput = 'Listening...';
    });

    await VoiceRecognitionService().startListening(
      onResult: (text) {
        setState(() {
          _voiceInput = text;
          _isListening = false;
        });

        final isValid = VoiceRecognitionService().checkAnswer(
          voiceAnswer: text,
          question: _currentQuestion?.question ?? '',
          requiredCount: 3,
        );

        if (isValid) {
          _handleCorrect();
        } else {
          Get.snackbar(
            '🎤 Try Again',
            'We heard: "$text". Try naming 3 things clearly.',
            backgroundColor: AppColors.warning,
            colorText: Colors.white,
          );
          setState(() => _voiceInput = '');
        }
      },
      onError: (error) {
        setState(() {
          _voiceInput = '';
          _isListening = false;
        });
        Get.snackbar('❌ Voice Error', error, backgroundColor: AppColors.danger, colorText: Colors.white);
      },
    );
  }

  Widget _buildTips() {
    String tip = '💡 Speak your answers out loud!';
    if (_useVoice) tip = '🎤 Tap the microphone to use voice input!';
    else if (_useAI) tip = '🤖 Gemini AI questions are fresh every time!';
    
    return Text(tip, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textMuted, fontSize: 14, fontStyle: FontStyle.italic)).animate().fadeIn(delay: 400.ms);
  }
}