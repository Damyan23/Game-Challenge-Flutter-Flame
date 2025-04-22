import 'package:my_game/enemy.dart';
import 'enemy_behaviour_strategy.dart';

class MeleeStrategy extends EnemyBehaviorStrategy 
{
  MeleeStrategy(SpriteAnimationConfig runConfig, SpriteAnimationConfig attackConfig, this.attackCooldown, 
                double stoppingDistance, int maxHp, double xpReward,double speed, int damage)
  {
    this.runConfig = runConfig;
    this.attackConfig = attackConfig;
    this.maxHp = maxHp;
    this.xpReward = xpReward;
    this.stoppingDistance = stoppingDistance;
    this.speed = speed;
    this.damage = damage;
  }

  double attackCooldown = 2.0; // seconds between attacks
  double _timeSinceLastAttack = 0.0;

  @override
  void update(Enemy enemy, double dt) {
    super.update(enemy, dt);
    // Time progresses
    _timeSinceLastAttack += dt;

    // Attack if within range and cooldown is over
    if (distanceToPlayer.length <= stoppingDistance && _timeSinceLastAttack >= attackCooldown) {
      _timeSinceLastAttack = 0.0;

      enemy.player.takeDamage(damage);
    }
  }
}

