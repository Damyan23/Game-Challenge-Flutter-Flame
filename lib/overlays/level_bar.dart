import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class LevelBar extends PositionComponent 
{
  LevelBar();

  double _xp = 0;
  double _xpToLevel = 100;
  int _level = 1;

  double barHeight = 30.0;

  late final TextComponent _levelText;

  final double _horizontalPadding = 16;

  @override
  Future<void> onLoad() async
  {
    super.onLoad();
    
    _levelText = TextComponent(
      text: 'Level $_level',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    )
      ..anchor = Anchor.center;

    add(_levelText);
  }

  @override
  // ignore: avoid_renaming_method_parameters
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);

    size = Vector2(gameSize.x - _horizontalPadding * 2, barHeight);
    position = Vector2(_horizontalPadding, 10);
    _levelText.position = size / 2;
  }

  void setXP(double value, double max, int currentLevel) {
    _xp = value;
    _xpToLevel = max;
    _level = currentLevel;
    _levelText.text = 'Level $_level';
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final bgPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    final fgPaint = Paint()
      ..color = Colors.blueGrey
      ..style = PaintingStyle.fill;

    final progressWidth = (_xp / _xpToLevel).clamp(0.0, 1.0) * size.x;

    // Background
    canvas.drawRect(size.toRect(), bgPaint);

    // Progress fill
    canvas.drawRect(
      Rect.fromLTWH(0, 0, progressWidth, size.y),
      fgPaint,
    );
  }
}
