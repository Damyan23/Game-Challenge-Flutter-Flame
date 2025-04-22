import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:flame/palette.dart';

enum MenuState { start, gameOver }

class MenuOverlay extends PositionComponent {
  MenuOverlay({required this.menuState, required this.onButtonPressed});

  final MenuState menuState;
  final VoidCallback onButtonPressed;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    anchor = Anchor.center;
    size = Vector2(200, 120);

    // Background
    add(RectangleComponent(
      size: size,
      paint: Paint()..color = Colors.black.withValues(alpha: 0.7),
    ));

    // Title Text
    add(TextComponent(
      text: menuState == MenuState.start ? 'Start Game' : 'Game Over',
      anchor: Anchor.topCenter,
      position: Vector2(size.x / 2, 10),
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 18,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    ));

    // Button
    add(_createButton(
      text: menuState == MenuState.start ? 'Start' : 'Retry',
      onPressed: onButtonPressed,
      yOffset: 60,
    ));
  }

  Component _createButton({
    required String text,
    required VoidCallback onPressed,
    required double yOffset,
  }) 
  {
    final buttonSize = Vector2(140, 40);

    // Wrap both button and label in a parent component
    final buttonComponent = PositionComponent(
      position: Vector2((size.x - buttonSize.x) / 2, yOffset),
      size: buttonSize,
    );

    final hudButton = HudButtonComponent(
      button: RectangleComponent(
        size: buttonSize,
        paint: BasicPalette.white.paint(),
      ),
      buttonDown: RectangleComponent(
        size: buttonSize,
        paint: BasicPalette.gray.paint(),
      ),
      onPressed: onPressed,
    );

    final label = TextComponent(
      text: text,
      anchor: Anchor.center,
      position: buttonSize / 2,
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black,
        ),
      ),
    );

    buttonComponent.add(hudButton);
    buttonComponent.add(label);

    return buttonComponent;
  }
}

