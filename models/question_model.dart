// lib/models/question_model.dart
import 'package:flutter/foundation.dart';

@immutable
class Question {
  final String id;
  final String question;
  final String category;
  final String difficulty;
  final List<String>? hints;

  const Question({
    required this.id,
    required this.question,
    required this.category,
    this.difficulty = 'medium',
    this.hints,
  });

  /// Factory constructor from JSON (Robust)
  /// Handles potential type mismatches safely
  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id']?.toString() ?? '',
      question: json['question']?.toString() ?? '',
      category: json['category']?.toString() ?? 'General',
      difficulty: json['difficulty']?.toString() ?? 'medium',
      hints: json['hints'] is List
          ? (json['hints'] as List).map((e) => e.toString()).toList()
          : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'category': category,
      'difficulty': difficulty,
      'hints': hints,
    };
  }

  /// Create a copy with modified fields (Immutable update)
  Question copyWith({
    String? id,
    String? question,
    String? category,
    String? difficulty,
    List<String>? hints,
  }) {
    return Question(
      id: id ?? this.id,
      question: question ?? this.question,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      hints: hints ?? this.hints,
    );
  }

  @override
  String toString() {
    return 'Question(id: $id, question: $question, category: $category, difficulty: $difficulty)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Question && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Fallback Question Bank for Offline Mode or Initialization
class QuestionBank {
  static const List<Question> questions = [
    Question(
      id: '1',
      question: 'Name 3 types of fruit',
      category: 'Food',
      difficulty: 'easy',
      hints: ['Think tropical', 'Think citrus', 'Think berries'],
    ),
    Question(
      id: '2',
      question: 'Name 3 colors',
      category: 'General',
      difficulty: 'easy',
    ),
    Question(
      id: '3',
      question: 'Name 3 animals that live in the ocean',
      category: 'Animals',
      difficulty: 'easy',
    ),
    Question(
      id: '4',
      question: 'Name 3 countries in Europe',
      category: 'Geography',
      difficulty: 'medium',
    ),
    Question(
      id: '5',
      question: 'Name 3 sports played with a ball',
      category: 'Sports',
      difficulty: 'easy',
    ),
    Question(
      id: '6',
      question: 'Name 3 famous musicians',
      category: 'Music',
      difficulty: 'medium',
    ),
    Question(
      id: '7',
      question: 'Name 3 Marvel superheroes',
      category: 'Movies',
      difficulty: 'easy',
    ),
    Question(
      id: '8',
      question: 'Name 3 car brands',
      category: 'General',
      difficulty: 'easy',
    ),
    Question(
      id: '9',
      question: 'Name 3 programming languages',
      category: 'Technology',
      difficulty: 'medium',
    ),
    Question(
      id: '10',
      question: 'Name 3 planets in our solar system',
      category: 'Science',
      difficulty: 'easy',
    ),
    Question(
      id: '11',
      question: 'Name 3 vegetables',
      category: 'Food',
      difficulty: 'easy',
    ),
    Question(
      id: '12',
      question: 'Name 3 things you find in a kitchen',
      category: 'General',
      difficulty: 'easy',
    ),
    Question(
      id: '13',
      question: 'Name 3 social media platforms',
      category: 'Technology',
      difficulty: 'easy',
    ),
    Question(
      id: '14',
      question: 'Name 3 types of weather',
      category: 'Nature',
      difficulty: 'easy',
    ),
    Question(
      id: '15',
      question: 'Name 3 things that are hot',
      category: 'General',
      difficulty: 'easy',
    ),
    Question(
      id: '16',
      question: 'Name 3 Disney movies',
      category: 'Movies',
      difficulty: 'easy',
    ),
    Question(
      id: '17',
      question: 'Name 3 types of dance',
      category: 'Music',
      difficulty: 'medium',
    ),
    Question(
      id: '18',
      question: 'Name 3 body parts',
      category: 'General',
      difficulty: 'easy',
    ),
    Question(
      id: '19',
      question: 'Name 3 things you find in a bathroom',
      category: 'General',
      difficulty: 'easy',
    ),
    Question(
      id: '20',
      question: 'Name 3 types of trees',
      category: 'Nature',
      difficulty: 'medium',
    ),
  ];
}