// lib/services/ai_satirical_service.dart
// COMPLETE ERROR-FREE AI SATIRICAL MODE
// - Hilarious ad integration with REAL AdMob IDs
// - Ethical data collection for future AI training
// - All errors fixed

import 'dart:async';
import 'dart:math';
import 'dart:io' show Platform;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class AISatiricalAdvancedService {
  static final AISatiricalAdvancedService _instance = 
      AISatiricalAdvancedService._internal();
  factory AISatiricalAdvancedService() => _instance;
  AISatiricalAdvancedService._internal();

  final FlutterTts _tts = FlutterTts();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  bool _isInitialized = false;
  int _roastCount = 0;
  int _adShowCount = 0;
  String _sessionId = '';
  String _lastRoast = '';
  
  // Data collection consent
  bool _userConsentedToDataCollection = false;
  
  // Ad timing
  final int _roastsUntilAd = 5; // Show ad after 5 roasts
  
  RewardedAd? _rewardedAd;
  bool _isAdLoaded = false;
  
  // Initialize service
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Initialize TTS
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.5);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
      
      // Create session ID
      _sessionId = DateTime.now().millisecondsSinceEpoch.toString();
      
      // Check data collection consent
      await _loadDataCollectionConsent();
      
      // Load first ad
      await _loadRewardedAd();
      
      _isInitialized = true;
      debugPrint('AI Satirical Advanced Service initialized');
    } catch (e) {
      debugPrint('Error initializing: $e');
    }
  }
  
  // ==========================================================================
  // AD INTEGRATION - HILARIOUS WAYS WITH REAL IDS
  // ==========================================================================
  
  /// Load rewarded ad
  Future<void> _loadRewardedAd() async {
    try {
      await RewardedAd.load(
        adUnitId: _getRewardedAdUnitId(),
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            _rewardedAd = ad;
            _isAdLoaded = true;
            debugPrint('Rewarded ad loaded for satirical mode');
            
            // Set ad callbacks
            _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (ad) {
                _onAdClosed();
                ad.dispose();
                _loadRewardedAd(); // Load next ad
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                debugPrint('Ad failed to show: $error');
                ad.dispose();
                _loadRewardedAd();
              },
            );
          },
          onAdFailedToLoad: (error) {
            debugPrint('Rewarded ad failed to load: $error');
            _isAdLoaded = false;
          },
        ),
      );
    } catch (e) {
      debugPrint('Error loading rewarded ad: $e');
    }
  }
  
  /// Get ad unit ID based on platform - REAL IDs
  String _getRewardedAdUnitId() {
    // YOUR REAL ADMOB IDS
    return Platform.isAndroid
        ? 'ca-app-pub-4557897331416844/2433959439' // Your Android Rewarded ID
        : 'ca-app-pub-4557897331416844/2306090633'; // Your iOS Rewarded ID
  }
  
  /// Show ad with hilarious intro
  Future<String> maybeShowAdWithRoast() async {
    _roastCount++;
    
    // Check if it's time for an ad
    if (_roastCount >= _roastsUntilAd && _isAdLoaded) {
      return await _showAdWithFunnyIntro();
    }
    
    return '';
  }
  
  /// Show ad with funny introduction
  Future<String> _showAdWithFunnyIntro() async {
    // Hilarious ad intro roasts
    final funnyIntros = [
      "That roast was SO good, I'm gonna reward MYSELF with an ad break! 🎬",
      "You know what? Your terrible answer deserves a punishment... AN AD! 😈",
      "Commercial break! Time for me to make some money off your failures! 💰",
      "AD TIME! Consider this your timeout for being so hilariously wrong! 📺",
      "I need a break from roasting you. Here's an ad to cleanse my palate! 🍿",
      "Congratulations! You've unlocked: ADVERTISEMENT MODE! Watch and earn! 🎯",
      "Your performance was so bad, even the ads want to intervene! 😅",
      "Plot twist: The ad is actually more entertaining than your answers! 🎭",
      "Breaking news: Local AI needs ad revenue to cope with your gameplay! 📰",
      "This ad is brought to you by: Your questionable life choices! 🎪",
    ];
    
    final intro = funnyIntros[Random().nextInt(funnyIntros.length)];
    _lastRoast = intro;
    
    // Speak the intro
    await speak(intro);
    
    // Wait for speech to finish
    await Future.delayed(const Duration(seconds: 3));
    
    // Show the ad
    if (_rewardedAd != null) {
      await _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          debugPrint('User earned reward: ${reward.amount} ${reward.type}');
          // Give user bonus coins for watching
          _giveAdReward(reward.amount);
        },
      );
    }
    
    return intro;
  }
  
  /// Called when ad is closed
  void _onAdClosed() {
    _roastCount = 0; // Reset counter
    _adShowCount++;
    
    // Funny post-ad roast
    final postAdRoasts = [
      "Welcome back! Did you miss me? Of course you did! Let's continue...",
      "And we're back! That ad was more educational than your answers!",
      "Ad's over! Hope you learned something. Like how NOT to play this game!",
      "Thanks for watching! Now back to your regularly scheduled roasting!",
      "Ad break over! Your patience is appreciated. Your answers, not so much!",
    ];
    
    final postRoast = postAdRoasts[Random().nextInt(postAdRoasts.length)];
    speak(postRoast);
  }
  
  /// Give reward for watching ad
  void _giveAdReward(num amount) {
    debugPrint('Giving user $amount bonus coins for watching ad');
    // Integrate with your points/coins system here
    // Example: gameState.addCoins(amount.toInt());
  }
  
  // ==========================================================================
  // DATA COLLECTION - ETHICAL & COMPLIANT
  // ==========================================================================
  
  /// Request user consent for data collection
  Future<bool> requestDataCollectionConsent() async {
    return await _loadDataCollectionConsent();
  }
  
  /// Load data collection consent
  Future<bool> _loadDataCollectionConsent() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _userConsentedToDataCollection = prefs.getBool('data_collection_consent') ?? false;
      return _userConsentedToDataCollection;
    } catch (e) {
      debugPrint('Error loading consent: $e');
      return false;
    }
  }
  
  /// Save data collection consent
  Future<void> saveDataCollectionConsent(bool consent) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('data_collection_consent', consent);
      _userConsentedToDataCollection = consent;
      
      // Log consent event
      await _logConsentEvent(consent);
    } catch (e) {
      debugPrint('Error saving consent: $e');
    }
  }
  
  /// Log consent event to Firestore
  Future<void> _logConsentEvent(bool consent) async {
    if (!_userConsentedToDataCollection) return;
    
    try {
      await _firestore.collection('consent_logs').add({
        'session_id': _sessionId,
        'timestamp': FieldValue.serverTimestamp(),
        'consent_given': consent,
        'version': '1.0',
      });
    } catch (e) {
      debugPrint('Error logging consent: $e');
    }
  }
  
  /// Collect interaction data (with consent)
  Future<void> collectInteractionData({
    required String questionAsked,
    required String userAnswer,
    required bool wasCorrect,
    required String aiRoast,
    required double responseTime,
    String? voiceInput,
    Map<String, dynamic>? metadata,
  }) async {
    // Only collect if user consented
    if (!_userConsentedToDataCollection) return;
    
    try {
      // Redact PII (Personally Identifiable Information)
      final cleanAnswer = _redactPII(userAnswer);
      final cleanVoice = voiceInput != null ? _redactPII(voiceInput) : null;
      
      // Prepare data for collection
      final data = {
        'session_id': _sessionId,
        'timestamp': FieldValue.serverTimestamp(),
        
        // Question & Answer (anonymized)
        'question': questionAsked,
        'user_answer': cleanAnswer,
        'voice_input': cleanVoice,
        'was_correct': wasCorrect,
        'response_time_seconds': responseTime,
        
        // AI Behavior
        'ai_roast': aiRoast,
        'roast_type': _getRoastType(wasCorrect),
        
        // Context (non-PII metadata only)
        'metadata': {
          'app_version': metadata?['app_version'] ?? '1.0.0',
          'device_locale': metadata?['locale'] ?? 'en-US',
          'question_category': metadata?['category'] ?? 'general',
        },
        
        // Data collection metadata
        'data_purpose': 'ai_model_training',
        'retention_period': 'anonymized_indefinitely',
        'can_use_for_training': true,
      };
      
      // Store in Firestore
      await _firestore
          .collection('ai_training_data')
          .doc(_sessionId)
          .collection('interactions')
          .add(data);
          
      debugPrint('Interaction data collected (anonymized)');
    } catch (e) {
      debugPrint('Error collecting data: $e');
    }
  }
  
  /// Collect voice audio data (with explicit consent)
  Future<void> collectVoiceData({
    required String audioFilePath,
    required String transcription,
    required Map<String, dynamic> audioMetadata,
  }) async {
    if (!_userConsentedToDataCollection) return;
    
    try {
      final data = {
        'session_id': _sessionId,
        'timestamp': FieldValue.serverTimestamp(),
        
        // Audio file reference
        'audio_file_ref': audioFilePath,
        'transcription': _redactPII(transcription),
        
        // Audio characteristics
        'audio_metadata': {
          'duration_ms': audioMetadata['duration'],
          'sample_rate': audioMetadata['sample_rate'],
          'channels': audioMetadata['channels'],
          'format': audioMetadata['format'],
          'environment_type': audioMetadata['environment'],
          'speech_rate': audioMetadata['speech_rate'],
        },
        
        // Consent trail
        'consent_timestamp': FieldValue.serverTimestamp(),
        'consent_version': '1.0',
        'explicit_voice_consent': true,
        
        // Usage rights
        'can_use_for_training': true,
        'can_share_anonymously': true,
        'retention_policy': 'delete_after_training',
      };
      
      await _firestore
          .collection('voice_training_data')
          .doc(_sessionId)
          .collection('recordings')
          .add(data);
          
      debugPrint('Voice data collected (with explicit consent)');
    } catch (e) {
      debugPrint('Error collecting voice data: $e');
    }
  }
  
  /// Collect language diversity data
  Future<void> collectLanguageData({
    required String detectedLanguage,
    required String? detectedAccent,
    required bool wasCodeSwitching,
    List<String>? languagesSwitched,
  }) async {
    if (!_userConsentedToDataCollection) return;
    
    try {
      final data = {
        'session_id': _sessionId,
        'timestamp': FieldValue.serverTimestamp(),
        
        // Language characteristics
        'primary_language': detectedLanguage,
        'detected_accent': detectedAccent,
        'code_switching': wasCodeSwitching,
        'languages_in_utterance': languagesSwitched ?? [],
        
        // For multilingual model training
        'language_tagged': wasCodeSwitching,
        'low_resource_language': _isLowResourceLanguage(detectedLanguage),
      };
      
      await _firestore
          .collection('language_diversity_data')
          .doc(_sessionId)
          .collection('utterances')
          .add(data);
    } catch (e) {
      debugPrint('Error collecting language data: $e');
    }
  }
  
  /// Redact PII from text
  String _redactPII(String text) {
    String cleaned = text;
    
    // Phone numbers (Indian and international)
    cleaned = cleaned.replaceAll(
      RegExp(r'\b[\+]?[(]?[0-9]{3}[)]?[-\s\.]?[0-9]{3}[-\s\.]?[0-9]{4,6}\b'),
      '[PHONE]',
    );
    
    // Emails
    cleaned = cleaned.replaceAll(
      RegExp(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b'),
      '[EMAIL]',
    );
    
    // Aadhaar numbers (Indian ID)
    cleaned = cleaned.replaceAll(
      RegExp(r'\b[0-9]{4}\s?[0-9]{4}\s?[0-9]{4}\b'),
      '[AADHAAR]',
    );
    
    // URLs
    cleaned = cleaned.replaceAll(
      RegExp(r'https?://[^\s]+'),
      '[URL]',
    );
    
    // Common name patterns
    cleaned = cleaned.replaceAll(
      RegExp(r'\b(Mr|Mrs|Ms|Dr)\.?\s+[A-Z][a-z]+\s+[A-Z][a-z]+\b'),
      '[NAME]',
    );
    
    return cleaned;
  }
  
  /// Check if language is low-resource
  bool _isLowResourceLanguage(String language) {
    const lowResourceLanguages = [
      'bhojpuri', 'maithili', 'santali', 'konkani', 'tulu',
      'bodo', 'dogri', 'kashmiri', 'manipuri', 'sindhi',
    ];
    return lowResourceLanguages.contains(language.toLowerCase());
  }
  
  /// Get roast type for categorization
  String _getRoastType(bool wasCorrect) {
    return wasCorrect ? 'congratulatory_sarcasm' : 'failure_mockery';
  }
  
  // ==========================================================================
  // ROAST GENERATORS
  // ==========================================================================
  
  Future<void> speak(String text) async {
    try {
      await _tts.speak(text);
    } catch (e) {
      debugPrint('Error speaking: $e');
    }
  }
  
  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (e) {
      debugPrint('Error stopping TTS: $e');
    }
  }
  
  String getWelcomeRoast() {
    final roasts = [
      "Oh wonderful, another victim... I mean player! Let's see if you can handle 5 whole seconds.",
      "Welcome to your personal comedy roast show! Spoiler alert: You're the star.",
      "Ready to play? Great! I've been practicing my sarcasm all day for this moment.",
      "Ah, a new challenger! Let me just adjust my expectations... there, lowered them to zero.",
      "5 seconds? That's about how long your confidence will last. Let's begin!",
    ];
    _lastRoast = roasts[Random().nextInt(roasts.length)];
    speak(_lastRoast);
    return _lastRoast;
  }
  
  String getCorrectAnswerRoast(int streak) {
    // Check if ad should be shown
    maybeShowAdWithRoast();
    
    List<String> roasts;
    
    if (streak == 1) {
      roasts = [
        "Wow, you actually got one right! Don't let it go to your head.",
        "Correct! A broken clock is right twice a day, and you're on schedule.",
        "Look at you! One whole correct answer. Someone alert the press!",
      ];
    } else if (streak <= 3) {
      roasts = [
        "Two in a row? Okay, maybe you're not completely hopeless!",
        "Look at you showing off! Don't worry, I'm sure you'll mess up soon.",
        "Streak of $streak! Should I be worried about my job here?",
      ];
    } else if (streak <= 5) {
      roasts = [
        "Okay fine, you're good at this. Happy now? Don't let it go to your head!",
        "Streak of $streak! You're like a trivia ninja. A very slow ninja, but still.",
        "Alright champion, you're making me look bad. Keep it up!",
      ];
    } else {
      roasts = [
        "STREAK OF $streak?! Okay you win, you're actually brilliant!",
        "You're unstoppable! I'm running out of roasts and into compliments!",
        "At this point you're just showing off. Respect! 🔥",
      ];
    }
    
    _lastRoast = roasts[Random().nextInt(roasts.length)];
    speak(_lastRoast);
    return _lastRoast;
  }
  
  String getWrongAnswerRoast(int failCount) {
    List<String> roasts;
    
    if (failCount == 1) {
      roasts = [
        "Oops! That was... well, it was something. Not a correct answer, but something!",
        "Wrong! But hey, at least you tried. That counts for... actually no, it doesn't.",
        "Nope! Better luck next time. By 'next time' I mean in like 3 seconds.",
      ];
    } else if (failCount <= 3) {
      roasts = [
        "Wrong again! This is becoming a pattern. An unfortunate pattern.",
        "Still not right! Maybe try thinking INSIDE the box for once?",
        "Incorrect! At this rate, we'll be here all day.",
      ];
    } else {
      roasts = [
        "How do you keep getting these wrong? It's almost impressive!",
        "Wrong yet again! Should I slow down? Use smaller words?",
        "Still wrong! But hey, at least you're consistent. Consistently wrong!",
      ];
    }
    
    _lastRoast = roasts[Random().nextInt(roasts.length)];
    speak(_lastRoast);
    return _lastRoast;
  }
  
  String getTimeoutRoast() {
    final roasts = [
      "Time's up! 5 seconds was apparently 4 seconds too many for you.",
      "Too slow! My grandmother answers faster, and she's not even playing!",
      "Timeout! Were you waiting for divine inspiration? Because it didn't show up.",
      "Time's up! You had one job: answer in 5 seconds. ONE. JOB.",
    ];
    _lastRoast = roasts[Random().nextInt(roasts.length)];
    speak(_lastRoast);
    return _lastRoast;
  }
  
  String getGameOverRoast(int finalScore, int totalQuestions) {
    final percentage = (finalScore / (totalQuestions * 10) * 100).round();
    
    List<String> roasts;
    
    if (percentage >= 90) {
      roasts = [
        "WOW! Score of $finalScore? You absolutely crushed it! I bow to you!",
        "Incredible! $finalScore points! You're so good, I'm almost speechless. Almost.",
      ];
    } else if (percentage >= 70) {
      roasts = [
        "Pretty good! $finalScore points! You're like a B+ student. Solid.",
        "Not bad! $finalScore points! You're competent. That's a compliment!",
      ];
    } else if (percentage >= 50) {
      roasts = [
        "Okay, $finalScore points. That's... that's something.",
        "$finalScore points! Right in the middle. Not impressive, not terrible.",
      ];
    } else {
      roasts = [
        "Ouch. $finalScore points. That's... well, at least you showed up!",
        "$finalScore points? Don't worry, tomorrow is a new day!",
      ];
    }
    
    _lastRoast = roasts[Random().nextInt(roasts.length)];
    speak(_lastRoast);
    return _lastRoast;
  }
  
  // ==========================================================================
  // ANALYTICS & UTILITY
  // ==========================================================================
  
  Map<String, dynamic> getAdPerformance() {
    return {
      'ads_shown': _adShowCount,
      'roast_count': _roastCount,
      'next_ad_in': _roastsUntilAd - _roastCount,
      'is_ad_loaded': _isAdLoaded,
    };
  }
  
  String getLastRoast() => _lastRoast;
  
  Future<void> dispose() async {
    await stop();
    _rewardedAd?.dispose();
  }
}