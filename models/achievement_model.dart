// lib/models/achievement_model.dart
class Achievement {
  final String id;
  final String name;
  final String description;
  final String emoji;
  final int requiredValue;
  final String type; // games_played, score, streak, etc.
  final int coinReward;
  final int xpReward;
  bool isUnlocked;
  int currentProgress;

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    required this.requiredValue,
    required this.type,
    this.coinReward = 50,
    this.xpReward = 100,
    this.isUnlocked = false,
    this.currentProgress = 0,
  });

  // From JSON
  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      emoji: json['emoji'] ?? '🏆',
      requiredValue: json['requiredValue'] ?? 0,
      type: json['type'] ?? 'games_played',
      coinReward: json['coinReward'] ?? 50,
      xpReward: json['xpReward'] ?? 100,
      isUnlocked: json['isUnlocked'] ?? false,
      currentProgress: json['currentProgress'] ?? 0,
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'emoji': emoji,
      'requiredValue': requiredValue,
      'type': type,
      'coinReward': coinReward,
      'xpReward': xpReward,
      'isUnlocked': isUnlocked,
      'currentProgress': currentProgress,
    };
  }

  // Update progress
  void updateProgress(int value) {
    currentProgress = value;
    if (currentProgress >= requiredValue && !isUnlocked) {
      isUnlocked = true;
    }
  }

  // Get progress percentage
  double get progressPercentage {
    return (currentProgress / requiredValue).clamp(0.0, 1.0);
  }

  // Check if can be unlocked
  bool get canUnlock => currentProgress >= requiredValue && !isUnlocked;

  @override
  String toString() {
    return 'Achievement(name: $name, progress: $currentProgress/$requiredValue, unlocked: $isUnlocked)';
  }
}

// Achievement categories
class AchievementCategory {
  final String name;
  final String emoji;
  final List<Achievement> achievements;

  AchievementCategory({
    required this.name,
    required this.emoji,
    required this.achievements,
  });

  // Get unlocked count
  int get unlockedCount {
    return achievements.where((a) => a.isUnlocked).length;
  }

  // Get total count
  int get totalCount => achievements.length;

  // Get completion percentage
  double get completionPercentage {
    if (totalCount == 0) return 0;
    return (unlockedCount / totalCount).clamp(0.0, 1.0);
  }
}