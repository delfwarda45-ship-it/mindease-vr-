import 'package:flutter/material.dart';
import 'ui.dart';

class BreathingCircle extends StatelessWidget {
  final Animation<double> animation;
  final String phase;
  final String instruction;

  const BreathingCircle({
    super.key,
    required this.animation,
    required this.phase,
    required this.instruction,
  });

  @override
  Widget build(BuildContext context) {
    final diameter = 180.0 + (animation.value * 120.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Container(
              width: diameter,
              height: diameter,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppUI.purplePrimary.withOpacity(0.35),
                    AppUI.purpleSecondary.withOpacity(0.12),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppUI.purplePrimary.withOpacity(0.18),
                    blurRadius: 30,
                    spreadRadius: 3,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  phase,
                  style: const TextStyle(
                    color: AppUI.purplePrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 24),
        Text(
          instruction,
          style: AppUI.bodyText.copyWith(
            color: AppUI.textColor.withOpacity(0.8),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
