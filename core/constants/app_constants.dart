// lib/core/constants/app_constants.dart
class AppConstants {
  // App Info
  static const String appName = '5 Seconds Showdown';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Think Fast, Answer Faster!';
  
  // Game Constants
  static const int defaultTimerDuration = 5;
  static const int maxRounds = 999;
  static const int coinsPerCorrectAnswer = 100;
  static const int xpPerCorrectAnswer = 50;
  static const int streakBonusMultiplier = 2;
  
  // Ad Constants
  static const int roundsBetweenInterstitials = 5;
  static const int rewardedAdCoins = 50;
  static const int dailyBonusCoins = 100;
  
  // Local Storage Keys
  static const String keyHighScore = 'high_score';
  static const String keyTotalCoins = 'total_coins';
  static const String keyTotalXP = 'total_xp';
  static const String keyGamesPlayed = 'games_played';
  static const String keyCurrentStreak = 'current_streak';
  static const String keyBestStreak = 'best_streak';
  static const String keySoundEnabled = 'sound_enabled';
  static const String keyVibrationEnabled = 'vibration_enabled';
  static const String keyMusicEnabled = 'music_enabled';
  static const String keyLastDailyBonus = 'last_daily_bonus';
  
  // Firebase Collections
  static const String collectionLeaderboard = 'leaderboard';
  static const String collectionQuestions = 'questions';
  static const String collectionUsers = 'users';
  
  // Ad Unit IDs (Replace with your actual IDs)
  static const String androidBannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111'; // Test ID
  static const String iosBannerAdUnitId = 'ca-app-pub-3940256099942544/2934735716'; // Test ID
  static const String androidInterstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712'; // Test ID
  static const String iosInterstitialAdUnitId = 'ca-app-pub-3940256099942544/4411468910'; // Test ID
  static const String androidRewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917'; // Test ID
  static const String iosRewardedAdUnitId = 'ca-app-pub-3940256099942544/1712485313'; // Test ID
  
  // Questions Categories
  static const List<String> categories = [
    'General',
    'Food',
    'Animals',
    'Sports',
    'Movies',
    'Music',
    'Geography',
    'Technology',
  ];
  
  // Sample Questions
  static const List<Map<String, dynamic>> sampleQuestions = [
    {
      'question': 'Name 3 types of fruit',
      'category': 'Food',
      'difficulty': 'easy',
    },
    {
      'question': 'Name 3 colors',
      'category': 'General',
      'difficulty': 'easy',
    },
    {
      'question': 'Name 3 animals',
      'category': 'Animals',
      'difficulty': 'easy',
    },
    {
      'question': 'Name 3 countries',
      'category': 'Geography',
      'difficulty': 'easy',
    },
    {
      'question': 'Name 3 sports',
      'category': 'Sports',
      'difficulty': 'easy',
    },
    {
      'question': 'Name 3 musicians',
      'category': 'Music',
      'difficulty': 'medium',
    },
    {
      'question': 'Name 3 movies',
      'category': 'Movies',
      'difficulty': 'easy',
    },
    {
      'question': 'Name 3 car brands',
      'category': 'General',
      'difficulty': 'easy',
    },
    {
      'question': 'Name 3 programming languages',
      'category': 'Technology',
      'difficulty': 'medium',
    },
    {
      'question': 'Name 3 planets',
      'category': 'General',
      'difficulty': 'easy',
    },
  ];
  
  // Sound Effects Paths
  static const String soundCorrect = 'assets/sounds/correct.mp3';
  static const String soundWrong = 'assets/sounds/wrong.mp3';
  static const String soundTick = 'assets/sounds/tick.mp3';
  static const String soundGameOver = 'assets/sounds/game_over.mp3';
  static const String soundWin = 'assets/sounds/win.mp3';
  static const String soundButton = 'assets/sounds/button.mp3';
  static const String soundCoin = 'assets/sounds/coin.mp3';
  
  // Social Links
  static const String instagramUrl = 'https://instagram.com/namdosan__';
  static const String githubUrl = 'https://github.com/namdosan';
  static const String linkedinUrl = 'https://linkedin.com/in/namdosan';
  
  // Privacy & Terms
  static const String privacyPolicyUrl = 'https://yourwebsite.com/privacy';
  static const String termsOfServiceUrl = 'https://yourwebsite.com/terms';
}