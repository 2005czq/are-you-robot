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
  List<_BurstParticle> _particles = const <_BurstParticle>[];
  List<_BalloonParticle> _balloons = const <_BalloonParticle>[];
  List<_FireworkBurst> _fireworks = const <_FireworkBurst>[];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _reseed();
    if (widget.play) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant CelebrationOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
    }

    if (oldWidget.variant != widget.variant ||
        oldWidget.colorSeed != widget.colorSeed) {
      _reseed();
    }

    if (!oldWidget.play && widget.play) {
      _reseed();
      _controller
        ..reset()
        ..forward();
    } else if (oldWidget.play && !widget.play) {
      _controller.reset();
    }
  }

  void _reseed() {
    _particles = _buildParticles();
    _balloons = _buildBalloons();
    _fireworks = _buildFireworks();
  }

  math.Random _seededRandom(int salt) {
    return math.Random(
        (widget.colorSeed?.hashCode ?? 31) ^ salt ^ widget.variant.index * 997);
  }

  List<_BurstParticle> _buildParticles() {
    final random = _seededRandom(41);
    final colors = _paletteFor(widget.colorSeed);

    return List.generate(84, (index) {
      final fromLeft = index.isEven;
      return _BurstParticle(
        color: colors[index % colors.length],
        fromLeft: fromLeft,
        dx: fromLeft
            ? 90 + random.nextDouble() * 520
            : -(90 + random.nextDouble() * 520),
        dy: -(260 + random.nextDouble() * 420),
        size: 10 + random.nextDouble() * 16,
        rotation: random.nextDouble() * math.pi,
        spin: (random.nextDouble() - 0.5) * 0.36,
        delay: random.nextDouble() * 0.24,
      );
    });
  }

  List<_BalloonParticle> _buildBalloons() {
    final random = _seededRandom(83);
    final colors = _paletteFor(widget.colorSeed);

    return List.generate(16, (index) {
      return _BalloonParticle(
        color: colors[index % colors.length],
        xFactor: 0.05 + random.nextDouble() * 0.9,
        drift: -44 + random.nextDouble() * 88,
        wobble: random.nextDouble() * math.pi * 2,
        speed: 0.42 + random.nextDouble() * 0.34,
        size: 28 + random.nextDouble() * 20,
        delay: random.nextDouble() * 0.22,
      );
    });
  }

  List<_FireworkBurst> _buildFireworks() {
    final random = _seededRandom(127);
    final colors = _paletteFor(widget.colorSeed);

    return List.generate(3, (index) {
      final sparkCount = 22 + random.nextInt(7);
      return _FireworkBurst(
        color: colors[index % colors.length],
        launchXFactor: 0.22 + random.nextDouble() * 0.56,
        burstXFactor: 0.22 + random.nextDouble() * 0.56,
        burstYFactor: 0.22 + random.nextDouble() * 0.22,
        delay: index * 0.11,
        sparks: List.generate(sparkCount, (sparkIndex) {
          final angle = (math.pi * 2 / sparkCount) * sparkIndex +
              random.nextDouble() * 0.22;
          return _FireworkSpark(
            angle: angle,
            radius: 92 + random.nextDouble() * 116,
            size: 2.8 + random.nextDouble() * 2.6,
          );
        }),
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
          if (_controller.value == 0 ||
              _controller.status == AnimationStatus.completed) {
            return const SizedBox.shrink();
          }

          return RepaintBoundary(
            child: CustomPaint(
              painter: _CelebrationPainter(
                progress: _controller.value,
                variant: widget.variant,
                particles: _particles,
                balloons: _balloons,
                fireworks: _fireworks,
              ),
              size: Size.infinite,
            ),
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
    required this.wobble,
    required this.speed,
    required this.size,
    required this.delay,
  });

  final Color color;
  final double xFactor;
  final double drift;
  final double wobble;
  final double speed;
  final double size;
  final double delay;
}

class _FireworkSpark {
  const _FireworkSpark({
    required this.angle,
    required this.radius,
    required this.size,
  });

  final double angle;
  final double radius;
  final double size;
}

class _FireworkBurst {
  const _FireworkBurst({
    required this.color,
    required this.launchXFactor,
    required this.burstXFactor,
    required this.burstYFactor,
    required this.delay,
    required this.sparks,
  });

  final Color color;
  final double launchXFactor;
  final double burstXFactor;
  final double burstYFactor;
  final double delay;
  final List<_FireworkSpark> sparks;
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
  final List<_FireworkBurst> fireworks;

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
      final gravity = Curves.easeIn.transform(localProgress) * 380;
      final start = Offset(
        particle.fromLeft ? 18 : size.width - 18,
        size.height - 14,
      );
      final offset = Offset(
        particle.dx * eased + math.sin(localProgress * math.pi * 3) * 12,
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
          height: particle.size * 0.34,
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
          math.sin(localProgress * math.pi * 2 + balloon.wobble) *
              balloon.drift;
      final y = size.height +
          balloon.size -
          localProgress * (size.height + balloon.size * 2);
      final alpha =
          (1 - Curves.easeIn.transform(localProgress) * 0.9).clamp(0.0, 1.0);

      final fill = Paint()..color = balloon.color.withValues(alpha: alpha);
      final highlight = Paint()
        ..color = Colors.white.withValues(alpha: alpha * 0.24);
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
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(x - balloon.size * 0.16, y - balloon.size * 0.18),
          width: balloon.size * 0.22,
          height: balloon.size * 0.34,
        ),
        highlight,
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
    for (final burst in fireworks) {
      final localProgress =
          ((progress - burst.delay) / (1 - burst.delay)).clamp(0.0, 1.0);
      if (localProgress <= 0) {
        continue;
      }

      const launchCutoff = 0.24;
      final launchStart =
          Offset(size.width * burst.launchXFactor, size.height - 24);
      final burstCenter = Offset(
        size.width * burst.burstXFactor,
        size.height * burst.burstYFactor,
      );

      if (localProgress < launchCutoff) {
        final launchProgress =
            Curves.easeOutCubic.transform(localProgress / launchCutoff);
        final launchCurrent =
            Offset.lerp(launchStart, burstCenter, launchProgress)!;
        final trailPaint = Paint()
          ..shader = LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              burst.color.withValues(alpha: 0.0),
              burst.color.withValues(alpha: 0.92),
            ],
          ).createShader(Rect.fromPoints(launchStart, launchCurrent))
          ..strokeWidth = 3.6
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(launchStart, launchCurrent, trailPaint);
        canvas.drawCircle(
          launchCurrent,
          5.4,
          Paint()..color = Colors.white.withValues(alpha: 0.92),
        );
        continue;
      }

      final burstProgress =
          ((localProgress - launchCutoff) / (1 - launchCutoff)).clamp(0.0, 1.0);
      final eased = Curves.easeOutCubic.transform(burstProgress);
      final alpha =
          (1 - Curves.easeIn.transform(burstProgress)).clamp(0.0, 1.0);

      canvas.drawCircle(
        burstCenter,
        24 + burstProgress * 42,
        Paint()..color = burst.color.withValues(alpha: alpha * 0.14),
      );
      canvas.drawCircle(
        burstCenter,
        9 + burstProgress * 14,
        Paint()..color = Colors.white.withValues(alpha: alpha * 0.22),
      );

      for (final spark in burst.sparks) {
        final end = Offset(
          burstCenter.dx + math.cos(spark.angle) * spark.radius * eased,
          burstCenter.dy +
              math.sin(spark.angle) * spark.radius * eased +
              burstProgress * burstProgress * 52,
        );
        final linePaint = Paint()
          ..color = burst.color.withValues(alpha: alpha)
          ..strokeWidth = 3.1 - burstProgress * 1.4
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(burstCenter, end, linePaint);
        canvas.drawCircle(
          end,
          spark.size * (1 - burstProgress * 0.28),
          Paint()..color = burst.color.withValues(alpha: alpha),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CelebrationPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.variant != variant ||
        !identical(oldDelegate.particles, particles) ||
        !identical(oldDelegate.balloons, balloons) ||
        !identical(oldDelegate.fireworks, fireworks);
  }
}
