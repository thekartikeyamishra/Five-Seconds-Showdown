// lib/services/gemini_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart'; // Required for debugPrint
import 'package:google_generative_ai/google_generative_ai.dart';
import '../core/config/env_config.dart';
import '../models/question_model.dart';

class GeminiService {
  static final GeminiService _instance = GeminiService._internal();
  factory GeminiService() => _instance;
  GeminiService._internal();

  GenerativeModel? _model;

  // Cache to store extra questions (Cost Optimization)
  // This prevents calling the API for every single turn.
  final List<Question> _questionBuffer = [];

  /// Initialize the Gemini AI Model
  void initialize() {
    final apiKey = EnvConfig.geminiApiKey;
    if (apiKey.isNotEmpty) {
      _model = GenerativeModel(
        model: EnvConfig.geminiModel.isNotEmpty 
            ? EnvConfig.geminiModel 
            : 'gemini-pro',
        apiKey: apiKey,
        safetySettings: [
          SafetySetting(HarmCategory.harassment, HarmBlockThreshold.medium),
          SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.medium),
          SafetySetting(
            HarmCategory.sexuallyExplicit,
            HarmBlockThreshold.medium,
          ),
          SafetySetting(
            HarmCategory.dangerousContent,
            HarmBlockThreshold.medium,
          ),
        ],
      );
      debugPrint('✅ Gemini Service Initialized');
    } else {
      debugPrint(
        '⚠️ Gemini API Key is missing. AI features will use fallback questions.',
      );
    }
  }

  /// Generate Questions (Batched for Cost Efficiency)
  ///
  /// [category] - The topic (e.g., 'Food', 'History')
  /// [count] - How many questions to return to the UI immediately
  /// [difficulty] - 'easy', 'medium', or 'hard'
  /// [language] - Target language for the questions (e.g., 'Hindi', 'Spanish')
  Future<List<Question>> generateQuestions({
    required String category,
    required int count,
    String difficulty = 'medium',
    String language = 'English',
  }) async {
    // 1. Check Buffer first (Zero Cost)
    if (_questionBuffer.isNotEmpty && _questionBuffer.length >= count) {
      debugPrint('⚡ Serving questions from cache buffer (0 cost)');
      final batch = _questionBuffer.take(count).toList();
      _questionBuffer.removeRange(0, count);
      return batch;
    }

    // If model isn't initialized, return fallbacks immediately
    if (_model == null) {
      return _getFallbackQuestions(category, count);
    }

    try {
      debugPrint('🤖 Calling Gemini API for new questions...');

      // 2. Fetch Logic: Ask for MORE than needed to buffer future requests
      // If UI asks for 1, we fetch 5-10 to save future API calls.
      final fetchCount = count < 5 ? 10 : count * 2;

      final prompt =
          '''
        You are a trivia game generator. Generate $fetchCount "Name 3 things" game questions.
        
        Constraints:
        - Topic/Category: $category
        - Difficulty: $difficulty
        - Language: $language (If not English, provide questions in that language script)
        - Format: Strictly return a RAW JSON Array. Do not include markdown formatting like ```json or ```.
        
        JSON Structure per item:
        {
          "question": "The question text (e.g., Name 3 types of...)",
          "category": "$category",
          "difficulty": "$difficulty",
          "hints": ["hint1", "hint2", "hint3"]
        }
      ''';

      final content = [Content.text(prompt)];
      final response = await _model!.generateContent(content);

      if (response.text == null || response.text!.isEmpty) {
        throw Exception("Empty response from Gemini");
      }

      // Clean up the response in case Gemini adds markdown despite instructions
      final jsonString = response.text!
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      final List<dynamic> data = jsonDecode(jsonString);

      // Map JSON to Question objects
      final newQuestions = data.asMap().entries.map((e) {
        return Question(
          id: 'gemini_${DateTime.now().millisecondsSinceEpoch}_${e.key}',
          question: e.value['question']?.toString() ?? 'Name 3 things...',
          category: e.value['category']?.toString() ?? category,
          difficulty: e.value['difficulty']?.toString() ?? difficulty,
          hints: e.value['hints'] != null
              ? List<String>.from(e.value['hints'])
              : null,
        );
      }).toList();

      // 3. Fill Buffer with extras
      if (newQuestions.length > count) {
        final extras = newQuestions.sublist(count);
        _questionBuffer.addAll(extras);
        debugPrint('📦 Buffered ${extras.length} extra questions');

        return newQuestions.sublist(0, count);
      }

      return newQuestions;
    } catch (e) {
      debugPrint('❌ Gemini Error: $e');
      // On any error (network, parsing, quota), gracefully fallback
      return _getFallbackQuestions(category, count);
    }
  }

  /// Generate a Satirical/Roast comment (Satirical Mode)
  Future<String> generateRoast({
    required String playerName,
    required int score,
    required bool wasCorrect,
  }) async {
    if (_model == null) {
      return wasCorrect ? "Lucky guess!" : "Better luck next time!";
    }

    try {
      final prompt =
          '''
        You are a funny, witty game host roasting a player.
        Player Name: $playerName
        Score: $score
        Just happened: The player got the answer ${wasCorrect ? 'CORRECT' : 'WRONG'}.
        
        Task: Write a short, funny, 1-sentence roast or compliment. 
        Be sarcastic but friendly. Maximum 15 words.
      ''';

      final response = await _model!.generateContent([Content.text(prompt)]);
      return response.text?.replaceAll('"', '').trim() ??
          "Wow, what a performance.";
    } catch (e) {
      debugPrint('❌ Roast Error: $e');
      return wasCorrect ? "Impressive!" : "Ouch, that hurt.";
    }
  }

  /// Fallback questions when offline or API fails
  List<Question> _getFallbackQuestions(String category, int count) {
    debugPrint('⚠️ Using fallback questions');
    return List.generate(
      count,
      (i) => Question(
        id: 'fallback_${DateTime.now().millisecondsSinceEpoch}_$i',
        question: 'Name 3 things related to $category',
        category: category,
        difficulty: 'easy',
        hints: ['Think simple', 'Common items', 'Don\'t overthink it'],
      ),
    );
  }

  /// Clear the buffer (e.g., when switching categories completely)
  void clearBuffer() {
    _questionBuffer.clear();
  }
}