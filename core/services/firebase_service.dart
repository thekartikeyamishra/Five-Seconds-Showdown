// lib/core/services/firebase_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  // Save Score to Leaderboard
  Future<void> saveScore({
    required String playerName,
    required int score,
    required int round,
  }) async {
    try {
      await _firestore.collection('leaderboard').add({
        'playerName': playerName,
        'score': score,
        'round': round,
        'timestamp': FieldValue.serverTimestamp(),
      });
      
      // Log event to Analytics
      await _analytics.logEvent(
        name: 'score_submitted',
        parameters: {
          'score': score,
          'round': round,
        },
      );
    } catch (e) {
      print('Error saving score: $e');
    }
  }

  // Get Top Scores
  Future<List<Map<String, dynamic>>> getTopScores({int limit = 10}) async {
    try {
      final querySnapshot = await _firestore
          .collection('leaderboard')
          .orderBy('score', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) => {...doc.data(), 'id': doc.id})
          .toList();
    } catch (e) {
      print('Error getting top scores: $e');
      return [];
    }
  }

  // Log Game Event
  Future<void> logGameEvent(String eventName, Map<String, dynamic> parameters) async {
    try {
      await _analytics.logEvent(
        name: eventName,
        parameters: parameters.cast<String, Object>(),
      );
    } catch (e) {
      print('Error logging event: $e');
    }
  }
}