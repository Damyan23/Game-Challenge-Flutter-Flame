import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/rendering.dart';
import 'package:flutter/material.dart';
import 'package:my_game/my_game.dart';
import 'package:my_game/overlays/Upgrades/upgrade_data.dart';
import 'package:my_game/overlays/Upgrades/upgrade_tier.dart';
import 'package:my_game/player_stats.dart';

class Upgrade extends PositionComponent
    with HasGameReference<MyGame>, TapCallbacks, HoverCallbacks {
  late final PlayerStats stats;
  final UpgradeType type;
  final Rarity rarity;

  late final UpgradeData data;
  late final UpgradeTier tier;
  late final TextComponent text;
  late final Sprite icon;

  late final RectangleComponent background;
  late final RectangleComponent glowBorder;

  @override
  bool isHovered = false;

  Effect? _scaleEffect;

  VoidCallback? onTap;

  Upgrade({
    required this.type,
    required this.rarity,
    required Vector2 size,
  }) : super(size: size) {
    data = upgradeRegistry[type]!;
  }

  @override
  Future<void> onLoad() async {
    anchor = Anchor.center;
    stats = game.level.stats;

    tier = data.tiers.firstWhere(
      (t) => t.rarity == rarity,
      orElse: () => throw Exception("Rarity $rarity not found for $type"),
    );

    final image = await game.images.load(data.icon);
    icon = Sprite(image);

    // Base background
    background = RectangleComponent(
      size: size,
      paint: Paint()..color = Colors.black26,
    );
    background.decorator.addLast(PaintDecorator.blur(5));
    add(background);


    // Label text
    text = TextComponent(
      text: '${data.label} (+${tier.value})',
      textRenderer: TextPaint(
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
    )
      ..anchor = Anchor.topCenter
      ..position = size / 2 + Vector2(0, 30);
    add(text);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Draw icon manually
    icon.render(
      canvas,
      position: Vector2(size.x / 2 - 20, 6),
      size: Vector2(40, 40),
    );
  }

  @override
  void onTapDown(TapDownEvent event) {
    data.effect(stats, tier.value);
    onTap?.call();
  }

  @override
  void onHoverEnter() {
    isHovered = true;
    _animateScale(1.05);
    super.onHoverEnter();
  }

  @override
  void onHoverExit() {
    isHovered = false;
    _animateScale(1);
    super.onHoverExit();
  }

  void _animateScale(double targetScale) {
    _scaleEffect?.removeFromParent();

    _scaleEffect = ScaleEffect.to(
      Vector2.all(targetScale),
      EffectController(
        duration: 0.2,
        curve: Curves.easeInOut,
      ),
    );

    add(_scaleEffect!);
  }

}
