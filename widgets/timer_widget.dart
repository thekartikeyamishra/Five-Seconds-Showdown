// lib/widgets/timer_widget.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme/app_colors.dart';
import '../utils/sound_manager.dart';

class TimerWidget extends StatefulWidget {
  final int duration;
  final VoidCallback onComplete;
  final ValueChanged<int>? onTick;

  const TimerWidget({
    Key? key,
    required this.duration,
    required this.onComplete,
    this.onTick,
  }) : super(key: key);

  @override
  State<TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget>
    with SingleTickerProviderStateMixin {
  late int _timeLeft;
  Timer? _timer;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _timeLeft = widget.duration;
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
          
          // Pulse animation
          _pulseController.forward().then((_) => _pulseController.reverse());
          
          // Sound effects based on time left
          if (_timeLeft <= 2) {
            SoundManager().playTimerTick();
            SoundManager().vibrateLight();
          }
          
          // Callback
          widget.onTick?.call(_timeLeft);
          
        } else {
          timer.cancel();
          SoundManager().playGameOver();
          SoundManager().vibrateHeavy();
          widget.onComplete();
        }
      });
    });
  }

  Color _getTimerColor() {
    if (_timeLeft <= 1) return AppColors.timerDanger;
    if (_timeLeft <= 2) return AppColors.timerWarning;
    return AppColors.timerSafe;
  }

  List<Color> _getGradient() {
    if (_timeLeft <= 1) return AppColors.gradientFire;
    if (_timeLeft <= 2) return AppColors.gradientSunset;
    return AppColors.gradientPurple;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween<double>(begin: 1.0, end: 1.1).animate(
        CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
      ),
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: _getGradient(),
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: _getTimerColor().withOpacity(0.4),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$_timeLeft',
                style: const TextStyle(
                  fontSize: 80,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  height: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _timeLeft == 1 ? 'second' : 'seconds',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CircularTimerPainter extends CustomPainter {
  final int timeLeft;
  final int duration;
  final Color color;

  CircularTimerPainter({
    required this.timeLeft,
    required this.duration,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final progress = timeLeft / duration;

    // Background circle
    final bgPaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;
    canvas.drawCircle(center, radius, bgPaint);

    // Progress circle
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14159 / 2,
      2 * 3.14159 * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}