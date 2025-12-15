// lib/widgets/animated_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme/app_colors.dart';

class AnimatedCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final List<Color>? gradient;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Duration? delay;

  const AnimatedCard({
    Key? key,
    required this.child,
    this.onTap,
    this.gradient,
    this.padding,
    this.margin,
    this.delay,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        gradient: gradient != null
            ? LinearGradient(
                colors: gradient!,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: gradient == null ? AppColors.card : null,
        borderRadius: BorderRadius.circular(16),
        border: gradient == null
            ? Border.all(color: AppColors.border, width: 1)
            : null,
        boxShadow: [
          BoxShadow(
            color: (gradient?.first ?? Colors.black).withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(20),
            child: child,
          ),
        ),
      ),
    )
        .animate(delay: delay ?? Duration.zero)
        .fadeIn(duration: 300.ms, curve: Curves.easeOut)
        .slideY(begin: 0.2, end: 0, duration: 300.ms, curve: Curves.easeOut)
        .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1));
  }
}

class GameModeCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String description;
  final List<Color> gradient;
  final VoidCallback onTap;
  final Duration? delay;

  const GameModeCard({
    Key? key,
    required this.emoji,
    required this.title,
    required this.description,
    required this.gradient,
    required this.onTap,
    this.delay,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedCard(
      gradient: gradient,
      onTap: onTap,
      delay: delay,
      child: Row(
        children: [
          // Emoji Icon
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 32),
              ),
            ),
          ),
          const SizedBox(width: 16),
          
          // Text Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          
          // Arrow Icon
          const Icon(
            Icons.arrow_forward_ios,
            color: Colors.white,
            size: 20,
          ),
        ],
      ),
    );
  }
}