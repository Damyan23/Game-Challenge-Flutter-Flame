import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:my_game/Pools/object_pool.dart';
import 'package:my_game/my_game.dart';
import 'package:my_game/player.dart';
import 'Enemy Strategies/enemy_behaviour_strategy.dart';

enum EnemyState
{
  running,
  attacking
}


class Enemy extends SpriteAnimationGroupComponent with HasGameReference<MyGame>, CollisionCallbacks
{
  Enemy(Vector2 position, this.enemySprite, this.behaviorStrategy) : super(position: position);

  EnemyBehaviorStrategy behaviorStrategy;
  final String enemySprite;

  late final Player player;
  late final SpriteAnimation _run;
  late final SpriteAnimation _attack;

  late Vector2 knockbackDirection = Vector2.zero();
  late double knockbackSpeed = 0.0;
  late double knockbackDuration = 1.0;
  late double knockbackTime = 0.0;

  late int _maxHp;
  late int _currentHp;

  late double _xpReward;

  ObjectPool<Enemy>? _poolRef; // Add this to store the reference to its pool

  @override
  FutureOr<void> onLoad() async 
  {
    _maxHp = behaviorStrategy.maxHp;
    _currentHp = _maxHp;
    _xpReward = behaviorStrategy.xpReward;

    _run = createSpriteAnimation(behaviorStrategy.runConfig.path, behaviorStrategy.runConfig.frameCount, 
                                behaviorStrategy.runConfig.frameDuration, behaviorStrategy.runConfig.spriteSize);

    _attack = createSpriteAnimation(behaviorStrategy.attackConfig.path, behaviorStrategy.attackConfig.frameCount, 
                                  behaviorStrategy.attackConfig.frameDuration, behaviorStrategy.attackConfig.spriteSize);
    animations =
    {
      EnemyState.running: _run,
      EnemyState.attacking: _attack
    };

    current = EnemyState.running;
    player = game.level.player;

    RectangleHitbox hitBox = RectangleHitbox.relative(Vector2(1, 1), parentSize: size, anchor: Anchor.center);
    hitBox.collisionType = CollisionType.active; // Set the collision type to passive
    hitBox.debugMode = true; // Enable debug mode for the hitbox
    add (hitBox);
    return super.onLoad();
  }

  SpriteAnimation createSpriteAnimation(String path, int amount, double stepTime, Vector2 textureSize) {
    SpriteAnimationData spriteData = SpriteAnimationData.sequenced(amount: amount, stepTime: stepTime, textureSize: textureSize);
    return SpriteAnimation.fromFrameData(game.images.fromCache(path), spriteData);
  }

  @override
  void update(double dt) 
  {
    super.update(dt);
    if (game.isGamePaused) return;

    behaviorStrategy.update(this, dt);
    die ();

    if (knockbackTime > 0 && knockbackDirection != Vector2.zero()) 
    {
      position += knockbackDirection * knockbackSpeed * dt;
      knockbackTime -= dt;

      knockbackSpeed *= 0.6; // or use a curve
    } 
    else 
    {
      knockbackDirection = Vector2.zero(); // Clear knockback
      behaviorStrategy.update(this, dt); // Normal behavior
    }

    if (behaviorStrategy.distanceToPlayer.length <= behaviorStrategy.stoppingDistance)
    {
      current = EnemyState.attacking;
    }
    else
    {
      current = EnemyState.running;
    }
  }

  void die ()
  {
    if (_currentHp <= 0) 
    {
      FlameAudio.play("SE-Collision_03.ogg" , volume: 0.5);
      player.addXp(_xpReward);
      deactivate();
    }
  }

  void takeDamage (int amount)
  {
    _currentHp -= amount;
  }

  void setStrategy(EnemyBehaviorStrategy newStrategy) 
  {
    behaviorStrategy = newStrategy;
  }

  void reset(Vector2 position, EnemyBehaviorStrategy strategy, int baseHp, double baseXpReward) 
  {
    this.position = position;
    behaviorStrategy = strategy;
    strategy.maxHp = baseHp;
    _maxHp = strategy.maxHp;
    _currentHp = _maxHp;
    strategy.xpReward = baseXpReward;
    _xpReward = strategy.xpReward;
    knockbackDirection = Vector2.zero();
    knockbackSpeed = 0;
    knockbackTime = 0;
    
  }

  void setPool(ObjectPool<Enemy> pool) {
    _poolRef = pool;
  }   

  void deactivate() 
  {
    removeFromParent();
    _poolRef?.release(this); // Return it to the pool
  }

  // @override
  // void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) 
  // {
  //   print("asd");
  //   if (other is Player)
  //   {
  //     other.takeDamage(behaviorStrategy.damage);
  //   }
  //   super.onCollisionStart(intersectionPoints, other);
  // }
}
