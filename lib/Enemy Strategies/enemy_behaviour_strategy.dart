import "package:flame/components.dart";
import "../enemy.dart";

class SpriteAnimationConfig 
{
  final String path;
  final int frameCount;
  final double frameDuration;
  final Vector2 spriteSize;
  
  const SpriteAnimationConfig({
    required this.path,
    required this.frameCount,
    required this.frameDuration,
    required this.spriteSize,
  });
}

abstract class EnemyBehaviorStrategy
{
  late bool isFliped = false;
  Vector2 distanceToPlayer = Vector2.zero();
  Vector2 normalizedDistanceToPlayer = Vector2.zero();

  late int maxHp;
  late double xpReward;
  late double speed = 5;
  late double stoppingDistance = 50; 
  late int damage = 5;

  late SpriteAnimationConfig runConfig;
  late SpriteAnimationConfig attackConfig;

  void update(Enemy enemy, double dt)
  {
    distanceToPlayer = enemy.player.position - enemy.position;
    normalizedDistanceToPlayer = distanceToPlayer.normalized();
    handelFlip(enemy);
    goToPlayer(enemy, dt);
  }

  void handelFlip (Enemy enemy)
  {
    if (normalizedDistanceToPlayer.x < 0 && !isFliped)
    {
      enemy.flipHorizontallyAroundCenter();
      isFliped = true;
    }
    else if (normalizedDistanceToPlayer.x > 0 && isFliped)
    {
      enemy.flipHorizontallyAroundCenter();
      isFliped = false;
    }
  }

  void goToPlayer (Enemy enemy, double dt)
  {
    if (distanceToPlayer.length > stoppingDistance)
    {
      enemy.position += normalizedDistanceToPlayer * speed * dt;
    }
  }
}

