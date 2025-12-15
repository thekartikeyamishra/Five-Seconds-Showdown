// lib/core/utils/sound_manager.dart
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SoundManager {
  static final SoundManager _instance = SoundManager._internal();
  factory SoundManager() => _instance;
  SoundManager._internal();

  // Audio players
  final AudioPlayer _sfxPlayer = AudioPlayer();
  final AudioPlayer _musicPlayer = AudioPlayer();

  // Settings
  bool _soundEnabled = true;
  bool _musicEnabled = true;
  bool _vibrationEnabled = true;
  double _soundVolume = 1.0;
  double _musicVolume = 0.5;

  // Initialization flag
  bool _isInitialized = false;

  // Sound asset paths
  static const String _buttonClickSound = 'sounds/button_click.mp3';
  static const String _correctSound = 'sounds/correct.mp3';
  static const String _wrongSound = 'sounds/wrong.mp3';
  static const String _coinSound = 'sounds/coin.mp3';
  static const String _winSound = 'sounds/win.mp3';
  static const String _gameOverSound = 'sounds/game_over.mp3';
  static const String _timerTickSound = 'sounds/timer_tick.mp3';
  static const String _backgroundMusic = 'sounds/background_music.mp3';

  // Preference keys
  static const String _keySoundEnabled = 'sound_enabled';
  static const String _keyMusicEnabled = 'music_enabled';
  static const String _keyVibrationEnabled = 'vibration_enabled';
  static const String _keySoundVolume = 'sound_volume';
  static const String _keyMusicVolume = 'music_volume';

  // Initialize sound manager
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Load saved preferences
      await _loadPreferences();

      // Set audio modes
      await _sfxPlayer.setReleaseMode(ReleaseMode.stop);
      await _musicPlayer.setReleaseMode(ReleaseMode.loop);

      // Set initial volumes
      await _sfxPlayer.setVolume(_soundVolume);
      await _musicPlayer.setVolume(_musicVolume);

      _isInitialized = true;
    } catch (e) {
      print('Error initializing sound manager: $e');
      _isInitialized = false;
    }
  }

  // Load preferences from storage
  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _soundEnabled = prefs.getBool(_keySoundEnabled) ?? true;
      _musicEnabled = prefs.getBool(_keyMusicEnabled) ?? true;
      _vibrationEnabled = prefs.getBool(_keyVibrationEnabled) ?? true;
      _soundVolume = prefs.getDouble(_keySoundVolume) ?? 1.0;
      _musicVolume = prefs.getDouble(_keyMusicVolume) ?? 0.5;
    } catch (e) {
      print('Error loading sound preferences: $e');
    }
  }

  // Save preferences to storage
  Future<void> _savePreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keySoundEnabled, _soundEnabled);
      await prefs.setBool(_keyMusicEnabled, _musicEnabled);
      await prefs.setBool(_keyVibrationEnabled, _vibrationEnabled);
      await prefs.setDouble(_keySoundVolume, _soundVolume);
      await prefs.setDouble(_keyMusicVolume, _musicVolume);
    } catch (e) {
      print('Error saving sound preferences: $e');
    }
  }

  // Play sound effect
  Future<void> _playSound(String assetPath) async {
    if (!_soundEnabled) return;
    
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.play(AssetSource(assetPath));
    } catch (e) {
      print('Error playing sound $assetPath: $e');
    }
  }

  // Button click sound
  Future<void> playButtonClick() async {
    await _playSound(_buttonClickSound);
  }

  // Correct answer sound
  Future<void> playCorrect() async {
    await _playSound(_correctSound);
  }

  // Wrong answer sound
  Future<void> playWrong() async {
    await _playSound(_wrongSound);
  }

  // Coin collection sound
  Future<void> playCoin() async {
    await _playSound(_coinSound);
  }

  // Win sound
  Future<void> playWin() async {
    await _playSound(_winSound);
  }

  // Game over sound
  Future<void> playGameOver() async {
    await _playSound(_gameOverSound);
  }

  // Timer tick sound
  Future<void> playTimerTick() async {
    await _playSound(_timerTickSound);
  }

  // Start background music
  Future<void> startBackgroundMusic() async {
    if (!_musicEnabled) return;

    try {
      await _musicPlayer.play(AssetSource(_backgroundMusic));
    } catch (e) {
      print('Error playing background music: $e');
    }
  }

  // Stop background music
  Future<void> stopBackgroundMusic() async {
    try {
      await _musicPlayer.stop();
    } catch (e) {
      print('Error stopping background music: $e');
    }
  }

  // Pause background music
  Future<void> pauseBackgroundMusic() async {
    try {
      await _musicPlayer.pause();
    } catch (e) {
      print('Error pausing background music: $e');
    }
  }

  // Resume background music
  Future<void> resumeBackgroundMusic() async {
    if (!_musicEnabled) return;

    try {
      await _musicPlayer.resume();
    } catch (e) {
      print('Error resuming background music: $e');
    }
  }

  // Vibrate device
  Future<void> vibrate({int duration = 50}) async {
    if (!_vibrationEnabled) return;

    try {
      // Check if device has vibration capability
      final hasVibrator = await Vibration.hasVibrator() ?? false;
      if (hasVibrator) {
        await Vibration.vibrate(duration: duration);
      }
    } catch (e) {
      print('Error vibrating: $e');
    }
  }

  // Heavy vibration (for errors, wrong answers)
  Future<void> vibrateHeavy() async {
    if (!_vibrationEnabled) return;

    try {
      final hasVibrator = await Vibration.hasVibrator() ?? false;
      if (hasVibrator) {
        final hasCustomVibration = await Vibration.hasCustomVibrationsSupport() ?? false;
        if (hasCustomVibration) {
          // Pattern: vibrate, pause, vibrate
          await Vibration.vibrate(pattern: [0, 100, 50, 100]);
        } else {
          await Vibration.vibrate(duration: 200);
        }
      }
    } catch (e) {
      print('Error vibrating: $e');
    }
  }

  // Light vibration (for button taps, correct answers)
  Future<void> vibrateLight() async {
    if (!_vibrationEnabled) return;

    try {
      final hasVibrator = await Vibration.hasVibrator() ?? false;
      if (hasVibrator) {
        await Vibration.vibrate(duration: 30);
      }
    } catch (e) {
      print('Error vibrating: $e');
    }
  }

  // Success vibration pattern
  Future<void> vibrateSuccess() async {
    if (!_vibrationEnabled) return;

    try {
      final hasVibrator = await Vibration.hasVibrator() ?? false;
      if (hasVibrator) {
        final hasCustomVibration = await Vibration.hasCustomVibrationsSupport() ?? false;
        if (hasCustomVibration) {
          // Pattern: short, short, long
          await Vibration.vibrate(pattern: [0, 50, 30, 50, 30, 150]);
        } else {
          await Vibration.vibrate(duration: 100);
        }
      }
    } catch (e) {
      print('Error vibrating: $e');
    }
  }

  // Toggle sound on/off
  Future<void> toggleSound() async {
    _soundEnabled = !_soundEnabled;
    await _savePreferences();
    
    if (!_soundEnabled) {
      await _sfxPlayer.stop();
    }
  }

  // Toggle music on/off
  Future<void> toggleMusic() async {
    _musicEnabled = !_musicEnabled;
    await _savePreferences();
    
    if (_musicEnabled) {
      await startBackgroundMusic();
    } else {
      await stopBackgroundMusic();
    }
  }

  // Toggle vibration on/off
  Future<void> toggleVibration() async {
    _vibrationEnabled = !_vibrationEnabled;
    await _savePreferences();
  }

  // Set sound volume
  Future<void> setSoundVolume(double volume) async {
    _soundVolume = volume.clamp(0.0, 1.0);
    await _sfxPlayer.setVolume(_soundVolume);
    await _savePreferences();
  }

  // Set music volume
  Future<void> setMusicVolume(double volume) async {
    _musicVolume = volume.clamp(0.0, 1.0);
    await _musicPlayer.setVolume(_musicVolume);
    await _savePreferences();
  }

  // Getters
  bool get isSoundEnabled => _soundEnabled;
  bool get isMusicEnabled => _musicEnabled;
  bool get isVibrationEnabled => _vibrationEnabled;
  double get soundVolume => _soundVolume;
  double get musicVolume => _musicVolume;
  bool get isInitialized => _isInitialized;

  // Dispose
  Future<void> dispose() async {
    await _sfxPlayer.dispose();
    await _musicPlayer.dispose();
  }
}