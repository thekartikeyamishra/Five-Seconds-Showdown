// lib/services/accessibility_service.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccessibilityService extends ChangeNotifier {
  static final AccessibilityService _instance = AccessibilityService._internal();
  factory AccessibilityService() => _instance;
  AccessibilityService._internal();

  // State Variables
  bool _screenReaderEnabled = false;
  bool _highContrastEnabled = false;
  bool _visualHapticsEnabled = true; // Flashing for deaf/hard of hearing users
  double _textScaleFactor = 1.0;

  // Keys for SharedPreferences
  static const String _keyScreenReader = 'acc_screen_reader';
  static const String _keyHighContrast = 'acc_high_contrast';
  static const String _keyVisualHaptics = 'acc_visual_haptics';
  static const String _keyTextScale = 'acc_text_scale';

  // Getters
  bool get isScreenReaderEnabled => _screenReaderEnabled;
  bool get isHighContrastEnabled => _highContrastEnabled;
  bool get visualHapticsEnabled => _visualHapticsEnabled;
  double get textScaleFactor => _textScaleFactor;

  /// Initialize and load saved settings
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _screenReaderEnabled = prefs.getBool(_keyScreenReader) ?? false;
      _highContrastEnabled = prefs.getBool(_keyHighContrast) ?? false;
      _visualHapticsEnabled = prefs.getBool(_keyVisualHaptics) ?? true;
      _textScaleFactor = prefs.getDouble(_keyTextScale) ?? 1.0;
      notifyListeners();
    } catch (e) {
      print('Error loading accessibility settings: $e');
    }
  }

  // ==================== SETTINGS TOGGLES ====================

  /// Toggle Screen Reader optimization (e.g., auto-speak questions)
  Future<void> toggleScreenReader(bool value) async {
    _screenReaderEnabled = value;
    await _saveBool(_keyScreenReader, value);
    notifyListeners();
  }

  /// Toggle High Contrast Mode (e.g., Black/White UI)
  Future<void> toggleHighContrast(bool value) async {
    _highContrastEnabled = value;
    await _saveBool(_keyHighContrast, value);
    notifyListeners();
  }

  /// Toggle Visual Haptics (e.g., Screen flash on wrong answer)
  Future<void> toggleVisualHaptics(bool value) async {
    _visualHapticsEnabled = value;
    await _saveBool(_keyVisualHaptics, value);
    notifyListeners();
  }

  /// Set Text Scale Factor
  Future<void> setTextScale(double value) async {
    _textScaleFactor = value.clamp(0.5, 3.0); // Safe limits
    await _saveDouble(_keyTextScale, _textScaleFactor);
    notifyListeners();
  }

  // ==================== HELPER METHODS FOR UI ====================

  /// Get color adapted for High Contrast Mode
  /// [normalColor] - The color used in standard mode
  /// [isBackground] - If true, returns Black/White. If false (text/icon), returns White/Black.
  Color getAdaptiveColor(Color normalColor, {bool isBackground = false}) {
    if (!_highContrastEnabled) return normalColor;

    // High Contrast Logic:
    // Backgrounds become strictly Black or White based on original brightness
    // Foreground elements become the opposite for maximum readability.
    if (isBackground) {
      return normalColor.computeLuminance() > 0.5 ? Colors.white : Colors.black;
    } else {
      // For text/icons, check luminance of the *original* color to decide contrast
      // Or simply return White for dark backgrounds and Black for light ones.
      // Assuming app is Dark Mode by default (based on your theme):
      return Colors.yellowAccent; // High visibility on dark backgrounds
    }
  }

  /// Get TextStyle adapted for accessibility (Scale + Contrast)
  TextStyle getAdaptiveTextStyle(TextStyle original) {
    var style = original.copyWith(
      fontSize: (original.fontSize ?? 14) * _textScaleFactor,
    );

    if (_highContrastEnabled) {
      style = style.copyWith(
        color: getAdaptiveColor(original.color ?? Colors.white),
        fontWeight: FontWeight.bold, // Bold is often easier to read
      );
    }

    return style;
  }

  /// Get semantics label for buttons
  /// If Screen Reader is on, provides more descriptive text.
  String getSemanticsLabel(String basicLabel, String? extendedDescription) {
    if (_screenReaderEnabled && extendedDescription != null) {
      return "$basicLabel. $extendedDescription";
    }
    return basicLabel;
  }

  // ==================== INTERNAL HELPERS ====================

  Future<void> _saveBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> _saveDouble(String key, double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(key, value);
  }
}