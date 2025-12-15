// lib/services/voice_recognition_service.dart
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VoiceRecognitionService {
  static final VoiceRecognitionService _instance = VoiceRecognitionService._internal();
  factory VoiceRecognitionService() => _instance;
  VoiceRecognitionService._internal();

  late stt.SpeechToText _speech;
  bool _isInitialized = false;
  bool _isListening = false;
  String _lastRecognizedText = '';
  List<String> _recognizedWords = [];
  double _confidenceLevel = 0.0;

  // Settings
  bool _continuousListening = false;
  Duration _listenDuration = const Duration(seconds: 5);
  Duration _pauseDuration = const Duration(seconds: 3);

  // Cache keys
  static const String _keyVoiceEnabled = 'voice_enabled';
  static const String _keyLastUsed = 'voice_last_used';
  static const String _keyUsageCount = 'voice_usage_count';

  // Statistics
  int _totalRecognitions = 0;
  int _successfulRecognitions = 0;
  int _failedRecognitions = 0;

  // Initialize voice recognition
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      _speech = stt.SpeechToText();
      _isInitialized = await _speech.initialize(
        onError: (error) {
          print('Voice recognition error: ${error.errorMsg}');
          _handleError(error.errorMsg);
        },
        onStatus: (status) {
          print('Voice recognition status: $status');
          _handleStatus(status);
        },
      );

      if (_isInitialized) {
        await _loadPreferences();
        await _incrementUsageCount();
      }

      return _isInitialized;
    } catch (e) {
      print('Failed to initialize voice recognition: $e');
      return false;
    }
  }

  // Request microphone permission
  Future<bool> requestPermission() async {
    try {
      final status = await Permission.microphone.request();
      return status.isGranted;
    } catch (e) {
      print('Error requesting microphone permission: $e');
      return false;
    }
  }

  // Check permission status
  Future<bool> hasPermission() async {
    try {
      final status = await Permission.microphone.status;
      return status.isGranted;
    } catch (e) {
      print('Error checking microphone permission: $e');
      return false;
    }
  }

  // Open app settings for permission
  Future<void> openSettings() async {
    try {
      await openAppSettings();
    } catch (e) {
      print('Error opening app settings: $e');
    }
  }

  // Start listening with callbacks
  Future<void> startListening({
    required Function(String) onResult,
    required Function(String) onError,
    Duration? listenFor,
    Duration? pauseFor,
    bool continuous = false,
  }) async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) {
        onError('Voice recognition not available');
        return;
      }
    }

    if (_isListening) {
      print('Already listening');
      return;
    }

    // Check permission
    final hasPermission = await this.hasPermission();
    if (!hasPermission) {
      final granted = await requestPermission();
      if (!granted) {
        onError('Microphone permission denied');
        return;
      }
    }

    try {
      _isListening = true;
      _continuousListening = continuous;
      _listenDuration = listenFor ?? _listenDuration;
      _pauseDuration = pauseFor ?? _pauseDuration;

      await _speech.listen(
        onResult: (result) {
          _lastRecognizedText = result.recognizedWords;
          _confidenceLevel = result.confidence;
          _recognizedWords = result.recognizedWords.split(' ');

          print('Recognized: $_lastRecognizedText (confidence: $_confidenceLevel)');

          // Call result callback when final
          if (result.finalResult) {
            _totalRecognitions++;
            if (_lastRecognizedText.isNotEmpty) {
              _successfulRecognitions++;
              onResult(_lastRecognizedText);
            } else {
              _failedRecognitions++;
              onError('No speech detected');
            }
            
            // Stop listening after final result (unless continuous)
            if (!_continuousListening) {
              stopListening();
            }
          }
        },
        listenFor: _listenDuration,
        pauseFor: _pauseDuration,
        partialResults: true,
        cancelOnError: true,
        listenMode: stt.ListenMode.confirmation,
        localeId: 'en_US',
      );

      // Track usage
      await _saveLastUsed();
    } catch (e) {
      _isListening = false;
      _failedRecognitions++;
      onError('Failed to start listening: $e');
    }
  }

  // Stop listening
  Future<void> stopListening() async {
    if (_isListening) {
      try {
        await _speech.stop();
        _isListening = false;
      } catch (e) {
        print('Error stopping voice recognition: $e');
      }
    }
  }

  // Cancel listening
  Future<void> cancelListening() async {
    if (_isListening) {
      try {
        await _speech.cancel();
        _isListening = false;
        _lastRecognizedText = '';
        _recognizedWords = [];
      } catch (e) {
        print('Error canceling voice recognition: $e');
      }
    }
  }

  // Check if answer is valid (contains required count of items)
  bool checkAnswer({
    required String voiceAnswer,
    required String question,
    required int requiredCount,
  }) {
    if (voiceAnswer.isEmpty) return false;

    // Convert to lowercase for comparison
    final answer = voiceAnswer.toLowerCase().trim();
    
    // Count separators
    int itemCount = 1; // Start with 1 (first item)
    
    // Count commas
    itemCount += ','.allMatches(answer).length;
    
    // Count "and" (but not as part of words)
    final andPattern = RegExp(r'\s+and\s+', caseSensitive: false);
    itemCount += andPattern.allMatches(answer).length;
    
    // Check if we have enough items
    if (itemCount >= requiredCount) {
      return true;
    }
    
    // Alternative: check word count (each item ~2-4 words)
    final words = answer.split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty && w.length > 1)
        .toList();
    
    if (words.length >= requiredCount * 2) {
      return true;
    }
    
    return false;
  }

  // Parse voice answer into list of items
  List<String> parseAnswer(String voiceAnswer) {
    if (voiceAnswer.isEmpty) return [];

    final answer = voiceAnswer.toLowerCase().trim();
    final items = <String>[];
    
    // Split by common separators
    String cleanedAnswer = answer;
    
    // Replace "and" with commas
    cleanedAnswer = cleanedAnswer.replaceAll(RegExp(r'\s+and\s+'), ',');
    
    // Split by commas
    if (cleanedAnswer.contains(',')) {
      items.addAll(
        cleanedAnswer
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty),
      );
    } else {
      // If no commas, try to split by spaces (groups of 2-3 words)
      final words = cleanedAnswer.split(RegExp(r'\s+'));
      
      if (words.length <= 3) {
        // Short answer, treat as single items
        items.addAll(words);
      } else {
        // Group words into items (every 2-3 words)
        int i = 0;
        while (i < words.length) {
          final take = (i + 3 <= words.length) ? 3 : (words.length - i);
          final item = words.sublist(i, i + take).join(' ');
          items.add(item);
          i += take;
        }
      }
    }
    
    // Clean up items
    return items
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty && item.length > 1)
        .toList();
  }

  // Validate parsed items
  bool validateItems(List<String> items, int requiredCount) {
    if (items.length < requiredCount) return false;
    
    // Check for duplicates
    final uniqueItems = items.toSet();
    if (uniqueItems.length < requiredCount) return false;
    
    // Check for meaningful content (not just filler words)
    final fillerWords = ['um', 'uh', 'like', 'you know', 'well', 'so'];
    final meaningfulItems = items.where((item) {
      return !fillerWords.any((filler) => item.toLowerCase().contains(filler));
    }).toList();
    
    return meaningfulItems.length >= requiredCount;
  }

  // Get available locales
  Future<List<stt.LocaleName>> getAvailableLocales() async {
    if (!_isInitialized) {
      await initialize();
    }
    
    try {
      return await _speech.locales();
    } catch (e) {
      print('Error getting locales: $e');
      return [];
    }
  }

  // Handle error messages
  void _handleError(String errorMsg) {
    print('Voice error: $errorMsg');
    _failedRecognitions++;
    
    if (errorMsg.contains('network')) {
      print('Network error - check internet connection');
    } else if (errorMsg.contains('permission')) {
      print('Permission error - check microphone access');
    } else if (errorMsg.contains('not available')) {
      print('Service not available on this device');
    }
  }

  // Handle status changes
  void _handleStatus(String status) {
    if (status == 'done') {
      _isListening = false;
    } else if (status == 'listening') {
      _isListening = true;
    } else if (status == 'notListening') {
      _isListening = false;
    }
  }

  // Load preferences
  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastUsed = prefs.getString(_keyLastUsed);
      final usageCount = prefs.getInt(_keyUsageCount) ?? 0;
      
      print('Voice recognition - Last used: $lastUsed, Usage count: $usageCount');
    } catch (e) {
      print('Error loading voice preferences: $e');
    }
  }

  // Save last used timestamp
  Future<void> _saveLastUsed() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyLastUsed, DateTime.now().toIso8601String());
    } catch (e) {
      print('Error saving last used: $e');
    }
  }

  // Increment usage count
  Future<void> _incrementUsageCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final count = prefs.getInt(_keyUsageCount) ?? 0;
      await prefs.setInt(_keyUsageCount, count + 1);
    } catch (e) {
      print('Error incrementing usage count: $e');
    }
  }

  // Get statistics
  Map<String, dynamic> getStatistics() {
    return {
      'total_recognitions': _totalRecognitions,
      'successful': _successfulRecognitions,
      'failed': _failedRecognitions,
      'success_rate': _totalRecognitions > 0
          ? (_successfulRecognitions / _totalRecognitions * 100).toStringAsFixed(1)
          : '0.0',
      'last_confidence': _confidenceLevel,
      'is_listening': _isListening,
    };
  }

  // Test microphone
  Future<bool> testMicrophone() async {
    try {
      if (!_isInitialized) {
        await initialize();
      }
      
      final hasPermission = await this.hasPermission();
      if (!hasPermission) {
        return false;
      }
      
      return _speech.isAvailable;
    } catch (e) {
      print('Error testing microphone: $e');
      return false;
    }
  }

  // Get supported languages
  Future<List<String>> getSupportedLanguages() async {
    try {
      final locales = await getAvailableLocales();
      return locales.map((locale) => locale.name).toList();
    } catch (e) {
      print('Error getting supported languages: $e');
      return ['English (US)'];
    }
  }

  // Reset statistics
  void resetStatistics() {
    _totalRecognitions = 0;
    _successfulRecognitions = 0;
    _failedRecognitions = 0;
  }

  // Getters
  bool get isListening => _isListening;
  bool get isInitialized => _isInitialized;
  bool get isAvailable => _speech.isAvailable;
  String get lastRecognizedText => _lastRecognizedText;
  List<String> get recognizedWords => _recognizedWords;
  double get confidenceLevel => _confidenceLevel;
  int get totalRecognitions => _totalRecognitions;
  int get successfulRecognitions => _successfulRecognitions;
  int get failedRecognitions => _failedRecognitions;
  
  // Calculate success rate
  double get successRate {
    if (_totalRecognitions == 0) return 0.0;
    return (_successfulRecognitions / _totalRecognitions) * 100;
  }

  // Dispose
  void dispose() {
    stopListening();
  }
}