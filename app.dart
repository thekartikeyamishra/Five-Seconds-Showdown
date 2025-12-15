// lib/app.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/game_screen.dart';
import 'screens/result_screen.dart';

class FiveSecondsShowdownApp extends StatelessWidget {
  const FiveSecondsShowdownApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: '5 Seconds Showdown',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      
      // Initial Route
      initialRoute: '/',
      
      // Routes
      getPages: [
        GetPage(
          name: '/',
          page: () => const SplashScreen(),
          transition: Transition.fade,
        ),
        GetPage(
          name: '/home',
          page: () => const HomeScreen(),
          transition: Transition.fadeIn,
        ),
        GetPage(
          name: '/game',
          page: () => const GameScreen(),
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: '/result',
          page: () => const ResultScreen(),
          transition: Transition.zoom,
        ),
      ],
    );
  }
}