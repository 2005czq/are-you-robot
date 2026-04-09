import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'emoji_text.dart';

class EmojiPattern extends StatelessWidget {
  const EmojiPattern({
    super.key,
    required this.emojis,
    this.size = 18,
    this.opacity = 0.1,
    this.spacing = 18,
    this.rotation = -0.12,
    this.padding = const EdgeInsets.all(24),
  });

  final List<String> emojis;
  final double size;
  final double opacity;
  final double spacing;
  final double rotation;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stride = size + spacing;
          final columns =
              math.max(3, (constraints.maxWidth / stride).ceil() + 2);
          final rows = math.max(2, (constraints.maxHeight / stride).ceil() + 2);
          final width = columns * stride;
          final height = rows * stride;

          return ClipRect(
            child: Transform.rotate(
              angle: rotation,
              child: OverflowBox(
                maxWidth: constraints.maxWidth * 1.18,
                maxHeight: constraints.maxHeight * 1.18,
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: padding,
                  child: SizedBox(
                    width: width,
                    height: height,
                    child: Stack(
                      children: [
                        for (var row = 0; row < rows; row++)
                          for (var column = 0; column < columns; column++)
                            Positioned(
                              left: column * stride,
                              top: row * stride,
                              child: Opacity(
                                opacity: opacity,
                                child: SizedBox(
                                  width: stride,
                                  height: stride,
                                  child: Center(
                                    child: EmojiText(
                                      emojis[(row * columns + column) %
                                          emojis.length],
                                      size: size,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
