import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class ReloadBar extends PositionComponent {
  double progress = 0.0; // from 0.0 to 1.0

  ReloadBar({
    required super.position,
    required super.size,
  });

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final whitePaint = Paint()..color = Colors.white;

    // Dimensions
    const bracketHeight = 16.0;
    const bracketSideLength = 6.0;
    const lineThickness = 2.0;
    const barHeight = 3.0;

    final centerY = size.y / 2;
    final barStart = bracketSideLength;
    final barEnd = size.x - (bracketSideLength);
    final barWidth = barEnd - barStart;

    // === Left Bracket ===
    canvas.drawRect(Rect.fromLTWH(0, centerY - bracketHeight / 2, lineThickness, bracketHeight), whitePaint); // vertical
    canvas.drawRect(Rect.fromLTWH(0, centerY - bracketHeight / 2, bracketSideLength, lineThickness), whitePaint); // top (shorter)
    canvas.drawRect(Rect.fromLTWH(0, centerY + bracketHeight / 2 - lineThickness, bracketSideLength, lineThickness), whitePaint); // bottom (shorter)

    // === Right Bracket ===
    final rightX = size.x - lineThickness;
    canvas.drawRect(Rect.fromLTWH(rightX, centerY - bracketHeight / 2, lineThickness, bracketHeight), whitePaint); // vertical
    canvas.drawRect(Rect.fromLTWH(size.x - bracketSideLength, centerY - bracketHeight / 2, bracketSideLength, lineThickness), whitePaint); // top (shorter)
    canvas.drawRect(Rect.fromLTWH(size.x - bracketSideLength, centerY + bracketHeight / 2 - lineThickness, bracketSideLength, lineThickness), whitePaint); // bottom (shorter)

    // === Middle Bar (Track) ===
    canvas.drawRect(
      Rect.fromLTWH(barStart, centerY - barHeight / 2, barWidth, barHeight),
      whitePaint,
    );

    // === Moving Marker ===
    final markerWidth = 4.0;
    final markerHeight = bracketHeight;
    final markerX = barStart + progress * barWidth;

    canvas.drawRect(
      Rect.fromLTWH(markerX - markerWidth / 2, centerY - markerHeight / 2, markerWidth, markerHeight),
      whitePaint,
    );
  }

  void setProgress(double value) {
    progress = value.clamp(0.0, 1.0);
  }
}
