// lib/core/services/feedback_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FeedbackService {
  static final FeedbackService _instance = FeedbackService._internal();
  factory FeedbackService() => _instance;
  FeedbackService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Show feedback dialog (Non-Annoying)
  Future<void> showFeedbackDialog(BuildContext context) async {
    final TextEditingController feedbackController = TextEditingController();
    int rating = 0;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: const Text(
          '💬 We Value Your Feedback',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Help us make the game better!',
                style: TextStyle(color: Color(0xFFCBD5E1)),
              ),
              const SizedBox(height: 16),
              
              // Star rating
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 32,
                    ),
                    onPressed: () {
                      setState(() {
                        rating = index + 1;
                      });
                    },
                  );
                }),
              ),
              
              const SizedBox(height: 16),
              
              // Feedback text field
              TextField(
                controller: feedbackController,
                maxLines: 4,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Tell us what you think...',
                  hintStyle: const TextStyle(color: Color(0xFF64748B)),
                  filled: true,
                  fillColor: const Color(0xFF334155),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Later',
              style: TextStyle(color: Color(0xFF64748B)),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (rating > 0) {
                await _submitFeedback(
                  rating: rating,
                  feedback: feedbackController.text,
                );
                Navigator.pop(context);
                
                Get.snackbar(
                  '✅ Thank You!',
                  'Your feedback helps us improve',
                  backgroundColor: const Color(0xFF10B981),
                  colorText: Colors.white,
                  snackPosition: SnackPosition.BOTTOM,
                  duration: const Duration(seconds: 2),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B5CF6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  // Submit feedback to Firebase
  Future<void> _submitFeedback({
    required int rating,
    required String feedback,
  }) async {
    try {
      await _firestore.collection('feedback').add({
        'rating': rating,
        'feedback': feedback,
        'timestamp': FieldValue.serverTimestamp(),
        'platform': GetPlatform.isAndroid ? 'android' : 'ios',
        'version': '1.0.0',
      });
    } catch (e) {
      print('Error submitting feedback: $e');
    }
  }

  // Report bug
  Future<void> reportBug({
    required String description,
    String? stackTrace,
  }) async {
    try {
      await _firestore.collection('bug_reports').add({
        'description': description,
        'stackTrace': stackTrace,
        'timestamp': FieldValue.serverTimestamp(),
        'platform': GetPlatform.isAndroid ? 'android' : 'ios',
        'version': '1.0.0',
      });
    } catch (e) {
      print('Error reporting bug: $e');
    }
  }

  // Submit feature request
  Future<void> requestFeature({
    required String title,
    required String description,
  }) async {
    try {
      await _firestore.collection('feature_requests').add({
        'title': title,
        'description': description,
        'votes': 0,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'pending',
      });
    } catch (e) {
      print('Error submitting feature request: $e');
    }
  }
}