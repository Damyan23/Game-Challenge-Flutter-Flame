// bullet_base.dart
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flame/particles.dart';
import 'package:my_game/Pools/object_pool.dart';
import 'package:my_game/my_game.dart';

abstract class Bullet extends SpriteComponent with HasGameReference<MyGame>, CollisionCallbacks {
  Bullet({
    required this.bulletSprite,
    required this.forwardDirection,
    required this.speed,
    required this.damage,
    required double scaleFactor,
    required double angle,
    required this.maxDistance, // Add maxDistance to constructor
  }) : super(anchor: Anchor.center, scale: Vector2.all(scaleFactor), angle: angle);

  final String bulletSprite;
  late Vector2 forwardDirection;
  final double speed;
  final int damage;
  late Type canHit;

  late SpriteAnimation impactVfx;
  final double maxDistance; 
  double traveledDistance = 0.0; // Distance traveled by the bullet

  @override
  Future<void> onLoad() async {
    sprite = Sprite(game.images.fromCache(bulletSprite));

    CircleHitbox hitbox = CircleHitbox();
    add(hitbox);

    impactVfx = SpriteAnimation.fromFrameData(
      game.images.fromCache("ImpactMedium2.png"),
      SpriteAnimationData.sequenced(amount: 6, stepTime: 0.1, textureSize: Vector2.all(32)),
    );

    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (game.isGamePaused) return;

    position += forwardDirection * speed * dt;
    traveledDistance += speed * dt;

    if (traveledDistance >= maxDistance) {
      deactivate();
    }
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    applyDamage(other, intersectionPoints.first);
    super.onCollisionStart(intersectionPoints, other);
  }

  void spawnImpactVFX(Vector2 position) {
    parent?.add(
      ParticleSystemComponent(
        position: position,
        particle: SpriteAnimationParticle(
          animation: impactVfx,
          size: Vector2.all(32.0),
          lifespan: 0.3,
        ),
      ),
    );
  }

  void reset(Vector2 position, Vector2 direction, double angle) {
    this.position = position;
    forwardDirection = direction;
    this.angle = angle;
    traveledDistance = 0.0; // Reset distance when the bullet is reused
  }

  void applyDamage(PositionComponent other, Vector2 collisionPoint);

  void deactivate() {
    removeFromParent(); 
    // Return to the pool
    _pool.release(this); 
  }

  // A method to set the pool
  late ObjectPool<Bullet> _pool;
  void setPool(ObjectPool<Bullet> pool) {
    _pool = pool;
  }
}

