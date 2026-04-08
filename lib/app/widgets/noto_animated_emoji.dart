import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class NotoAnimatedEmoji extends StatelessWidget {
  const NotoAnimatedEmoji({
    super.key,
    required this.asset,
    required this.size,
    this.repeat = false,
    this.opacity = 1,
  });

  final String asset;
  final double size;
  final bool repeat;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Opacity(
        opacity: opacity,
        child: RepaintBoundary(
          child: Lottie.asset(
            asset,
            repeat: repeat,
            frameRate: FrameRate.composition,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
