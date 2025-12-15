// lib/core/services/app_review_service.dart
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class AppReviewService {
  static final AppReviewService _instance = AppReviewService._internal();
  factory AppReviewService() => _instance;
  AppReviewService._internal();

  final InAppReview _inAppReview = InAppReview.instance;
  
  // Tracking keys
  static const String _keyGamesPlayed = 'games_played';
  static const String _keyReviewRequested = 'review_requested';
  static const String _keyReviewCompleted = 'review_completed';
  static const String _keyLastReviewRequest = 'last_review_request';
  
  // Smart review request thresholds
  static const int _gamesBeforeFirstRequest = 5;
  static const int _gamesBeforeSecondRequest = 20;
  static const int _daysBetweenRequests = 30;

  // Check if should request review (Smart, Non-Annoying)
  Future<void> checkAndRequestReview() async {
    final prefs = await SharedPreferences.getInstance();
    
    final gamesPlayed = prefs.getInt(_keyGamesPlayed) ?? 0;
    final reviewRequested = prefs.getBool(_keyReviewRequested) ?? false;
    final reviewCompleted = prefs.getBool(_keyReviewCompleted) ?? false;
    final lastRequestTime = prefs.getInt(_keyLastReviewRequest) ?? 0;
    
    // Don't ask if already completed
    if (reviewCompleted) return;
    
    // Check if enough time passed since last request
    final now = DateTime.now().millisecondsSinceEpoch;
    final daysSinceLastRequest = (now - lastRequestTime) / (1000 * 60 * 60 * 24);
    
    if (lastRequestTime > 0 && daysSinceLastRequest < _daysBetweenRequests) {
      return;
    }
    
    // Request review at smart moments
    bool shouldRequest = false;
    
    if (!reviewRequested && gamesPlayed >= _gamesBeforeFirstRequest) {
      shouldRequest = true;
    } else if (reviewRequested && gamesPlayed >= _gamesBeforeSecondRequest) {
      shouldRequest = true;
    }
    
    if (shouldRequest) {
      await _requestReview();
      await prefs.setBool(_keyReviewRequested, true);
      await prefs.setInt(_keyLastReviewRequest, now);
    }
  }

  // Request review using native dialog
  Future<void> _requestReview() async {
    if (await _inAppReview.isAvailable()) {
      await _inAppReview.requestReview();
    }
  }

  // Open store page (for manual rating)
  Future<void> openStorePage() async {
    await _inAppReview.openStoreListing(
      appStoreId: 'your_app_store_id', // Replace with actual ID
    );
  }

  // Increment games played counter
  Future<void> incrementGamesPlayed() async {
    final prefs = await SharedPreferences.getInstance();
    final gamesPlayed = (prefs.getInt(_keyGamesPlayed) ?? 0) + 1;
    await prefs.setInt(_keyGamesPlayed, gamesPlayed);
  }

  // Mark review as completed
  Future<void> markReviewCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyReviewCompleted, true);
  }

  // Share app (for organic growth)
  Future<void> shareApp() async {
    const text = '🎮 Check out 5 Seconds Showdown! A fast-paced game where you have 5 seconds to answer. Can you beat my score?';
    const url = 'https://play.google.com/store/apps/details?id=com.namdosan.five_seconds_showdown';
    
    final Uri uri = Uri.parse('mailto:?subject=Check out 5 Seconds Showdown&body=$text\n\n$url');
    
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}