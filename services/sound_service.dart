// lib/services/sound_service.dart
// COMPLETE SOUND SERVICE - NO ERRORS
// Handles missing assets gracefully

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isMuted = false;
  bool _isInitialized = false;
  
  // Sound files status
  final Map<String, bool> _soundsExist = {};
  
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      await _audioPlayer.setReleaseMode(ReleaseMode.stop);
      
      // Check which sound files exist
      await _checkSoundFiles();
      
      _isInitialized = true;
      debugPrint('✅ Sound service initialized');
      debugPrint('📊 Available sounds: ${_soundsExist.entries.where((e) => e.value).length}/${_soundsExist.length}');
    } catch (e) {
      debugPrint('❌ Error initializing sound service: $e');
    }
  }
  
  Future<void> _checkSoundFiles() async {
    final sounds = [
      'button_click',
      'correct',
      'wrong',
      'timer_tick',
      'game_over',
      'coin',
      'streak',
      'powerup',
    ];
    
    for (final sound in sounds) {
      try {
        // Try to load the asset
        final path = 'assets/sounds/$sound.mp3';
        await _audioPlayer.setSource(AssetSource('sounds/$sound.mp3'));
        _soundsExist[sound] = true;
        debugPrint('✅ Sound found: $sound.mp3');
      } catch (e) {
        _soundsExist[sound] = false;
        debugPrint('❌ Sound missing: $sound.mp3');
      }
    }
  }
  
  Future<void> playSound(String soundName) async {
    if (!_isInitialized) {
      await initialize();
    }
    
    if (_isMuted) {
      debugPrint('🔇 Sound muted: $soundName');
      return;
    }
    
    // Check if sound exists
    if (_soundsExist[soundName] == false) {
      debugPrint('⚠️ Sound not available: $soundName.mp3');
      return;
    }
    
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('sounds/$soundName.mp3'));
      debugPrint('🔊 Playing sound: $soundName.mp3');
    } catch (e) {
      debugPrint('❌ Error playing sound $soundName: $e');
    }
  }
  
  // Individual sound methods
  Future<void> playButtonClick() async => await playSound('button_click');
  Future<void> playCorrect() async => await playSound('correct');
  Future<void> playWrong() async => await playSound('wrong');
  Future<void> playTimerTick() async => await playSound('timer_tick');
  Future<void> playGameOver() async => await playSound('game_over');
  Future<void> playCoin() async => await playSound('coin');
  Future<void> playStreak() async => await playSound('streak');
  Future<void> playPowerup() async => await playSound('powerup');
  
  void setMuted(bool muted) {
    _isMuted = muted;
    debugPrint('🔊 Sound ${muted ? "muted" : "unmuted"}');
  }
  
  bool get isMuted => _isMuted;
  
  Map<String, bool> get availableSounds => Map.from(_soundsExist);
  
  Future<void> dispose() async {
    await _audioPlayer.dispose();
    debugPrint('✅ Sound service disposed');
  }
}