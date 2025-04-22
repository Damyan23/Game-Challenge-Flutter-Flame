import 'dart:async';
import 'dart:math';
import 'package:flame/components.dart';
import 'package:my_game/my_game.dart';
import 'package:my_game/player_stats.dart';

class Gun extends SpriteComponent with HasGameReference<MyGame>
{
  Gun(this.gunSprite)
      : super(anchor: Anchor.centerLeft);

  String gunSprite;
  late final PlayerStats _stats;
  final double _offset = 50;

  @override
  FutureOr<void> onLoad() async 
  {
    _stats = game.level.stats;
    sprite = Sprite(game.images.fromCache(gunSprite));
    _stats.currentBullets = _stats.maxBullets;

    // Set the size to the original size of the sprite
    size = sprite!.originalSize;
    position += Vector2 (_offset, 0);

    return super.onLoad();
  }

  Vector2 forwardDirection ()
  {
    return Vector2(cos(angle), sin(angle)); // Calculate the forward direction based on the angle
  }
}
