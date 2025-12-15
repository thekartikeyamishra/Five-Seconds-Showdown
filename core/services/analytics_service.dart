// lib/services/analytics_service.dart
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Track screen view
  Future<void> trackScreenView(String screenName) async {
    await _analytics.logScreenView(screenName: screenName);
  }

  // Track game started
  Future<void> trackGameStarted({
    required String mode,
    String? category,
  }) async {
    await _analytics.logEvent(
      name: 'game_started',
      parameters: {
        'mode': mode,
        'category': category ?? 'all',
        'timestamp': DateTime.now().toIso8601String(),
      },
    );

    // Store in Firestore for detailed analytics
    await _storeEvent('game_started', {
      'mode': mode,
      'category': category,
    });
  }

  // Track game completed
  Future<void> trackGameCompleted({
    required String mode,
    required int score,
    required int correctAnswers,
    required int totalQuestions,
    required int duration,
  }) async {
    await _analytics.logEvent(
      name: 'game_completed',
      parameters: {
        'mode': mode,
        'score': score,
        'correct_answers': correctAnswers,
        'total_questions': totalQuestions,
        'duration_seconds': duration,
        'accuracy': (correctAnswers / totalQuestions * 100).toInt(),
      },
    );

    await _storeEvent('game_completed', {
      'mode': mode,
      'score': score,
      'correct_answers': correctAnswers,
      'total_questions': totalQuestions,
      'duration': duration,
    });
  }

  // Track ad interaction
  Future<void> trackAdInteraction({
    required String adType,
    required String action,
    String? placement,
  }) async {
    await _analytics.logEvent(
      name: 'ad_interaction',
      parameters: {
        'ad_type': adType,
        'action': action,
        'placement': placement ?? 'unknown',
      },
    );

    await _storeEvent('ad_interaction', {
      'ad_type': adType,
      'action': action,
      'placement': placement,
    });
  }

  // Track purchase
  Future<void> trackPurchase({
    required String itemId,
    required String itemName,
    required double price,
    required String currency,
  }) async {
    await _analytics.logPurchase(
      value: price,
      currency: currency,
      items: [
        AnalyticsEventItem(
          itemId: itemId,
          itemName: itemName,
          price: price,
        ),
      ],
    );

    await _storeEvent('purchase', {
      'item_id': itemId,
      'item_name': itemName,
      'price': price,
      'currency': currency,
    });
  }

  // Track user progression
  Future<void> trackLevelUp({
    required int level,
    required int totalXP,
  }) async {
    await _analytics.logLevelUp(
      level: level,
      character: 'player',
    );

    await _storeEvent('level_up', {
      'level': level,
      'total_xp': totalXP,
    });
  }

  // Track achievement unlocked
  Future<void> trackAchievementUnlocked({
    required String achievementId,
    required String achievementName,
  }) async {
    await _analytics.logUnlockAchievement(
      id: achievementId,
    );

    await _storeEvent('achievement_unlocked', {
      'achievement_id': achievementId,
      'achievement_name': achievementName,
    });
  }

  // Track social share
  Future<void> trackShare({
    required String contentType,
    required String method,
  }) async {
    await _analytics.logShare(
      contentType: contentType,
      itemId: 'game_score',
      method: method,
    );

    await _storeEvent('share', {
      'content_type': contentType,
      'method': method,
    });
  }

  // Track feedback submitted
  Future<void> trackFeedback({
    required int rating,
    String? comment,
  }) async {
    await _analytics.logEvent(
      name: 'feedback_submitted',
      parameters: {
        'rating': rating,
        'has_comment': comment != null && comment.isNotEmpty,
      },
    );

    await _storeEvent('feedback', {
      'rating': rating,
      'comment_length': comment?.length ?? 0,
    });
  }

  // Track error
  Future<void> trackError({
    required String errorType,
    required String errorMessage,
    String? stackTrace,
  }) async {
    await _analytics.logEvent(
      name: 'app_error',
      parameters: {
        'error_type': errorType,
        'error_message': errorMessage.substring(0, 100.clamp(0, errorMessage.length)),
      },
    );

    await _storeEvent('error', {
      'error_type': errorType,
      'error_message': errorMessage,
      'stack_trace': stackTrace?.substring(0, 500),
    });
  }

  // Store event in Firestore for detailed analysis
  Future<void> _storeEvent(String eventName, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('analytics_events').add({
        'event_name': eventName,
        'data': data,
        'timestamp': FieldValue.serverTimestamp(),
        'platform': 'flutter',
      });
    } catch (e) {
      print('Error storing analytics event: $e');
    }
  }

  // Get user statistics
  Future<Map<String, dynamic>> getUserStatistics(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('analytics_events')
          .where('data.user_id', isEqualTo: userId)
          .get();

      int gamesPlayed = 0;
      int totalScore = 0;
      int totalCorrectAnswers = 0;
      int totalQuestions = 0;

      for (var doc in snapshot.docs) {
        final data = doc.data();
        if (data['event_name'] == 'game_completed') {
          gamesPlayed++;
          totalScore += (data['data']['score'] as int? ?? 0);
          totalCorrectAnswers += (data['data']['correct_answers'] as int? ?? 0);
          totalQuestions += (data['data']['total_questions'] as int? ?? 0);
        }
      }

      return {
        'games_played': gamesPlayed,
        'total_score': totalScore,
        'average_score': gamesPlayed > 0 ? totalScore / gamesPlayed : 0,
        'total_correct_answers': totalCorrectAnswers,
        'accuracy': totalQuestions > 0 ? (totalCorrectAnswers / totalQuestions * 100) : 0,
      };
    } catch (e) {
      print('Error getting user statistics: $e');
      return {};
    }
  }

  // Get popular game modes
  Future<Map<String, int>> getPopularGameModes() async {
    try {
      final snapshot = await _firestore
          .collection('analytics_events')
          .where('event_name', isEqualTo: 'game_started')
          .limit(1000)
          .get();

      final modeCount = <String, int>{};

      for (var doc in snapshot.docs) {
        final mode = doc.data()['data']['mode'] as String?;
        if (mode != null) {
          modeCount[mode] = (modeCount[mode] ?? 0) + 1;
        }
      }

      return modeCount;
    } catch (e) {
      print('Error getting popular modes: $e');
      return {};
    }
  }
}