import 'package:flame/components.dart';
import 'package:my_game/Bullets/bullet.dart';
import 'package:my_game/player.dart';

class RangedEnemyBullet extends Bullet {
  RangedEnemyBullet({
      required super.bulletSprite,
      required super.forwardDirection,
      required super.speed,
      required super.damage,
      required super.scaleFactor,
      required super.angle,
      required super.maxDistance,
  });
  @override
  void applyDamage(PositionComponent other, Vector2 collisionPoint) 
  {
    if (other is Player) 
    {
      other.takeDamage(damage);
      spawnImpactVFX(collisionPoint);
      deactivate();
    }
  }
}
