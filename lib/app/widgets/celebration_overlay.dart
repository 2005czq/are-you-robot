import 'dart:math' as math;

import 'package:flutter/material.dart';

class CelebrationOverlay extends StatefulWidget {
  const CelebrationOverlay({
    super.key,
    required this.play,
    this.variant = CelebrationVariant.confetti,
    this.duration = const Duration(milliseconds: 2200),
    this.colorSeed,
  });

  final bool play;
  final CelebrationVariant variant;
  final Duration duration;
  final Color? colorSeed;

  @override
  State<CelebrationOverlay> createState() => _CelebrationOverlayState();
}

class _CelebrationOverlayState extends State<CelebrationOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_BurstParticle> _particles;
  late final List<_BalloonParticle> _balloons;
  late final List<_FireworkParticle> _fireworks;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _particles = _buildParticles();
    _balloons = _buildBalloons();
    _fireworks = _buildFireworks();
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
    final colors = _paletteFor(widget.colorSeed);

    return List.generate(52, (index) {
      final fromLeft = index.isEven;
      return _BurstParticle(
        color: colors[index % colors.length],
        fromLeft: fromLeft,
        dx: fromLeft
            ? 40 + random.nextDouble() * 360
            : -(40 + random.nextDouble() * 360),
        dy: -(220 + random.nextDouble() * 340),
        size: 12 + random.nextDouble() * 16,
        rotation: random.nextDouble() * math.pi,
        spin: (random.nextDouble() - 0.5) * 0.3,
        delay: random.nextDouble() * 0.16,
      );
    });
  }

  List<_BalloonParticle> _buildBalloons() {
    final random = math.Random(84);
    final colors = _paletteFor(widget.colorSeed);

    return List.generate(11, (index) {
      return _BalloonParticle(
        color: colors[index % colors.length],
        xFactor: 0.08 + random.nextDouble() * 0.84,
        drift: -32 + random.nextDouble() * 64,
        speed: 0.45 + random.nextDouble() * 0.3,
        size: 26 + random.nextDouble() * 18,
        delay: random.nextDouble() * 0.26,
      );
    });
  }

  List<_FireworkParticle> _buildFireworks() {
    final random = math.Random(126);
    final colors = _paletteFor(widget.colorSeed);

    return List.generate(18, (index) {
      final angle = (math.pi * 2 / 18) * index;
      final radius = 80 + random.nextDouble() * 110;
      return _FireworkParticle(
        color: colors[index % colors.length],
        angle: angle,
        radius: radius,
      );
    });
  }

  List<Color> _paletteFor(Color? seed) {
    if (seed == null) {
      return const [
        Color(0xFFF15C4D),
        Color(0xFFF4B942),
        Color(0xFF5AC18E),
        Color(0xFF56B0F4),
        Color(0xFFF48FB1),
      ];
    }

    final hsl = HSLColor.fromColor(seed);
    return [
      hsl.withLightness(0.58).withSaturation(0.86).toColor(),
      hsl.withHue((hsl.hue + 28) % 360).withLightness(0.62).toColor(),
      hsl.withHue((hsl.hue + 64) % 360).withLightness(0.64).toColor(),
      hsl.withHue((hsl.hue + 108) % 360).withLightness(0.6).toColor(),
      hsl.withHue((hsl.hue + 148) % 360).withLightness(0.68).toColor(),
    ];
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
              variant: widget.variant,
              particles: _particles,
              balloons: _balloons,
              fireworks: _fireworks,
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

enum CelebrationVariant {
  confetti,
  balloons,
  fireworks,
}

class _BalloonParticle {
  const _BalloonParticle({
    required this.color,
    required this.xFactor,
    required this.drift,
    required this.speed,
    required this.size,
    required this.delay,
  });

  final Color color;
  final double xFactor;
  final double drift;
  final double speed;
  final double size;
  final double delay;
}

class _FireworkParticle {
  const _FireworkParticle({
    required this.color,
    required this.angle,
    required this.radius,
  });

  final Color color;
  final double angle;
  final double radius;
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
    required this.variant,
    required this.particles,
    required this.balloons,
    required this.fireworks,
  });

  final double progress;
  final CelebrationVariant variant;
  final List<_BurstParticle> particles;
  final List<_BalloonParticle> balloons;
  final List<_FireworkParticle> fireworks;

  @override
  void paint(Canvas canvas, Size size) {
    switch (variant) {
      case CelebrationVariant.confetti:
        _paintConfetti(canvas, size);
      case CelebrationVariant.balloons:
        _paintBalloons(canvas, size);
      case CelebrationVariant.fireworks:
        _paintFireworks(canvas, size);
    }
  }

  void _paintConfetti(Canvas canvas, Size size) {
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

  void _paintBalloons(Canvas canvas, Size size) {
    for (final balloon in balloons) {
      final localProgress =
          ((progress - balloon.delay) / balloon.speed).clamp(0.0, 1.0);
      if (localProgress <= 0) {
        continue;
      }

      final x = size.width * balloon.xFactor +
          math.sin(localProgress * math.pi * 2) * balloon.drift;
      final y = size.height +
          balloon.size -
          localProgress * (size.height + balloon.size * 2);
      final alpha =
          (1 - Curves.easeIn.transform(localProgress) * 0.9).clamp(0.0, 1.0);

      final fill = Paint()..color = balloon.color.withValues(alpha: alpha);
      final stringPaint = Paint()
        ..color = balloon.color.withValues(alpha: alpha * 0.65)
        ..strokeWidth = 2;

      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(x, y),
          width: balloon.size,
          height: balloon.size * 1.26,
        ),
        fill,
      );

      final path = Path()
        ..moveTo(x, y + balloon.size * 0.62)
        ..quadraticBezierTo(
          x + math.sin(localProgress * math.pi * 3) * 10,
          y + balloon.size * 1.2,
          x + math.cos(localProgress * math.pi * 2) * 8,
          y + balloon.size * 2.1,
        );
      canvas.drawPath(path, stringPaint);
    }
  }

  void _paintFireworks(Canvas canvas, Size size) {
    final launchProgress =
        Curves.easeOutCubic.transform(progress.clamp(0.0, 0.34));
    final burstProgress = ((progress - 0.34) / 0.66).clamp(0.0, 1.0);
    final launchStart = Offset(size.width * 0.5, size.height - 26);
    final burstCenter = Offset(size.width * 0.5, size.height * 0.34);
    final launchCurrent =
        Offset.lerp(launchStart, burstCenter, launchProgress)!;

    if (progress < 0.34) {
      final trailPaint = Paint()
        ..shader = const LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Color(0xFFFFD36B), Color(0x00FFD36B)],
        ).createShader(
          Rect.fromPoints(launchStart, launchCurrent),
        )
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(launchStart, launchCurrent, trailPaint);
      canvas.drawCircle(
          launchCurrent, 8, Paint()..color = const Color(0xFFFFE48A));
      return;
    }

    final glowAlpha = (1 - burstProgress).clamp(0.0, 1.0);
    canvas.drawCircle(
      burstCenter,
      26 + burstProgress * 22,
      Paint()
        ..color = const Color(0xFFFFF1BF).withValues(alpha: glowAlpha * 0.24),
    );

    for (final spark in fireworks) {
      final end = Offset(
        burstCenter.dx +
            math.cos(spark.angle) *
                spark.radius *
                Curves.easeOut.transform(burstProgress),
        burstCenter.dy +
            math.sin(spark.angle) *
                spark.radius *
                Curves.easeOut.transform(burstProgress),
      );
      final paint = Paint()
        ..color = spark.color.withValues(alpha: glowAlpha)
        ..strokeWidth = 3.2
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(burstCenter, end, paint);
      canvas.drawCircle(
          end, 4.4, Paint()..color = spark.color.withValues(alpha: glowAlpha));
    }
  }

  @override
  bool shouldRepaint(covariant _CelebrationPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.variant != variant;
  }
}
