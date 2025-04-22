import 'package:my_game/Pools/object_pool.dart';

import 'enemy_behaviour_strategy.dart';
import 'package:my_game/enemy.dart';
import 'package:my_game/Bullets/ranged_enemy_bullet.dart';
import 'package:flame/components.dart';

class RangedStrategy extends EnemyBehaviorStrategy
{
  RangedStrategy(SpriteAnimationConfig runConfig, SpriteAnimationConfig attackConfig, this.shootingCooldown, 
                double stoppingDistance, int maxHp, double xpReward,double speed, int damage, this.bulletPool)
  {
    this.runConfig = runConfig;
    this.attackConfig = attackConfig;
    this.maxHp = maxHp;
    this.xpReward = xpReward;
    this.stoppingDistance = stoppingDistance;
    this.speed = speed;
    this.damage = damage;
  }


  final ObjectPool<RangedEnemyBullet> bulletPool; // Store the pool here

  late double shootingCooldown = 2.0; // Seconds between shots
  double _cooldownTimer = 0.0;

  @override
  void update(Enemy enemy, double dt) 
  {
    super.update(enemy, dt); 

    if (distanceToPlayer.length <= stoppingDistance) {
      _cooldownTimer -= dt;
      if (_cooldownTimer <= 0.0) {
        shoot(enemy, normalizedDistanceToPlayer);
        _cooldownTimer = shootingCooldown;
      }
    } else {
      // Move closer to player if not in range
      final direction = normalizedDistanceToPlayer;
      enemy.position += direction * speed * dt;
    }
  }

  void shoot(Enemy enemy, Vector2 direction) {
    final bullet = bulletPool.obtain();
    bullet.setPool(bulletPool); 
    bullet.reset(enemy.position, direction, 0);
    enemy.parent?.add(bullet); 
  }
}
