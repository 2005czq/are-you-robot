import 'dart:math' as math;

import 'package:flutter/material.dart';

const kEmojiFontFallback = <String>[
  'NotoColorEmoji',
  'Noto Color Emoji',
];

TextStyle emojiTextStyle({
  required double size,
  FontWeight fontWeight = FontWeight.w400,
  double height = 1,
  List<Shadow>? shadows,
}) {
  return TextStyle(
    fontFamily: 'NotoColorEmoji',
    fontFamilyFallback: kEmojiFontFallback,
    fontSize: size,
    fontWeight: fontWeight,
    height: height,
    shadows: shadows,
  );
}

class EmojiText extends StatelessWidget {
  const EmojiText(
    this.emoji, {
    super.key,
    required this.size,
    this.textAlign,
    this.shadows,
  });

  final String emoji;
  final double size;
  final TextAlign? textAlign;
  final List<Shadow>? shadows;

  @override
  Widget build(BuildContext context) {
    return Text(
      emoji,
      textAlign: textAlign,
      style: emojiTextStyle(size: size, shadows: shadows),
      strutStyle: const StrutStyle(forceStrutHeight: true, height: 1),
    );
  }
}

enum EmojiMotion {
  none,
  hover,
  loop,
}

class AnimatedEmoji extends StatefulWidget {
  const AnimatedEmoji(
    this.emoji, {
    super.key,
    required this.size,
    this.motion = EmojiMotion.none,
    this.duration = const Duration(milliseconds: 1600),
    this.scaleBoost = 0.08,
    this.lift = 10,
    this.turns = 0.01,
    this.shadows,
  });

  final String emoji;
  final double size;
  final EmojiMotion motion;
  final Duration duration;
  final double scaleBoost;
  final double lift;
  final double turns;
  final List<Shadow>? shadows;

  @override
  State<AnimatedEmoji> createState() => _AnimatedEmojiState();
}

class _AnimatedEmojiState extends State<AnimatedEmoji>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _syncAnimation();
  }

  @override
  void didUpdateWidget(covariant AnimatedEmoji oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
    }

    if (oldWidget.motion != widget.motion) {
      _syncAnimation();
    }
  }

  void _syncAnimation() {
    switch (widget.motion) {
      case EmojiMotion.none:
        _controller
          ..stop()
          ..value = 0;
      case EmojiMotion.hover:
        _controller
          ..stop()
          ..value = 0;
      case EmojiMotion.loop:
        _controller.repeat(reverse: true);
    }
  }

  void _setHovering(bool hovering) {
    if (widget.motion != EmojiMotion.hover) {
      return;
    }

    if (hovering) {
      _controller.repeat(reverse: true);
    } else {
      _controller.stop();
      _controller.animateTo(
        0,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final child = AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final eased = Curves.easeInOut.transform(_controller.value);
        final wave = math.sin(eased * math.pi);

        return Transform.translate(
          offset: Offset(0, -widget.lift * wave),
          child: Transform.rotate(
            angle: wave * widget.turns * math.pi * 2,
            child: Transform.scale(
              scale: 1 + widget.scaleBoost * wave,
              child: EmojiText(
                widget.emoji,
                size: widget.size,
                shadows: widget.shadows,
              ),
            ),
          ),
        );
      },
    );

    if (widget.motion != EmojiMotion.hover) {
      return child;
    }

    return MouseRegion(
      onEnter: (_) => _setHovering(true),
      onExit: (_) => _setHovering(false),
      child: child,
    );
  }
}
