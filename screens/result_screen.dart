// lib/screens/result_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import 'package:share_plus/share_plus.dart';
import '../core/theme/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../core/services/ad_service.dart';
import '../core/services/app_review_service.dart';
import '../core/services/firebase_service.dart';
import '../core/services/analytics_service.dart';
import '../utils/sound_manager.dart';
import '../widgets/gradient_button.dart';
import '../widgets/animated_card.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({Key? key}) : super(key: key);

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late ConfettiController _confettiController;
  bool _showingRewardedAdDialog = false;
  bool _adWatched = false;
  int _bonusCoins = 0;

  // Result data
  int _score = 0;
  int _round = 0;
  int _correctAnswers = 0;
  int _coins = 0;
  int _xp = 0;
  int _streak = 0;
  String _mode = 'Solo Challenge';
  bool _useAI = false;
  bool _useLocation = false;
  bool _useVoice = false;

  @override
  void initState() {
    super.initState();
    _initializeConfetti();
    _loadResultData();
    _handlePostGameActions();
  }

  void _initializeConfetti() {
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
  }

  void _loadResultData() {
    // Get results from arguments
    final args = Get.arguments as Map<String, dynamic>?;
    
    if (args != null) {
      _score = args['score'] ?? 0;
      _round = args['round'] ?? 0;
      _correctAnswers = args['correctAnswers'] ?? 0;
      _coins = args['coins'] ?? 0;
      _xp = args['xp'] ?? 0;
      _streak = args['streak'] ?? 0;
      _mode = args['mode'] ?? 'Solo Challenge';
      _useAI = args['useAI'] ?? false;
      _useLocation = args['useLocation'] ?? false;
      _useVoice = args['useVoice'] ?? false;
    }
  }

  Future<void> _handlePostGameActions() async {
    // Play appropriate sound
    if (_score > 500) {
      await SoundManager().playWin();
      _confettiController.play();
    } else {
      await SoundManager().playGameOver();
    }
    
    // Save score to leaderboard
    await _saveScore();
    
    // Show interstitial ad (after 2 seconds delay for better UX)
    Future.delayed(const Duration(seconds: 2), () {
      AdService().showInterstitialAd();
    });
    
    // Request app review (smart timing)
    await AppReviewService().checkAndRequestReview();
    
    // Track analytics
    await _trackResults();
  }

  Future<void> _saveScore() async {
    try {
      await FirebaseService().saveScore(
        playerName: 'Player', // Replace with actual user name from profile
        score: _score,
        round: _round,
      );
    } catch (e) {
      print('Error saving score: $e');
    }
  }

  Future<void> _trackResults() async {
    try {
      await AnalyticsService().trackScreenView('result_screen');
    } catch (e) {
      print('Error tracking analytics: $e');
    }
  }

  void _showRewardedAdDialog() {
    if (_showingRewardedAdDialog || _adWatched) return;
    
    setState(() {
      _showingRewardedAdDialog = true;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: AppColors.gradientSunset,
                ),
              ),
              child: const Center(
                child: Text('💰', style: TextStyle(fontSize: 40)),
              ),
            )
                .animate(onPlay: (controller) => controller.repeat())
                .scale(
                  duration: 1000.ms,
                  begin: const Offset(1, 1),
                  end: const Offset(1.1, 1.1),
                )
                .then()
                .scale(
                  duration: 1000.ms,
                  begin: const Offset(1.1, 1.1),
                  end: const Offset(1, 1),
                ),
            const SizedBox(height: 16),
            const Text(
              'Earn Bonus Coins!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Watch a short ad to earn',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: AppColors.gradientForest,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.success.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Text(
                '+50 Coins',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
            )
                .animate()
                .shimmer(duration: 2000.ms, color: Colors.white.withOpacity(0.3)),
            const SizedBox(height: 16),
            const Text(
              'This helps us keep the game free! 🙏',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _showingRewardedAdDialog = false;
              });
            },
            child: const Text(
              'No Thanks',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 14,
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => _handleWatchAd(context),
            icon: const Icon(Icons.play_arrow, size: 20),
            label: const Text('Watch Ad'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleWatchAd(BuildContext dialogContext) async {
    Navigator.pop(dialogContext);
    
    try {
      // Check if ad is ready
      if (AdService().isRewardedAdReady) {
        // Show loading
        Get.dialog(
          Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: AppColors.primary),
                  SizedBox(height: 16),
                  Text(
                    'Loading ad...',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          barrierDismissible: false,
        );
        
        // Show rewarded ad
        await AdService().showRewardedAd(
          onRewardEarned: (amount) {
            Get.back(); // Close loading dialog
            
            setState(() {
              _bonusCoins = 50;
              _coins += 50;
              _adWatched = true;
            });
            
            SoundManager().playCoin();
            
            Get.snackbar(
              '🎉 Bonus Earned!',
              'You earned +50 coins!',
              backgroundColor: AppColors.success,
              colorText: Colors.white,
              snackPosition: SnackPosition.BOTTOM,
              duration: const Duration(seconds: 2),
              margin: const EdgeInsets.all(16),
              borderRadius: 12,
            );
            
            // Track ad view
            AnalyticsService().trackAdInteraction(
              adType: 'rewarded',
              action: 'completed',
              placement: 'result_screen',
            );
          },
        );
      } else {
        Get.snackbar(
          '😅 Oops!',
          'Ad not ready yet. Try again later!',
          backgroundColor: AppColors.warning,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
      }
    } catch (e) {
      print('Error showing rewarded ad: $e');
      Get.snackbar(
        '❌ Error',
        'Could not load ad. Please try again.',
        backgroundColor: AppColors.danger,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } finally {
      setState(() {
        _showingRewardedAdDialog = false;
      });
    }
  }

  Future<void> _handleShare() async {
    try {
      final message = '🎮 I scored $_score points in 5 Seconds Showdown! '
          'Can you beat my score? 🏆\n\n'
          '📊 Stats:\n'
          '• Round: $_round\n'
          '• Correct: $_correctAnswers\n'
          '• Streak: $_streak 🔥\n\n'
          'Download now and challenge me!';
      
      await Share.share(
        message,
        subject: 'My 5 Seconds Showdown Score!',
      );
      
      // Track share
      await AnalyticsService().trackShare(
        contentType: 'game_score',
        method: 'share_button',
      );
    } catch (e) {
      print('Error sharing: $e');
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.background, AppColors.backgroundLight],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          
          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              particleDrag: 0.05,
              emissionFrequency: 0.05,
              numberOfParticles: 20,
              gravity: 0.1,
              shouldLoop: false,
              colors: const [
                AppColors.primary,
                AppColors.secondary,
                AppColors.accent,
                AppColors.success,
              ],
            ),
          ),
          
          // Content
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    
                    // Result Icon
                    _buildResultIcon(),
                    
                    const SizedBox(height: 24),
                    
                    // Title
                    _buildTitle()
                        .animate()
                        .fadeIn(delay: 200.ms)
                        .slideY(begin: 0.3, end: 0),
                    
                    const SizedBox(height: 8),
                    
                    // Subtitle (mode)
                    _buildSubtitle()
                        .animate()
                        .fadeIn(delay: 300.ms),
                    
                    const SizedBox(height: 40),
                    
                    // Score Card
                    _buildScoreCard()
                        .animate()
                        .fadeIn(delay: 400.ms)
                        .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),
                    
                    const SizedBox(height: 20),
                    
                    // Stats Grid
                    _buildStatsGrid()
                        .animate()
                        .fadeIn(delay: 500.ms),
                    
                    const SizedBox(height: 32),
                    
                    // Rewarded Ad Button (if not watched yet)
                    if (!_adWatched)
                      _buildRewardedAdButton()
                          .animate()
                          .fadeIn(delay: 600.ms)
                          .slideY(begin: 0.2, end: 0),
                    
                    // Bonus earned message (if watched)
                    if (_adWatched)
                      _buildBonusEarnedCard()
                          .animate()
                          .fadeIn()
                          .scale(),
                    
                    const SizedBox(height: 24),
                    
                    // Action Buttons
                    _buildActionButtons()
                        .animate()
                        .fadeIn(delay: 700.ms),
                    
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultIcon() {
    final isHighScore = _score > 500;
    
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: isHighScore 
              ? AppColors.gradientForest 
              : AppColors.gradientFire,
        ),
        boxShadow: [
          BoxShadow(
            color: (isHighScore ? AppColors.success : AppColors.danger)
                .withOpacity(0.5),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Center(
        child: Text(
          isHighScore ? '🏆' : '💪',
          style: const TextStyle(fontSize: 60),
        ),
      ),
    )
        .animate()
        .scale(
          duration: 500.ms,
          curve: Curves.elasticOut,
        )
        .then()
        .shimmer(duration: 1500.ms);
  }

  Widget _buildTitle() {
    final isHighScore = _score > 500;
    
    return Text(
      isHighScore ? '🎉 Awesome!' : '💪 Keep Trying!',
      style: const TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w900,
        color: Colors.white,
      ),
    );
  }

  Widget _buildSubtitle() {
    String subtitle = _mode;
    
    if (_useAI || _useLocation || _useVoice) {
      final features = <String>[];
      if (_useAI) features.add('AI');
      if (_useLocation) features.add('Location');
      if (_useVoice) features.add('Voice');
      subtitle += ' • ${features.join(' + ')}';
    }
    
    return Text(
      subtitle,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildScoreCard() {
    return AnimatedCard(
      gradient: AppColors.gradientOcean,
      delay: Duration.zero,
      child: Column(
        children: [
          const Text(
            'Your Score',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '$_score',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 64,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          )
              .animate(onPlay: (controller) => controller.repeat())
              .shimmer(duration: 2000.ms, color: Colors.white.withOpacity(0.3)),
          const SizedBox(height: 8),
          Text(
            'Round $_round',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: [
        _buildStatCard('✅', '$_correctAnswers', 'Correct', AppColors.gradientForest, 100),
        _buildStatCard('💰', '${_coins + _bonusCoins}', 'Coins', AppColors.gradientSunset, 200),
        _buildStatCard('⭐', '$_xp', 'XP', AppColors.gradientPurple, 300),
        _buildStatCard('🔥', '$_streak', 'Best Streak', AppColors.gradientPink, 400),
      ],
    );
  }

  Widget _buildStatCard(String emoji, String value, String label, List<Color> gradient, int delayMs) {
    return AnimatedCard(
      gradient: gradient,
      delay: Duration(milliseconds: delayMs),
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardedAdButton() {
    return AnimatedCard(
      gradient: AppColors.gradientSunset,
      delay: Duration.zero,
      onTap: _showRewardedAdDialog,
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text('💰', style: TextStyle(fontSize: 32)),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Watch Ad for +50 Coins',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Optional - Help us keep the game free!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.play_arrow,
            color: Colors.white,
            size: 28,
          ),
        ],
      ),
    );
  }

  Widget _buildBonusEarnedCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.gradientForest,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.success.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          const Text('✓', style: TextStyle(fontSize: 40, color: Colors.white)),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bonus Earned!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '+50 coins added to your balance',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const Text(
            '💰',
            style: TextStyle(fontSize: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Play Again
        GradientButton(
          text: '🔄 Play Again',
          onPressed: () {
            Get.back();
            Get.toNamed('/game', arguments: {
              'mode': _mode,
              'useAI': _useAI,
              'useLocation': _useLocation,
              'useVoice': _useVoice,
            });
          },
          gradient: AppColors.gradientPurple,
        )
            .animate()
            .fadeIn(delay: 100.ms)
            .slideY(begin: 0.2, end: 0),
        
        const SizedBox(height: 12),
        
        // Share Score
        GradientButton(
          text: '📤 Share Score',
          onPressed: _handleShare,
          gradient: AppColors.gradientOcean,
        )
            .animate()
            .fadeIn(delay: 200.ms)
            .slideY(begin: 0.2, end: 0),
        
        const SizedBox(height: 12),
        
        // Back to Home
        GradientButton(
          text: '🏠 Back to Home',
          onPressed: () {
            Get.offAllNamed('/home');
          },
          gradient: AppColors.gradientPink,
        )
            .animate()
            .fadeIn(delay: 300.ms)
            .slideY(begin: 0.2, end: 0),
      ],
    );
  }
}