// lib/models/game_state.dart
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import 'question_model.dart';

class GameState {
  int _score = 0;
  int _round = 0;
  int _correctAnswers = 0;
  int _coins = 0;
  int _xp = 0;
  int _currentStreak = 0;
  int _bestStreak = 0;
  
  final List<String> _usedQuestionIds = [];
  final Random _random = Random();

  // Getters
  int get score => _score;
  int get round => _round;
  int get correctAnswers => _correctAnswers;
  int get coins => _coins;
  int get xp => _xp;
  int get currentStreak => _currentStreak;
  int get bestStreak => _bestStreak;

  // Initialize from storage
  Future<void> loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    _coins = prefs.getInt(AppConstants.keyTotalCoins) ?? 0;
    _xp = prefs.getInt(AppConstants.keyTotalXP) ?? 0;
    _bestStreak = prefs.getInt(AppConstants.keyBestStreak) ?? 0;
  }

  // Save to storage
  Future<void> saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(AppConstants.keyTotalCoins, _coins);
    await prefs.setInt(AppConstants.keyTotalXP, _xp);
    await prefs.setInt(AppConstants.keyBestStreak, _bestStreak);
    
    // Update high score if current score is higher
    final highScore = prefs.getInt(AppConstants.keyHighScore) ?? 0;
    if (_score > highScore) {
      await prefs.setInt(AppConstants.keyHighScore, _score);
    }
    
    // Increment games played
    final gamesPlayed = prefs.getInt(AppConstants.keyGamesPlayed) ?? 0;
    await prefs.setInt(AppConstants.keyGamesPlayed, gamesPlayed + 1);
  }

  // Add correct answer
  void addCorrectAnswer() {
    _correctAnswers++;
    _currentStreak++;
    
    // Update best streak
    if (_currentStreak > _bestStreak) {
      _bestStreak = _currentStreak;
    }
    
    // Calculate score with streak bonus
    final baseScore = 100;
    final streakBonus = _currentStreak * AppConstants.streakBonusMultiplier;
    _score += baseScore + streakBonus;
    
    // Increment round
    _round++;
  }

  // Reset streak
  void resetStreak() {
    _currentStreak = 0;
  }

  // Increment round (for skipped questions)
  void incrementRound() {
    _round++;
    resetStreak();
  }

  // Add coins
  void addCoins(int amount) {
    _coins += amount;
  }

  // Spend coins
  bool spendCoins(int amount) {
    if (_coins >= amount) {
      _coins -= amount;
      return true;
    }
    return false;
  }

  // Add XP
  void addXP(int amount) {
    _xp += amount;
  }

  // Get random question
  Question getRandomQuestion() {
    // Filter out used questions
    final availableQuestions = QuestionBank.questions
        .where((q) => !_usedQuestionIds.contains(q.id))
        .toList();
    
    // If all questions used, reset
    if (availableQuestions.isEmpty) {
      _usedQuestionIds.clear();
      return QuestionBank.questions[_random.nextInt(QuestionBank.questions.length)];
    }
    
    // Get random question
    final question = availableQuestions[_random.nextInt(availableQuestions.length)];
    _usedQuestionIds.add(question.id);
    
    return question;
  }

  // Get question by category
  Question? getQuestionByCategory(String category) {
    final categoryQuestions = QuestionBank.questions
        .where((q) => q.category == category && !_usedQuestionIds.contains(q.id))
        .toList();
    
    if (categoryQuestions.isEmpty) return null;
    
    final question = categoryQuestions[_random.nextInt(categoryQuestions.length)];
    _usedQuestionIds.add(question.id);
    
    return question;
  }

  // Get question by difficulty
  Question? getQuestionByDifficulty(String difficulty) {
    final difficultyQuestions = QuestionBank.questions
        .where((q) => q.difficulty == difficulty && !_usedQuestionIds.contains(q.id))
        .toList();
    
    if (difficultyQuestions.isEmpty) return null;
    
    final question = difficultyQuestions[_random.nextInt(difficultyQuestions.length)];
    _usedQuestionIds.add(question.id);
    
    return question;
  }

  // Calculate level from XP
  int get level {
    return (_xp / 1000).floor() + 1;
  }

  // Calculate XP progress to next level
  double get levelProgress {
    final currentLevelXP = (level - 1) * 1000;
    final nextLevelXP = level * 1000;
    final progress = (_xp - currentLevelXP) / (nextLevelXP - currentLevelXP);
    return progress.clamp(0.0, 1.0);
  }

  // Reset game state
  void reset() {
    _score = 0;
    _round = 0;
    _correctAnswers = 0;
    _currentStreak = 0;
    _usedQuestionIds.clear();
    // Note: coins, xp, and bestStreak persist between games
  }

  // Get statistics
  Map<String, dynamic> getStatistics() {
    return {
      'score': _score,
      'round': _round,
      'correctAnswers': _correctAnswers,
      'coins': _coins,
      'xp': _xp,
      'currentStreak': _currentStreak,
      'bestStreak': _bestStreak,
      'level': level,
      'levelProgress': levelProgress,
    };
  }

  // Get lifetime statistics
  static Future<Map<String, dynamic>> getLifetimeStatistics() async {
    final prefs = await SharedPreferences.getInstance();
    
    return {
      'highScore': prefs.getInt(AppConstants.keyHighScore) ?? 0,
      'totalCoins': prefs.getInt(AppConstants.keyTotalCoins) ?? 0,
      'totalXP': prefs.getInt(AppConstants.keyTotalXP) ?? 0,
      'gamesPlayed': prefs.getInt(AppConstants.keyGamesPlayed) ?? 0,
      'bestStreak': prefs.getInt(AppConstants.keyBestStreak) ?? 0,
      'currentStreak': prefs.getInt(AppConstants.keyCurrentStreak) ?? 0,
    };
  }

  @override
  String toString() {
    return 'GameState(score: $_score, round: $_round, correctAnswers: $_correctAnswers, '
           'coins: $_coins, xp: $_xp, currentStreak: $_currentStreak, bestStreak: $_bestStreak)';
  }
}