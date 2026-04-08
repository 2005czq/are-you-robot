import 'package:flutter/material.dart';

class FadeSlideIn extends StatefulWidget {
  const FadeSlideIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.offset = const Offset(0, 0.035),
    this.duration = const Duration(milliseconds: 420),
    this.beginScale = 0.985,
  });

  final Widget child;
  final Duration delay;
  final Offset offset;
  final Duration duration;
  final double beginScale;

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn> {
  var _visible = false;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(widget.delay, () {
      if (!mounted) {
        return;
      }
      setState(() {
        _visible = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      duration: widget.duration,
      curve: Curves.easeOutCubic,
      offset: _visible ? Offset.zero : widget.offset,
      child: AnimatedScale(
        duration: widget.duration,
        curve: Curves.easeOutCubic,
        scale: _visible ? 1 : widget.beginScale,
        child: AnimatedOpacity(
          duration: widget.duration,
          curve: Curves.easeOutCubic,
          opacity: _visible ? 1 : 0,
          child: widget.child,
        ),
      ),
    );
  }
}
