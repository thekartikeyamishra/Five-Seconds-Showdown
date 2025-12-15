// lib/core/config/env_config.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  // Private constructor to prevent instantiation
  EnvConfig._();

  // Environment loaded flag
  static bool _isLoaded = false;

  // Initialize environment variables
  static Future<void> initialize() async {
    if (_isLoaded) return;

    try {
      await dotenv.load(fileName: '.env');
      _isLoaded = true;
      print('Environment variables loaded successfully');
    } catch (e) {
      print('Warning: Could not load .env file: $e');
      print('Using default/empty values');
      _isLoaded = true; // Continue with empty values
    }
  }

  // ==================== GOOGLE GEMINI API ====================
  
  /// Google Gemini API Key for AI generation
  /// Get from: https://aistudio.google.com/app/apikey
  static String get geminiApiKey {
    return dotenv.env['GEMINI_API_KEY'] ?? '';
  }

  /// Gemini Model to use (defaulting to pro for better performance/cost balance)
  static String get geminiModel {
    return dotenv.env['GEMINI_MODEL'] ?? 'gemini-pro';
  }

  // ==================== FIREBASE ====================
  
  /// Firebase API Key
  static String get firebaseApiKey {
    return dotenv.env['FIREBASE_API_KEY'] ?? '';
  }

  /// Firebase Project ID
  static String get firebaseProjectId {
    return dotenv.env['FIREBASE_PROJECT_ID'] ?? '';
  }

  /// Firebase Storage Bucket
  static String get firebaseStorageBucket {
    return dotenv.env['FIREBASE_STORAGE_BUCKET'] ?? '';
  }

  /// Firebase Messaging Sender ID
  static String get firebaseMessagingSenderId {
    return dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? '';
  }

  /// Firebase App ID (Android)
  static String get firebaseAndroidAppId {
    return dotenv.env['FIREBASE_ANDROID_APP_ID'] ?? '';
  }

  /// Firebase App ID (iOS)
  static String get firebaseIosAppId {
    return dotenv.env['FIREBASE_IOS_APP_ID'] ?? '';
  }

  // ==================== ADMOB ====================
  
  /// Android Banner Ad Unit ID
  static String get androidBannerAdId {
    return dotenv.env['ANDROID_BANNER_AD_ID'] ?? 
           'ca-app-pub-3940256099942544/6300978111'; // Test ID
  }

  /// iOS Banner Ad Unit ID
  static String get iosBannerAdId {
    return dotenv.env['IOS_BANNER_AD_ID'] ?? 
           'ca-app-pub-3940256099942544/2934735716'; // Test ID
  }

  /// Android Interstitial Ad Unit ID
  static String get androidInterstitialAdId {
    return dotenv.env['ANDROID_INTERSTITIAL_AD_ID'] ?? 
           'ca-app-pub-3940256099942544/1033173712'; // Test ID
  }

  /// iOS Interstitial Ad Unit ID
  static String get iosInterstitialAdId {
    return dotenv.env['IOS_INTERSTITIAL_AD_ID'] ?? 
           'ca-app-pub-3940256099942544/4411468910'; // Test ID
  }

  /// Android Rewarded Ad Unit ID
  static String get androidRewardedAdId {
    return dotenv.env['ANDROID_REWARDED_AD_ID'] ?? 
           'ca-app-pub-3940256099942544/5224354917'; // Test ID
  }

  /// iOS Rewarded Ad Unit ID
  static String get iosRewardedAdId {
    return dotenv.env['IOS_REWARDED_AD_ID'] ?? 
           'ca-app-pub-3940256099942544/1712485313'; // Test ID
  }

  /// AdMob App ID (Android)
  static String get androidAdMobAppId {
    return dotenv.env['ANDROID_ADMOB_APP_ID'] ?? 
           'ca-app-pub-3940256099942544~3347511713'; // Test ID
  }

  /// AdMob App ID (iOS)
  static String get iosAdMobAppId {
    return dotenv.env['IOS_ADMOB_APP_ID'] ?? 
           'ca-app-pub-3940256099942544~1458002511'; // Test ID
  }

  // ==================== APP CONFIG ====================
  
  /// Application Name
  static String get appName {
    return dotenv.env['APP_NAME'] ?? '5 Seconds Showdown';
  }

  /// Application Version
  static String get appVersion {
    return dotenv.env['APP_VERSION'] ?? '1.0.0';
  }

  /// Application Build Number
  static String get buildNumber {
    return dotenv.env['BUILD_NUMBER'] ?? '1';
  }

  /// Environment (dev, staging, production)
  static String get environment {
    return dotenv.env['ENVIRONMENT'] ?? 'production';
  }

  /// API Base URL (if using custom backend)
  static String get apiBaseUrl {
    return dotenv.env['API_BASE_URL'] ?? '';
  }

  // ==================== FEATURE FLAGS ====================
  
  /// Enable Voice Recognition
  static bool get enableVoiceRecognition {
    return dotenv.env['ENABLE_VOICE']?.toLowerCase() == 'true';
  }

  /// Enable Multiplayer
  static bool get enableMultiplayer {
    return dotenv.env['ENABLE_MULTIPLAYER']?.toLowerCase() == 'true';
  }

  /// Enable AI Question Generation (Switched to Gemini)
  static bool get enableAI {
    return dotenv.env['ENABLE_AI']?.toLowerCase() == 'true';
  }

  /// Enable Location-Based Questions
  static bool get enableLocation {
    return dotenv.env['ENABLE_LOCATION']?.toLowerCase() == 'true';
  }

  /// Enable Analytics
  static bool get enableAnalytics {
    return dotenv.env['ENABLE_ANALYTICS']?.toLowerCase() == 'true';
  }

  /// Enable Crash Reporting
  static bool get enableCrashReporting {
    return dotenv.env['ENABLE_CRASH_REPORTING']?.toLowerCase() == 'true';
  }

  /// Enable Debug Mode
  static bool get debugMode {
    return dotenv.env['DEBUG_MODE']?.toLowerCase() == 'true';
  }

  /// Enable Test Ads (use test IDs instead of real)
  static bool get useTestAds {
    return dotenv.env['USE_TEST_ADS']?.toLowerCase() == 'true';
  }

  // ==================== THIRD PARTY SERVICES ====================
  
  /// Sentry DSN (Error Tracking)
  static String get sentryDsn {
    return dotenv.env['SENTRY_DSN'] ?? '';
  }

  /// Mixpanel Token (Analytics)
  static String get mixpanelToken {
    return dotenv.env['MIXPANEL_TOKEN'] ?? '';
  }

  /// Google Places API Key (for location features)
  static String get googlePlacesApiKey {
    return dotenv.env['GOOGLE_PLACES_API_KEY'] ?? '';
  }

  /// OneSignal App ID (Push Notifications)
  static String get oneSignalAppId {
    return dotenv.env['ONESIGNAL_APP_ID'] ?? '';
  }

  // ==================== SOCIAL MEDIA ====================
  
  /// Facebook App ID
  static String get facebookAppId {
    return dotenv.env['FACEBOOK_APP_ID'] ?? '';
  }

  /// Twitter API Key
  static String get twitterApiKey {
    return dotenv.env['TWITTER_API_KEY'] ?? '';
  }

  /// Instagram Client ID
  static String get instagramClientId {
    return dotenv.env['INSTAGRAM_CLIENT_ID'] ?? '';
  }

  // ==================== PAYMENT ====================
  
  /// Stripe Publishable Key
  static String get stripePublishableKey {
    return dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? '';
  }

  /// In-App Purchase Product IDs
  static String get iapRemoveAdsProductId {
    return dotenv.env['IAP_REMOVE_ADS_ID'] ?? 'remove_ads';
  }

  static String get iapCoins500ProductId {
    return dotenv.env['IAP_COINS_500_ID'] ?? 'coins_500';
  }

  static String get iapCoins1500ProductId {
    return dotenv.env['IAP_COINS_1500_ID'] ?? 'coins_1500';
  }

  static String get iapCoins5000ProductId {
    return dotenv.env['IAP_COINS_5000_ID'] ?? 'coins_5000';
  }

  static String get iapVipProductId {
    return dotenv.env['IAP_VIP_ID'] ?? 'lifetime_vip';
  }

  // ==================== VALIDATION ====================
  
  /// Check if Gemini is properly configured
  static bool get isGeminiConfigured {
    return geminiApiKey.isNotEmpty;
  }

  /// Check if Firebase is properly configured
  static bool get isFirebaseConfigured {
    return firebaseApiKey.isNotEmpty && firebaseProjectId.isNotEmpty;
  }

  /// Check if AdMob is properly configured
  static bool get isAdMobConfigured {
    return (androidBannerAdId.isNotEmpty && androidBannerAdId.contains('ca-app-pub')) ||
           (iosBannerAdId.isNotEmpty && iosBannerAdId.contains('ca-app-pub'));
  }

  /// Check if all required services are configured
  static bool get isFullyConfigured {
    return isFirebaseConfigured && isAdMobConfigured;
  }

  // ==================== HELPERS ====================
  
  /// Get environment variable with default value
  static String getEnv(String key, {String defaultValue = ''}) {
    return dotenv.env[key] ?? defaultValue;
  }

  /// Get boolean environment variable
  static bool getBool(String key, {bool defaultValue = false}) {
    final value = dotenv.env[key]?.toLowerCase();
    if (value == null) return defaultValue;
    return value == 'true' || value == '1' || value == 'yes';
  }

  /// Get integer environment variable
  static int getInt(String key, {int defaultValue = 0}) {
    final value = dotenv.env[key];
    if (value == null) return defaultValue;
    return int.tryParse(value) ?? defaultValue;
  }

  /// Get double environment variable
  static double getDouble(String key, {double defaultValue = 0.0}) {
    final value = dotenv.env[key];
    if (value == null) return defaultValue;
    return double.tryParse(value) ?? defaultValue;
  }

  // ==================== DEBUG INFO ====================
  
  /// Print configuration summary (for debugging)
  static void printConfig() {
    if (!debugMode) return;

    print('========================================');
    print('ENVIRONMENT CONFIGURATION');
    print('========================================');
    print('Environment: $environment');
    print('App Name: $appName');
    print('Version: $appVersion ($buildNumber)');
    print('----------------------------------------');
    print('Gemini AI: ${isGeminiConfigured ? "✅" : "❌"}');
    print('Firebase: ${isFirebaseConfigured ? "✅" : "❌"}');
    print('AdMob: ${isAdMobConfigured ? "✅" : "❌"}');
    print('----------------------------------------');
    print('Voice Recognition: ${enableVoiceRecognition ? "✅" : "❌"}');
    print('Multiplayer: ${enableMultiplayer ? "✅" : "❌"}');
    print('AI Features: ${enableAI ? "✅" : "❌"}');
    print('Location: ${enableLocation ? "✅" : "❌"}');
    print('Analytics: ${enableAnalytics ? "✅" : "❌"}');
    print('----------------------------------------');
    print('Test Ads: ${useTestAds ? "✅" : "❌"}');
    print('Debug Mode: ${debugMode ? "✅" : "❌"}');
    print('========================================');
  }

  /// Get configuration as map
  static Map<String, dynamic> toMap() {
    return {
      'app_name': appName,
      'app_version': appVersion,
      'build_number': buildNumber,
      'environment': environment,
      'gemini_configured': isGeminiConfigured,
      'firebase_configured': isFirebaseConfigured,
      'admob_configured': isAdMobConfigured,
      'fully_configured': isFullyConfigured,
      'features': {
        'voice_recognition': enableVoiceRecognition,
        'multiplayer': enableMultiplayer,
        'ai': enableAI,
        'location': enableLocation,
        'analytics': enableAnalytics,
        'crash_reporting': enableCrashReporting,
      },
      'debug': {
        'debug_mode': debugMode,
        'test_ads': useTestAds,
      },
    };
  }

  /// Validate configuration
  static List<String> validate() {
    final errors = <String>[];

    // Check required configurations
    if (!isFirebaseConfigured) {
      errors.add('Firebase is not properly configured');
    }

    if (enableAI && !isGeminiConfigured) {
      errors.add('AI is enabled but Gemini API key is missing');
    }

    if (!isAdMobConfigured && !useTestAds) {
      errors.add('AdMob is not configured and test ads are disabled');
    }

    return errors;
  }

  /// Check if configuration has errors
  static bool get hasErrors {
    return validate().isNotEmpty;
  }

  // ==================== GETTERS ====================
  
  static bool get isLoaded => _isLoaded;
  static bool get isDevelopment => environment == 'development' || environment == 'dev';
  static bool get isStaging => environment == 'staging';
  static bool get isProduction => environment == 'production' || environment == 'prod';
}