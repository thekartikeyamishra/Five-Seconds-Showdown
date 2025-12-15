// lib/widgets/voice_input_button.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme/app_colors.dart';
import '../utils/sound_manager.dart';

class VoiceInputButton extends StatefulWidget {
  final bool isListening;
  final VoidCallback onPressed;
  final double size;
  final bool enabled;
  final String? tooltip;

  const VoiceInputButton({
    Key? key,
    required this.isListening,
    required this.onPressed,
    this.size = 64,
    this.enabled = true,
    this.tooltip,
  }) : super(key: key);

  @override
  State<VoiceInputButton> createState() => _VoiceInputButtonState();
}

class _VoiceInputButtonState extends State<VoiceInputButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _initializePulseAnimation();
  }

  void _initializePulseAnimation() {
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    // Start pulse animation if listening
    if (widget.isListening) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(VoiceInputButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Handle listening state changes
    if (widget.isListening != oldWidget.isListening) {
      if (widget.isListening) {
        _pulseController.repeat(reverse: true);
      } else {
        _pulseController.stop();
        _pulseController.reset();
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (!widget.enabled || widget.isListening) return;
    setState(() => _isPressed = true);
  }

  void _handleTapUp(TapUpDetails details) {
    if (!widget.enabled) return;
    setState(() => _isPressed = false);
  }

  void _handleTapCancel() {
    if (!widget.enabled) return;
    setState(() => _isPressed = false);
  }

  Future<void> _handleTap() async {
    if (!widget.enabled) return;
    
    // Play button click sound
    await SoundManager().playButtonClick();
    
    // Vibrate
    await SoundManager().vibrateLight();
    
    // Call the onPressed callback
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    final button = GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: _handleTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                // Outer glow ring (visible when listening)
                if (widget.isListening)
                  Container(
                    width: widget.size * _pulseAnimation.value,
                    height: widget.size * _pulseAnimation.value,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.primary.withOpacity(0.3),
                          AppColors.primary.withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                
                // Main button
                Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: widget.enabled
                          ? (widget.isListening
                              ? AppColors.gradientForest
                              : AppColors.gradientPurple)
                          : [Colors.grey, Colors.grey.shade700],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: widget.enabled
                            ? (widget.isListening
                                ? AppColors.success
                                : AppColors.primary)
                                .withOpacity(0.5)
                            : Colors.transparent,
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: _buildIcon(),
                  ),
                ),
                
                // Listening indicator dots
                if (widget.isListening) _buildListeningIndicator(),
              ],
            );
          },
        ),
      ),
    );

    if (widget.tooltip != null) {
      return Tooltip(
        message: widget.tooltip!,
        child: button,
      );
    }

    return button;
  }

  Widget _buildIcon() {
    if (widget.isListening) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.mic,
            color: Colors.white,
            size: widget.size * 0.4,
          )
              .animate(onPlay: (controller) => controller.repeat())
              .scale(
                duration: 500.ms,
                begin: const Offset(1, 1),
                end: const Offset(1.1, 1.1),
              )
              .then()
              .scale(
                duration: 500.ms,
                begin: const Offset(1.1, 1.1),
                end: const Offset(1, 1),
              ),
          const SizedBox(height: 4),
          Text(
            'Listening...',
            style: TextStyle(
              color: Colors.white,
              fontSize: widget.size * 0.12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    return Icon(
      Icons.mic,
      color: Colors.white,
      size: widget.size * 0.5,
    );
  }

  Widget _buildListeningIndicator() {
    return Positioned(
      bottom: 0,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          3,
          (index) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          )
              .animate(onPlay: (controller) => controller.repeat())
              .fadeIn(
                duration: 600.ms,
                delay: Duration(milliseconds: index * 200),
              )
              .then()
              .fadeOut(
                duration: 600.ms,
              ),
        ),
      ),
    );
  }
}

// Compact Voice Input Button (smaller variant)
class CompactVoiceInputButton extends StatefulWidget {
  final bool isListening;
  final VoidCallback onPressed;
  final bool enabled;

  const CompactVoiceInputButton({
    Key? key,
    required this.isListening,
    required this.onPressed,
    this.enabled = true,
  }) : super(key: key);

  @override
  State<CompactVoiceInputButton> createState() => _CompactVoiceInputButtonState();
}

class _CompactVoiceInputButtonState extends State<CompactVoiceInputButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.isListening) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(CompactVoiceInputButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isListening != oldWidget.isListening) {
      if (widget.isListening) {
        _pulseController.repeat(reverse: true);
      } else {
        _pulseController.stop();
        _pulseController.reset();
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.enabled ? () {
        SoundManager().playButtonClick();
        widget.onPressed();
      } : null,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: widget.isListening ? _pulseAnimation.value : 1.0,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.enabled
                    ? (widget.isListening
                        ? AppColors.success
                        : AppColors.primary)
                    : Colors.grey,
                boxShadow: [
                  if (widget.isListening)
                    BoxShadow(
                      color: AppColors.success.withOpacity(0.5),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                ],
              ),
              child: Icon(
                Icons.mic,
                color: Colors.white,
                size: 20,
              ),
            ),
          );
        },
      ),
    );
  }
}

// Voice Waveform Animation (decorative)
class VoiceWaveform extends StatefulWidget {
  final bool isActive;
  final Color color;
  final double height;
  final int barCount;

  const VoiceWaveform({
    Key? key,
    required this.isActive,
    this.color = AppColors.primary,
    this.height = 40,
    this.barCount = 5,
  }) : super(key: key);

  @override
  State<VoiceWaveform> createState() => _VoiceWaveformState();
}

class _VoiceWaveformState extends State<VoiceWaveform>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _controllers = List.generate(
      widget.barCount,
      (index) => AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 300 + (index * 50)),
      ),
    );

    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 0.2, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
    }).toList();

    if (widget.isActive) {
      _startAnimation();
    }
  }

  void _startAnimation() {
    for (var i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 50), () {
        if (mounted && widget.isActive) {
          _controllers[i].repeat(reverse: true);
        }
      });
    }
  }

  void _stopAnimation() {
    for (var controller in _controllers) {
      controller.stop();
      controller.reset();
    }
  }

  @override
  void didUpdateWidget(VoiceWaveform oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _startAnimation();
      } else {
        _stopAnimation();
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(
          widget.barCount,
          (index) => AnimatedBuilder(
            animation: _animations[index],
            builder: (context, child) {
              return Container(
                width: 4,
                height: widget.height * _animations[index].value,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: widget.color,
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// Voice Input Card (with button and status)
class VoiceInputCard extends StatelessWidget {
  final bool isListening;
  final VoidCallback onPressed;
  final String? voiceInput;
  final bool enabled;

  const VoiceInputCard({
    Key? key,
    required this.isListening,
    required this.onPressed,
    this.voiceInput,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isListening ? AppColors.primary : AppColors.border,
          width: 2,
        ),
        boxShadow: [
          if (isListening)
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 2,
            ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Voice button
          VoiceInputButton(
            isListening: isListening,
            onPressed: onPressed,
            enabled: enabled,
            size: 80,
          ),
          
          const SizedBox(height: 16),
          
          // Status text
          Text(
            isListening 
                ? 'Listening...' 
                : (voiceInput?.isNotEmpty ?? false)
                    ? 'Heard: "$voiceInput"'
                    : 'Tap to speak',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isListening ? Colors.white : AppColors.textSecondary,
              fontSize: 16,
              fontWeight: isListening ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          
          // Waveform (when listening)
          if (isListening) ...[
            const SizedBox(height: 16),
            VoiceWaveform(
              isActive: isListening,
              color: AppColors.primary,
              height: 40,
              barCount: 7,
            ),
          ],
          
          // Hint text
          if (!isListening && (voiceInput?.isEmpty ?? true)) ...[
            const SizedBox(height: 8),
            Text(
              'Say your answer clearly',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    )
        .animate()
        .fadeIn()
        .slideY(begin: 0.2, end: 0);
  }
}