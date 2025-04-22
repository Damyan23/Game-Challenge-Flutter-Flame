import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/services.dart';
import 'package:my_game/Bullets/player_bullet.dart';
import 'package:my_game/Bullets/ranged_enemy_bullet.dart';
import 'package:my_game/Enemy%20Strategies/enemy_behaviour_strategy.dart';
import 'package:my_game/Enemy%20Strategies/melee_strategy.dart';
import 'package:my_game/Enemy%20Strategies/ranged_strategy.dart';
import 'package:my_game/Pools/object_pool.dart';
import 'package:my_game/State%20Managment/game_event.dart';
import 'package:my_game/enemy.dart';
import 'package:my_game/my_game.dart';
import 'package:my_game/player_stats.dart';
import 'package:my_game/wave_spawner.dart';
import 'player.dart';
import 'gun.dart';
import 'dart:math';


class Level extends World with HasGameReference<MyGame>, KeyboardHandler  
{
  Level();

  late final Player player;
  late final Gun gun;
  late final PlayerStats stats;

  late bool _gunFliped = false;

  late bool isReloading = false;

  late final WaveSpawner spawner;

  late final ObjectPool<PlayerBullet> playerBulletPool;
  late final ObjectPool<RangedEnemyBullet> rangedEnemyBulletPool;

  late final ObjectPool<Enemy> meleeEnemyPool;
  late final ObjectPool<Enemy> rangedEnemyPool;
  final double _baseRangedEnemySpeed = 40;
  final double _baseMeleeEnemySpeed = 50;

  late double gameTimer = 0.0;
  bool _hasGameEnded = false;
  
  @override
  FutureOr<void> onLoad() async 
  {
    stats = PlayerStats();

    initilizePools();

    player = Player(Vector2.zero());
    gun = Gun("gun.png");
    gun.scale = Vector2.all(2.5);
    spawner = WaveSpawner();
    addAll
    ([
      player,
      gun,
      spawner,
    ]);
    

    return super.onLoad();
  }

  void initilizePools ()
  {
    playerBulletPool = ObjectPool<PlayerBullet> (
      create: () => PlayerBullet(
        bulletSprite: "bullet.png",
        forwardDirection: Vector2.zero(),
        speed: 200,
        damage: stats.damage,
        scaleFactor: 0.3,
        angle: 0,
        maxDistance: 1000,
      ),
    );

    rangedEnemyBulletPool = ObjectPool<RangedEnemyBullet> (
      create: () => RangedEnemyBullet(
        bulletSprite: "enemy_bullet.png",
        forwardDirection: Vector2.zero(),
        speed: 70,
        damage: 1,
        scaleFactor: 1,
        angle: 0,
        maxDistance: 1000,
      ),
    );

    meleeEnemyPool = ObjectPool<Enemy>(
    create: () {
      final strategy = MeleeStrategy(
        SpriteAnimationConfig(
          path: 'enemies/mele_enemy.png',
          frameCount: 5,
          frameDuration: 0.1,
          spriteSize: Vector2(64, 64),
        ),
        SpriteAnimationConfig(
          path: 'enemies/mele_enemy.png',
          frameCount: 5,
          frameDuration: 0.15,
          spriteSize: Vector2(64, 64),
        ),
        2.0,
        70,
        0,
        0,
        _baseMeleeEnemySpeed,
        1,
      );

      final enemy = Enemy(Vector2.zero(), "Player Idle 48 x 48.png", strategy)..scale = Vector2.all(1.5);
      enemy.setPool(meleeEnemyPool);
      return enemy;
    },
  );

  rangedEnemyPool = ObjectPool<Enemy>(
    create: () {
      final strategy = RangedStrategy(
        SpriteAnimationConfig(
          path: 'enemies/mage_walk.png',
          frameCount: 6,
          frameDuration: 0.1,
          spriteSize: Vector2(64, 64),
        ),
        SpriteAnimationConfig(
          path: 'enemies/mage_attack.png',
          frameCount: 9,
          frameDuration: 0.15,
          spriteSize: Vector2(64, 64),
        ),
        8.0,
        400,
        0,
        0,
        _baseRangedEnemySpeed,
        1,
        rangedEnemyBulletPool,
      );

      final enemy = Enemy(Vector2.zero(), "Player Idle 48 x 48.png", strategy)..scale = Vector2.all(1.5);
      enemy.setPool(rangedEnemyPool);
      return enemy;
    },
  );
  }

  @override
  void update(double dt) 
  {
    if (game.isGamePaused) return;

    updateGameTimer(dt); // Win Condition (survive for 5 minutes)

    // Calculate world position based on the mouse's current position
    final worldMousePosition = screenToWorld(Vector2(MyGame.mousePosition.dx, MyGame.mousePosition.dy));

    // Update gun position and rotation
    updateGunPosition(worldMousePosition);

    if (worldMousePosition.x < player.position.x && !_gunFliped) 
    {
      gun.flipVerticallyAroundCenter();
      _gunFliped = true;
    } else if (worldMousePosition.x > player.position.x && _gunFliped)
    {
      gun.flipVerticallyAroundCenter();
      _gunFliped = false;
    }

    stats.fireTimer -= dt;
    if (MyGame.isMouseButtonPressed && stats.currentBullets > 0 && !isReloading) 
    {
      if (stats.fireTimer <= 0) 
      {
        shoot();
        stats.fireTimer = stats.fireRate;
      }
    }
    else if (stats.currentBullets <= 0) 
    {
      reloadGun();
    }
 
    if (isReloading) 
    {
      stats.currentReloadTime -= dt;
      if (stats.currentReloadTime <= 0) {
        stats.currentBullets = stats.maxBullets;
        isReloading = false;
      }
    }

    super.update(dt);
  }
  // This method updates the gun's position and rotation
  void updateGunPosition(Vector2 mousePosition) {
    double angle = atan2(mousePosition.y - player.position.y, mousePosition.x - player.position.x);
    double orbitRadius = 60;
    Vector2 orbitOffset = Vector2(cos(angle), sin(angle)) * orbitRadius;
    gun.position = player.position + orbitOffset;

    // Point the gun away from the player
    Vector2 awayFromPlayer = gun.position - player.position;
    gun.angle = atan2(awayFromPlayer.y, awayFromPlayer.x);
  }

  Vector2 screenToWorld(Vector2 screenPosition) {
    return (screenPosition - Vector2(game.size.x / 2, game.size.y / 2)) / game.camera.viewfinder.zoom + game.camera.viewfinder.position;
  }

  void shoot() 
  {
    FlameAudio.play("20 Gauge Single Isolated.mp3", volume: 0.1);
      
    PlayerBullet bullet = playerBulletPool.obtain();
    bullet.setPool(playerBulletPool);
    bullet.reset(gun.position + Vector2(cos(gun.angle), sin(gun.angle)), gun.forwardDirection(), gun.angle);

    stats.currentBullets --;
    add(bullet);
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (keysPressed.contains(LogicalKeyboardKey.keyR))
    {
      reloadGun();
    }
    return super.onKeyEvent(event, keysPressed);
  }

  void reloadGun() {
    if (!isReloading && stats.currentBullets < stats.maxBullets) 
    {
      isReloading = true;
      stats.currentReloadTime = stats.reloadSpeed;
    }
  }

  void updateGameTimer(double dt) {
    if (_hasGameEnded) return;

    gameTimer += dt;

    if (gameTimer >= 300) { // 5 minutes = 300 seconds
      _hasGameEnded = true;
      game.gameBloc.add(GameOverEvent()); // Or whatever your event is called
    }
  }


}
