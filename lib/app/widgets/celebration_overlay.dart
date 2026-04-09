import 'dart:math' as math;

import 'package:flutter/material.dart';

double _clampDouble(num value, double lower, double upper) {
  return value.clamp(lower, upper).toDouble();
}

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
  List<_FireworkShell> _fireworks = const <_FireworkShell>[];

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
      (widget.colorSeed?.hashCode ?? 31) ^ salt ^ widget.variant.index * 997,
    );
  }

  List<_BurstParticle> _buildParticles() {
    final random = _seededRandom(41);
    final colors = _paletteFor(widget.colorSeed);
    final count = 88 + random.nextInt(34);

    return List.generate(count, (index) {
      final fromLeft = index.isEven;
      return _BurstParticle(
        color: colors[index % colors.length],
        fromLeft: fromLeft,
        startXFactor: fromLeft
            ? 0.015 + random.nextDouble() * 0.11
            : 0.875 + random.nextDouble() * 0.11,
        startYFactor: 0.82 + random.nextDouble() * 0.11,
        dx: fromLeft
            ? 180 + random.nextDouble() * 720
            : -(180 + random.nextDouble() * 720),
        dy: -(320 + random.nextDouble() * 560),
        size: 10 + random.nextDouble() * 18,
        rotation: random.nextDouble() * math.pi,
        spin: (random.nextDouble() - 0.5) * 0.42,
        wobble: 5 + random.nextDouble() * 13,
        delay: random.nextDouble() * 0.22,
      );
    });
  }

  List<_BalloonParticle> _buildBalloons() {
    final random = _seededRandom(83);
    final colors = _paletteFor(widget.colorSeed);
    final count = 11 + random.nextInt(7);
    final positions = <double>[];

    for (var index = 0; index < count; index++) {
      var candidate = 0.08 + random.nextDouble() * 0.84;
      var attempts = 0;
      while (positions.any((value) => (value - candidate).abs() < 0.07) &&
          attempts < 14) {
        candidate = 0.08 + random.nextDouble() * 0.84;
        attempts += 1;
      }
      positions.add(candidate);
    }

    positions.sort();

    return List.generate(count, (index) {
      return _BalloonParticle(
        color: colors[index % colors.length],
        xFactor: positions[index],
        drift: -48 + random.nextDouble() * 96,
        wobble: random.nextDouble() * math.pi * 2,
        speed: 0.36 + random.nextDouble() * 0.36,
        size: 28 + random.nextDouble() * 22,
        delay: random.nextDouble() * 0.18,
      );
    });
  }

  List<_FireworkShell> _buildFireworks() {
    final random = _seededRandom(127);
    final palette = _paletteFor(widget.colorSeed);
    final shellTypes = <_FireworkShellType>[
      _FireworkShellType.chrysanthemum,
      _FireworkShellType.chrysanthemum,
      _FireworkShellType.ring,
      _FireworkShellType.palm,
      _FireworkShellType.crackle,
      _FireworkShellType.willow,
    ];
    final shellCount = 3 + random.nextInt(2);
    final burstPositions = <double>[];
    final shells = <_FireworkShell>[];

    for (var index = 0; index < shellCount; index++) {
      var burstX = 0.16 + random.nextDouble() * 0.68;
      var attempts = 0;
      while (burstPositions.any((value) => (value - burstX).abs() < 0.16) &&
          attempts < 18) {
        burstX = 0.16 + random.nextDouble() * 0.68;
        attempts += 1;
      }
      burstPositions.add(burstX);

      final color = palette[random.nextInt(palette.length)];
      final secondaryColor = _brighten(
        _pickContrastingColor(palette, color, random),
        0.16,
      );
      final shellType = shellTypes[random.nextInt(shellTypes.length)];
      final launchX = _clampDouble(
        burstX + (random.nextDouble() - 0.5) * 0.2,
        0.06,
        0.94,
      );
      final burstYFactor = switch (shellType) {
        _FireworkShellType.willow => 0.15 + random.nextDouble() * 0.12,
        _FireworkShellType.palm => 0.18 + random.nextDouble() * 0.14,
        _ => 0.19 + random.nextDouble() * 0.16,
      };

      shells.add(
        _buildFireworkShell(
          random: random,
          type: shellType,
          color: color,
          secondaryColor: secondaryColor,
          launchXFactor: launchX,
          burstXFactor: burstX,
          burstYFactor: burstYFactor,
          delay: index * (0.1 + random.nextDouble() * 0.06),
        ),
      );
    }

    shells.sort((a, b) => a.delay.compareTo(b.delay));
    return shells;
  }

  _FireworkShell _buildFireworkShell({
    required math.Random random,
    required _FireworkShellType type,
    required Color color,
    required Color secondaryColor,
    required double launchXFactor,
    required double burstXFactor,
    required double burstYFactor,
    required double delay,
  }) {
    var primaryColor = color;
    var accentColor = secondaryColor;
    var launchDuration = 0.23 + random.nextDouble() * 0.05;
    var trailWidth = 2.6 + random.nextDouble() * 1.4;
    var cometSize = 4.4 + random.nextDouble() * 1.5;
    var glowSize = 26 + random.nextDouble() * 20;
    var flashSize = 34 + random.nextDouble() * 18;
    var launchBend = (random.nextDouble() - 0.5) * 0.085;
    var launchCurve = 1.5 + random.nextDouble() * 0.35;
    List<_FireworkSpark> sparks;
    List<_FireworkSpark> innerSparks = const <_FireworkSpark>[];
    List<_CrackleSpark> crackleBursts = const <_CrackleSpark>[];

    switch (type) {
      case _FireworkShellType.chrysanthemum:
        final count = 34 + random.nextInt(14);
        sparks = List.generate(count, (index) {
          final angle = (math.pi * 2 / count) * index +
              (random.nextDouble() - 0.5) * 0.18;
          return _FireworkSpark(
            angle: angle,
            radius: 136 + random.nextDouble() * 64,
            size: 2.6 + random.nextDouble() * 1.9,
            trail: 18 + random.nextDouble() * 18,
            speed: 0.88 + random.nextDouble() * 0.18,
            gravity: 40 + random.nextDouble() * 36,
            wobble: 2 + random.nextDouble() * 6,
            spin: random.nextDouble() * math.pi * 2,
            twinkle: random.nextDouble() * math.pi * 2,
          );
        });
        if (random.nextDouble() < 0.55) {
          innerSparks = _buildInnerSparks(
            random,
            count: 15 + random.nextInt(6),
            radiusMin: 52,
            radiusMax: 82,
            gravityMin: 20,
            gravityMax: 34,
          );
        }
      case _FireworkShellType.ring:
        final count = 30 + random.nextInt(8);
        final rotation = random.nextDouble() * math.pi;
        final squash = 0.24 + random.nextDouble() * 0.52;
        glowSize += 8;
        flashSize += 6;
        sparks = List.generate(count, (index) {
          final baseAngle = (math.pi * 2 / count) * index;
          final x = math.sin(baseAngle) * squash;
          final y = math.cos(baseAngle);
          final angle = math.atan2(y, x) + rotation;
          final radiusFactor = math.sqrt(x * x + y * y);
          return _FireworkSpark(
            angle: angle,
            radius: (150 + random.nextDouble() * 26) * radiusFactor,
            size: 2.8 + random.nextDouble() * 1.6,
            trail: 20 + random.nextDouble() * 16,
            speed: 0.9 + random.nextDouble() * 0.1,
            gravity: 28 + random.nextDouble() * 24,
            wobble: 1.4 + random.nextDouble() * 3.2,
            spin: random.nextDouble() * math.pi * 2,
            twinkle: random.nextDouble() * math.pi * 2,
          );
        });
        if (random.nextDouble() < 0.38) {
          innerSparks = _buildInnerSparks(
            random,
            count: 12 + random.nextInt(5),
            radiusMin: 40,
            radiusMax: 62,
            gravityMin: 18,
            gravityMax: 28,
          );
        }
      case _FireworkShellType.palm:
        launchDuration += 0.02;
        trailWidth += 0.3;
        glowSize += 10;
        final count = 12 + random.nextInt(6);
        sparks = List.generate(count, (index) {
          final angleSpread = 0.34 + random.nextDouble() * 0.22;
          final angle = (-math.pi / 2) +
              (index - count / 2) * angleSpread / count +
              (random.nextDouble() - 0.5) * 0.22;
          return _FireworkSpark(
            angle: angle,
            radius: 156 + random.nextDouble() * 74,
            size: 3.2 + random.nextDouble() * 2,
            trail: 34 + random.nextDouble() * 24,
            speed: 0.9 + random.nextDouble() * 0.12,
            gravity: 100 + random.nextDouble() * 54,
            wobble: 4 + random.nextDouble() * 8,
            spin: random.nextDouble() * math.pi * 2,
            twinkle: random.nextDouble() * math.pi * 2,
          );
        });
      case _FireworkShellType.crackle:
        glowSize += 6;
        flashSize += 10;
        accentColor = const Color(0xFFFFF0C8);
        final count = 18 + random.nextInt(7);
        sparks = List.generate(count, (index) {
          final angle = (math.pi * 2 / count) * index +
              (random.nextDouble() - 0.5) * 0.24;
          return _FireworkSpark(
            angle: angle,
            radius: 94 + random.nextDouble() * 48,
            size: 2.4 + random.nextDouble() * 1.6,
            trail: 14 + random.nextDouble() * 10,
            speed: 0.88 + random.nextDouble() * 0.16,
            gravity: 54 + random.nextDouble() * 34,
            wobble: 2 + random.nextDouble() * 5,
            spin: random.nextDouble() * math.pi * 2,
            twinkle: random.nextDouble() * math.pi * 2,
          );
        });
        if (random.nextDouble() < 0.42) {
          innerSparks = _buildInnerSparks(
            random,
            count: 13 + random.nextInt(4),
            radiusMin: 36,
            radiusMax: 56,
            gravityMin: 18,
            gravityMax: 26,
          );
        }
        crackleBursts = List.generate(44 + random.nextInt(16), (index) {
          return _CrackleSpark(
            angle: random.nextDouble() * math.pi * 2,
            distance: 24 + random.nextDouble() * 78,
            size: 1.3 + random.nextDouble() * 1.4,
            delay: random.nextDouble() * 0.34,
            speed: 0.82 + random.nextDouble() * 0.18,
          );
        });
      case _FireworkShellType.willow:
        launchDuration += 0.03;
        glowSize += 12;
        flashSize += 8;
        primaryColor = Color.lerp(primaryColor, const Color(0xFFF4B942), 0.55)!;
        accentColor = Color.lerp(accentColor, Colors.white, 0.45)!;
        final count = 17 + random.nextInt(6);
        sparks = List.generate(count, (index) {
          final angle =
              (math.pi * 2 / count) * index + (random.nextDouble() - 0.5) * 0.2;
          return _FireworkSpark(
            angle: angle,
            radius: 126 + random.nextDouble() * 60,
            size: 2.2 + random.nextDouble() * 1.4,
            trail: 46 + random.nextDouble() * 28,
            speed: 0.76 + random.nextDouble() * 0.14,
            gravity: 138 + random.nextDouble() * 54,
            wobble: 6 + random.nextDouble() * 8,
            spin: random.nextDouble() * math.pi * 2,
            twinkle: random.nextDouble() * math.pi * 2,
          );
        });
    }

    return _FireworkShell(
      type: type,
      color: primaryColor,
      secondaryColor: accentColor,
      launchXFactor: launchXFactor,
      burstXFactor: burstXFactor,
      burstYFactor: burstYFactor,
      delay: delay,
      launchBend: launchBend,
      launchCurve: launchCurve,
      launchDuration: launchDuration,
      trailWidth: trailWidth,
      cometSize: cometSize,
      glowSize: glowSize,
      flashSize: flashSize,
      sparks: sparks,
      innerSparks: innerSparks,
      crackleBursts: crackleBursts,
    );
  }

  List<_FireworkSpark> _buildInnerSparks(
    math.Random random, {
    required int count,
    required double radiusMin,
    required double radiusMax,
    required double gravityMin,
    required double gravityMax,
  }) {
    return List.generate(count, (index) {
      final angle =
          (math.pi * 2 / count) * index + (random.nextDouble() - 0.5) * 0.24;
      return _FireworkSpark(
        angle: angle,
        radius: radiusMin + random.nextDouble() * (radiusMax - radiusMin),
        size: 2 + random.nextDouble() * 1.2,
        trail: 12 + random.nextDouble() * 8,
        speed: 0.82 + random.nextDouble() * 0.18,
        gravity: gravityMin + random.nextDouble() * (gravityMax - gravityMin),
        wobble: 1.2 + random.nextDouble() * 2.6,
        spin: random.nextDouble() * math.pi * 2,
        twinkle: random.nextDouble() * math.pi * 2,
      );
    });
  }

  Color _pickContrastingColor(
    List<Color> palette,
    Color color,
    math.Random random,
  ) {
    final options = palette
        .where((candidate) => candidate.toARGB32() != color.toARGB32())
        .toList(growable: false);
    if (options.isEmpty) {
      return _brighten(color, 0.18);
    }
    return options[random.nextInt(options.length)];
  }

  Color _brighten(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness(_clampDouble(hsl.lightness + amount, 0.0, 0.92))
        .withSaturation(_clampDouble(hsl.saturation + 0.06, 0.0, 1.0))
        .toColor();
  }

  List<Color> _paletteFor(Color? seed) {
    if (seed == null) {
      return const <Color>[
        Color(0xFFF15C4D),
        Color(0xFFF4B942),
        Color(0xFF5AC18E),
        Color(0xFF56B0F4),
        Color(0xFFF48FB1),
      ];
    }

    final hsl = HSLColor.fromColor(seed);
    return <Color>[
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

enum _FireworkShellType {
  chrysanthemum,
  ring,
  crackle,
  willow,
  palm,
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

class _FireworkShell {
  const _FireworkShell({
    required this.type,
    required this.color,
    required this.secondaryColor,
    required this.launchXFactor,
    required this.burstXFactor,
    required this.burstYFactor,
    required this.delay,
    required this.launchBend,
    required this.launchCurve,
    required this.launchDuration,
    required this.trailWidth,
    required this.cometSize,
    required this.glowSize,
    required this.flashSize,
    required this.sparks,
    this.innerSparks = const <_FireworkSpark>[],
    this.crackleBursts = const <_CrackleSpark>[],
  });

  final _FireworkShellType type;
  final Color color;
  final Color secondaryColor;
  final double launchXFactor;
  final double burstXFactor;
  final double burstYFactor;
  final double delay;
  final double launchBend;
  final double launchCurve;
  final double launchDuration;
  final double trailWidth;
  final double cometSize;
  final double glowSize;
  final double flashSize;
  final List<_FireworkSpark> sparks;
  final List<_FireworkSpark> innerSparks;
  final List<_CrackleSpark> crackleBursts;
}

class _FireworkSpark {
  const _FireworkSpark({
    required this.angle,
    required this.radius,
    required this.size,
    required this.trail,
    required this.speed,
    required this.gravity,
    required this.wobble,
    required this.spin,
    required this.twinkle,
  });

  final double angle;
  final double radius;
  final double size;
  final double trail;
  final double speed;
  final double gravity;
  final double wobble;
  final double spin;
  final double twinkle;
}

class _CrackleSpark {
  const _CrackleSpark({
    required this.angle,
    required this.distance,
    required this.size,
    required this.delay,
    required this.speed,
  });

  final double angle;
  final double distance;
  final double size;
  final double delay;
  final double speed;
}

class _BurstParticle {
  const _BurstParticle({
    required this.color,
    required this.fromLeft,
    required this.startXFactor,
    required this.startYFactor,
    required this.dx,
    required this.dy,
    required this.size,
    required this.rotation,
    required this.spin,
    required this.wobble,
    required this.delay,
  });

  final Color color;
  final bool fromLeft;
  final double startXFactor;
  final double startYFactor;
  final double dx;
  final double dy;
  final double size;
  final double rotation;
  final double spin;
  final double wobble;
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
  final List<_FireworkShell> fireworks;

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
      final localProgress = _clampDouble(
          (progress - particle.delay) / (1 - particle.delay), 0, 1);
      if (localProgress <= 0) {
        continue;
      }

      final eased = Curves.easeOutCubic.transform(localProgress);
      final gravity = Curves.easeIn.transform(localProgress) * 420;
      final start = Offset(
        size.width * particle.startXFactor,
        size.height * particle.startYFactor,
      );
      final offset = Offset(
        particle.dx * eased +
            math.sin(localProgress * math.pi * particle.wobble) * 14,
        particle.dy * eased + gravity * localProgress,
      );
      final center = start + offset;
      final alpha = _clampDouble(
        1 - Curves.easeIn.transform(localProgress),
        0,
        1,
      );

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
          _clampDouble((progress - balloon.delay) / balloon.speed, 0, 1);
      if (localProgress <= 0) {
        continue;
      }

      final x = size.width * balloon.xFactor +
          math.sin(localProgress * math.pi * 2 + balloon.wobble) *
              balloon.drift;
      final y = size.height +
          balloon.size -
          localProgress * (size.height + balloon.size * 2);
      final alpha = _clampDouble(
        1 - Curves.easeIn.transform(localProgress) * 0.9,
        0,
        1,
      );

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
    for (final shell in fireworks) {
      final localProgress =
          _clampDouble((progress - shell.delay) / (1 - shell.delay), 0, 1);
      if (localProgress <= 0) {
        continue;
      }

      final center = Offset(
        size.width * shell.burstXFactor,
        size.height * shell.burstYFactor,
      );

      if (localProgress < shell.launchDuration) {
        final launchProgress =
            Curves.easeOutCubic.transform(localProgress / shell.launchDuration);
        _paintLaunch(canvas, size, shell, center, launchProgress);
        continue;
      }

      final burstProgress = _clampDouble(
        (localProgress - shell.launchDuration) / (1 - shell.launchDuration),
        0,
        1,
      );
      _paintShell(canvas, shell, center, burstProgress);
    }
  }

  void _paintLaunch(
    Canvas canvas,
    Size size,
    _FireworkShell shell,
    Offset center,
    double launchProgress,
  ) {
    const segments = 10;
    final startProgress = _clampDouble(launchProgress - 0.44, 0, 1);
    final points = <Offset>[];

    for (var index = 0; index <= segments; index++) {
      final t =
          startProgress + (launchProgress - startProgress) * (index / segments);
      points.add(_launchPoint(size, shell, center, t));
    }

    for (var index = 1; index < points.length; index++) {
      final ratio = index / (points.length - 1);
      canvas.drawLine(
        points[index - 1],
        points[index],
        Paint()
          ..color = shell.color.withValues(alpha: 0.08 + ratio * 0.58)
          ..strokeWidth = shell.trailWidth * (0.35 + ratio * 0.85)
          ..strokeCap = StrokeCap.round,
      );
    }

    final comet = _launchPoint(size, shell, center, launchProgress);
    canvas.drawCircle(
      comet,
      shell.cometSize * 2.2,
      Paint()..color = shell.color.withValues(alpha: 0.16),
    );
    canvas.drawCircle(
      comet,
      shell.cometSize,
      Paint()..color = shell.secondaryColor.withValues(alpha: 0.8),
    );
    canvas.drawCircle(
      comet,
      shell.cometSize * 0.56,
      Paint()..color = Colors.white.withValues(alpha: 0.92),
    );

    for (var index = 1; index <= 5; index++) {
      final emberProgress = _clampDouble(launchProgress - index * 0.055, 0, 1);
      if (emberProgress <= 0) {
        continue;
      }
      final ember = _launchPoint(size, shell, center, emberProgress).translate(
        (index.isEven ? 1 : -1) * index * 1.2,
        index * 2.1,
      );
      final emberSize = _clampDouble(
        shell.cometSize * (0.56 - index * 0.08),
        0.9,
        shell.cometSize,
      );
      canvas.drawCircle(
        ember,
        emberSize,
        Paint()
          ..color = shell.secondaryColor
              .withValues(alpha: _clampDouble(0.24 - index * 0.03, 0.03, 0.24)),
      );
    }
  }

  Offset _launchPoint(
    Size size,
    _FireworkShell shell,
    Offset center,
    double progress,
  ) {
    final rise = 1 - math.pow(1 - progress, shell.launchCurve).toDouble();
    final start = Offset(size.width * shell.launchXFactor, size.height + 24);
    final bend = math.sin(rise * math.pi) *
        shell.launchBend *
        size.width *
        (1 - rise * 0.45);
    return Offset(
      start.dx + (center.dx - start.dx) * rise + bend,
      start.dy + (center.dy - start.dy) * rise,
    );
  }

  void _paintShell(
    Canvas canvas,
    _FireworkShell shell,
    Offset center,
    double burstProgress,
  ) {
    final fade = _clampDouble(
      1 - Curves.easeInCubic.transform(burstProgress),
      0,
      1,
    );
    if (fade <= 0) {
      return;
    }

    final flash = _clampDouble(1 - burstProgress / 0.24, 0, 1);
    canvas.drawCircle(
      center,
      shell.glowSize + burstProgress * 54,
      Paint()..color = shell.color.withValues(alpha: fade * 0.12),
    );
    canvas.drawCircle(
      center,
      shell.flashSize * (0.76 + flash * 0.3),
      Paint()..color = shell.secondaryColor.withValues(alpha: flash * 0.1),
    );
    canvas.drawCircle(
      center,
      5 + flash * 16,
      Paint()..color = Colors.white.withValues(alpha: flash * 0.34),
    );

    _paintSparkSet(
      canvas,
      center,
      shell.sparks,
      shell.color,
      burstProgress,
      fade,
      trailBias: switch (shell.type) {
        _FireworkShellType.willow => 1.65,
        _FireworkShellType.palm => 1.32,
        _ => 1,
      },
      twinkle: shell.type == _FireworkShellType.crackle ||
          shell.type == _FireworkShellType.willow,
    );

    if (shell.innerSparks.isNotEmpty) {
      _paintSparkSet(
        canvas,
        center,
        shell.innerSparks,
        shell.secondaryColor,
        _clampDouble(burstProgress * 1.06, 0, 1),
        fade * 0.82,
        trailBias: 0.82,
        twinkle: true,
      );
    }

    if (shell.crackleBursts.isNotEmpty) {
      _paintCrackleBursts(canvas, center, shell, burstProgress, fade);
    }
  }

  void _paintSparkSet(
    Canvas canvas,
    Offset center,
    List<_FireworkSpark> sparks,
    Color color,
    double progress,
    double fade, {
    required double trailBias,
    required bool twinkle,
  }) {
    for (final spark in sparks) {
      final sparkProgress = _clampDouble(progress / spark.speed, 0, 1);
      if (sparkProgress <= 0) {
        continue;
      }

      final point = _burstPoint(center, spark, sparkProgress);
      final previous = _burstPoint(
        center,
        spark,
        _clampDouble(sparkProgress - 0.06, 0, 1),
      );
      final velocity = point - previous;
      final distance = velocity.distance;
      final direction = distance == 0
          ? Offset(math.cos(spark.angle), math.sin(spark.angle))
          : velocity / distance;
      final tailLength =
          spark.trail * trailBias * (0.28 + sparkProgress * 0.82);
      final tailStart = point - direction * tailLength;
      final shimmer = twinkle
          ? 0.62 + 0.38 * math.sin(progress * 20 + spark.twinkle).abs()
          : 1.0;
      final alpha = _clampDouble(fade * shimmer, 0, 1);
      final strokeWidth = _clampDouble(spark.size * 0.78, 1.1, 4.4);

      canvas.drawLine(
        tailStart,
        point,
        Paint()
          ..shader = LinearGradient(
            colors: <Color>[
              color.withValues(alpha: 0),
              color.withValues(alpha: alpha),
            ],
          ).createShader(Rect.fromPoints(tailStart, point))
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round,
      );

      if (trailBias > 1.2) {
        final softStart = point - direction * tailLength * 0.55;
        canvas.drawLine(
          softStart,
          point,
          Paint()
            ..color = color.withValues(alpha: alpha * 0.22)
            ..strokeWidth = strokeWidth * 1.8
            ..strokeCap = StrokeCap.round,
        );
      }

      canvas.drawCircle(
        point,
        _clampDouble(spark.size * (1 - sparkProgress * 0.22), 0.9, spark.size),
        Paint()..color = color.withValues(alpha: alpha),
      );
    }
  }

  Offset _burstPoint(Offset center, _FireworkSpark spark, double progress) {
    final curved = Curves.easeOutCubic.transform(progress);
    final radial = spark.radius * curved;
    final wobble =
        math.sin(progress * math.pi * 2 + spark.spin) * spark.wobble * progress;
    final normalAngle = spark.angle + math.pi / 2;

    return Offset(
      center.dx +
          math.cos(spark.angle) * radial +
          math.cos(normalAngle) * wobble,
      center.dy +
          math.sin(spark.angle) * radial +
          math.sin(normalAngle) * wobble +
          spark.gravity * progress * progress,
    );
  }

  void _paintCrackleBursts(
    Canvas canvas,
    Offset center,
    _FireworkShell shell,
    double burstProgress,
    double fade,
  ) {
    if (burstProgress < 0.44) {
      return;
    }

    final crackleProgress = _clampDouble((burstProgress - 0.44) / 0.56, 0, 1);
    for (final spark in shell.crackleBursts) {
      if (crackleProgress < spark.delay) {
        continue;
      }

      final local = _clampDouble(
        (crackleProgress - spark.delay) / (1 - spark.delay),
        0,
        1,
      );
      final curved = Curves.easeOutCubic
          .transform(_clampDouble(local / spark.speed, 0, 1));
      final point = Offset(
        center.dx + math.cos(spark.angle) * (18 + spark.distance * curved),
        center.dy +
            math.sin(spark.angle) * (18 + spark.distance * curved) +
            34 * curved * curved,
      );
      final shimmer = 0.55 + 0.45 * math.sin((local + spark.delay) * 30).abs();
      final alpha = _clampDouble(
        (1 - Curves.easeIn.transform(local)) * fade * shimmer,
        0,
        1,
      );
      final crackleColor =
          Color.lerp(shell.secondaryColor, Colors.white, 0.56)!;

      canvas.drawCircle(
        point,
        _clampDouble(spark.size * (1 - local * 0.26), 0.8, spark.size),
        Paint()..color = crackleColor.withValues(alpha: alpha),
      );
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
