// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'core/services/ad_service.dart';
import 'core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0F172A),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize Firebase
  try {
    await Firebase.initializeApp();
    print('✅ Firebase initialized');
  } catch (e) {
    print('❌ Firebase initialization error: $e');
  }

  // Initialize Hive (Local Storage)
  await Hive.initFlutter();
  await Hive.openBox('gameData');
  print('✅ Hive initialized');

  // Initialize Ad Service
  await AdService.initialize();
  print('✅ Ad Service initialized');

  // Initialize Notification Service
  try {
    await NotificationService().initialize();
    print('✅ Notification Service initialized');
  } catch (e) {
    print('❌ Notification Service error: $e');
  }

  // Load Ads
  AdService().loadRewardedAd();
  AdService().loadInterstitialAd();
  print('✅ Ads loading...');

  runApp(const FiveSecondsShowdownApp());
}