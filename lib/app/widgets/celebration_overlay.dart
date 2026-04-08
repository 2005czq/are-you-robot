import 'dart:math' as math;

import 'package:flutter/material.dart';

class CelebrationOverlay extends StatefulWidget {
  const CelebrationOverlay({
    super.key,
    required this.play,
    this.duration = const Duration(milliseconds: 1800),
  });

  final bool play;
  final Duration duration;

  @override
  State<CelebrationOverlay> createState() => _CelebrationOverlayState();
}

class _CelebrationOverlayState extends State<CelebrationOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_BurstParticle> _particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _particles = _buildParticles();
    if (widget.play) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant CelebrationOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.play && widget.play) {
      _controller
        ..reset()
        ..forward();
    }
  }

  List<_BurstParticle> _buildParticles() {
    final random = math.Random(42);
    const colors = [
      Color(0xFFF15C4D),
      Color(0xFFF4B942),
      Color(0xFF5AC18E),
      Color(0xFF56B0F4),
      Color(0xFFF48FB1),
    ];

    return List.generate(28, (index) {
      final fromLeft = index.isEven;
      return _BurstParticle(
        color: colors[index % colors.length],
        fromLeft: fromLeft,
        dx: fromLeft
            ? 40 + random.nextDouble() * 220
            : -(40 + random.nextDouble() * 220),
        dy: -(160 + random.nextDouble() * 260),
        size: 10 + random.nextDouble() * 12,
        rotation: random.nextDouble() * math.pi,
        spin: (random.nextDouble() - 0.5) * 0.24,
        delay: random.nextDouble() * 0.16,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          if (_controller.value == 0 && !widget.play) {
            return const SizedBox.shrink();
          }

          return CustomPaint(
            painter: _CelebrationPainter(
              progress: _controller.value,
              particles: _particles,
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class _BurstParticle {
  const _BurstParticle({
    required this.color,
    required this.fromLeft,
    required this.dx,
    required this.dy,
    required this.size,
    required this.rotation,
    required this.spin,
    required this.delay,
  });

  final Color color;
  final bool fromLeft;
  final double dx;
  final double dy;
  final double size;
  final double rotation;
  final double spin;
  final double delay;
}

class _CelebrationPainter extends CustomPainter {
  const _CelebrationPainter({
    required this.progress,
    required this.particles,
  });

  final double progress;
  final List<_BurstParticle> particles;

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final localProgress =
          ((progress - particle.delay) / (1 - particle.delay)).clamp(0.0, 1.0);
      if (localProgress <= 0) {
        continue;
      }

      final eased = Curves.easeOutCubic.transform(localProgress);
      final gravity = Curves.easeIn.transform(localProgress) * 280;
      final start = Offset(
        particle.fromLeft ? 22 : size.width - 22,
        size.height - 18,
      );
      final offset = Offset(
        particle.dx * eased,
        particle.dy * eased + gravity * localProgress,
      );
      final center = start + offset;
      final alpha =
          (1 - Curves.easeIn.transform(localProgress)).clamp(0.0, 1.0);

      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(particle.rotation + particle.spin * localProgress * 24);

      final paint = Paint()
        ..color = particle.color.withValues(alpha: alpha)
        ..style = PaintingStyle.fill;

      final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset.zero,
          width: particle.size,
          height: particle.size * 0.42,
        ),
        const Radius.circular(999),
      );
      canvas.drawRRect(rect, paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _CelebrationPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
