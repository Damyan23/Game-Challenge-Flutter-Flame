import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:my_game/State%20Managment/game_event.dart';
import 'package:my_game/enemy.dart';
import 'package:my_game/my_game.dart';
import 'package:my_game/overlays/Upgrades/upgrade.dart';
import 'package:my_game/overlays/Upgrades/upgrade_data.dart';
import 'package:my_game/overlays/Upgrades/upgrade_tier.dart';
import 'package:my_game/overlays/hud.dart';
import 'package:my_game/player_stats.dart';
import 'package:my_game/wave_spawner.dart';
import 'package:flame_audio/flame_audio.dart';

enum PlayerState {
  idle,
  running,
  hit
}

class Player extends SpriteAnimationGroupComponent with HasGameReference<MyGame>, KeyboardHandler, CollisionCallbacks 
{
  Player(Vector2 position)
      : super(position: position, scale: Vector2.all(3), anchor: Anchor.center);

  AudioPlayer? walkingAudio = AudioPlayer();


  late final PlayerStats _stats;

  late final RectangleHitbox _hitBox;

  // Animation Settings
  final double _idleStepTime = 0.07;
  late final SpriteAnimation _idleAnimation;

  final double _runStepTime = 0.065;
  late final SpriteAnimation _runAnimation;

  final double _hitStepTime = 0.07;
  late final SpriteAnimation _hitAnimation;

  // Movement Settings
  late Vector2 _velocity = Vector2.zero();

  bool _isFacingRight = true;
  late Vector2 direction = Vector2.zero();

  bool _canBeHit = true;
  final double _invincibilityDuration = 2;
  double _invincibilityTimer = 3;

  late final WaveSpawner _spawner;

  double _dustTimer = 0;
  int _stepToggle = 0; // 0 for left, 1 for right

  late Hud hud;

  int _footsteps = 0;

  @override
  Future<void> onLoad() async 
  {
    _loadAllAnimations();

    _hitBox = RectangleHitbox.relative(Vector2(0.2, 0.8), parentSize: size, anchor: Anchor.center);
    _hitBox.debugMode = true; // Optional: shows hitbox
    add(_hitBox);

    _spawner = game.level.spawner;

    _stats = game.level.stats;
    await super.onLoad();
  }

  void _loadAllAnimations() {
    _idleAnimation = createSpriteAnimation("Player Idle 48 x 48.png", 12, _idleStepTime, Vector2.all(48));
    _runAnimation = createSpriteAnimation("Player Run 48 x 48.png", 8, _runStepTime, Vector2.all(48));
    _hitAnimation = createSpriteAnimation("Player Hit 48 x 48.png", 4, _hitStepTime, Vector2.all(48));

    animations = {
      PlayerState.idle: _idleAnimation,
      PlayerState.running: _runAnimation,
      PlayerState.hit: _hitAnimation
    };

    current = PlayerState.idle;
  }

  SpriteAnimation createSpriteAnimation(
      String path, int amount, double stepTime, Vector2 textureSize) {
    SpriteAnimationData spriteData =
        SpriteAnimationData.sequenced(amount: amount, stepTime: stepTime, textureSize: textureSize);
    return SpriteAnimation.fromFrameData(game.images.fromCache(path), spriteData);
  }

  @override
  void update(double dt) 
  {
    super.update(dt);

    updatePlayerMovement(dt);
    levelUp();
    die ();
    updateWalkingAudio();

    _dustTimer -= dt;
    if (_dustTimer <= 0 && _velocity.length > 0) 
    {
      spawnDustParticle();
      //FlameAudio.play('DIRT - Walk 1.wav', volume: 0.4);
      _dustTimer = 0.15;
    }

    if (!_canBeHit) 
    {
      _invincibilityTimer -= dt;
      if (_invincibilityTimer <= 0) 
      {
        _canBeHit = true;
        _hitBox.collisionType = CollisionType.active;
      }
    }
  }

  void updateWalkingAudio() async 
  {
    if (_footsteps > 5)
    {
      FlameAudio.play('DIRT - Walk 1.wav', volume: 0.2);
      _footsteps = 0;
    }
  }

  void levelUp ()
  {
    if (_stats.currentXP >= _stats.xpNeededForLevelUp)
    {
      _stats.currentXP = 0;
      _stats.xpNeededForLevelUp += _stats.level * _stats.xpIncreaseFraction;
      onLevelUp();
      hud.setXp(_stats.currentXP, _stats.xpNeededForLevelUp, _stats.level);
    }
  }

  void updatePlayerMovement(double dt) {
    _velocity = direction * _stats.moveSpeed;
    position += _velocity * dt;
    
    // Update animation state
    if (_velocity.length == 0 && _canBeHit) {
      current = PlayerState.idle;
    } 
    else if (_canBeHit)
    {
      current = PlayerState.running;
    }
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) 
  {
    if (game.isGamePaused) return false;

    direction = Vector2.zero();
    
    if (keysPressed.contains(LogicalKeyboardKey.keyA)) {
      direction.x -= 1;
    }
    if (keysPressed.contains(LogicalKeyboardKey.keyD)) {
      direction.x += 1;
    }
    if (keysPressed.contains(LogicalKeyboardKey.keyW)) {
      direction.y -= 1;
    }
    if (keysPressed.contains(LogicalKeyboardKey.keyS)) {
      direction.y += 1;
    }
    if (keysPressed.contains(LogicalKeyboardKey.space)) onLevelUp();

    if (direction.length != 0) 
    {
      direction.normalize();
    }

    if (direction.x < 0 && _isFacingRight) {
      _isFacingRight = false;
      flipHorizontallyAroundCenter();
    } else if (direction.x > 0 && !_isFacingRight) {
      _isFacingRight = true;
      flipHorizontallyAroundCenter();
    }

    return true;
  }

  void takeDamage(int damage) {
    if (_canBeHit) 
    {
      _stats.health -= damage;
      _canBeHit = false;
      _invincibilityTimer = _invincibilityDuration;
      current = PlayerState.hit;
      knockBackEnemies();

      current = PlayerState.hit;

      _hitBox.collisionType = CollisionType.inactive;
    }
  }

  void die ()
  {
    if (_stats.health <= 0) 
    {
      game.gameBloc.add(GameOverEvent());
    }
  }

  void knockBackEnemies() {
    for (int i = 0; i < _spawner.enemies.length; i++) {
      Enemy enemy = _spawner.enemies[i];

      if (enemy.behaviorStrategy.distanceToPlayer.length < 250) {
        enemy.knockbackDirection = -enemy.behaviorStrategy.normalizedDistanceToPlayer;
        enemy.knockbackSpeed = 500;
        enemy.knockbackTime = enemy.knockbackDuration;
      }
    }
  }

  void spawnDustParticle() 
  {
    _footsteps ++;

    final particles = <Particle>[];

    // Toggle between left (0) and right (1) foot
    final isLeftStep = _stepToggle == 0;
    _stepToggle = 1 - _stepToggle;

    // Offsets for left/right steps
    final footOffsetX = isLeftStep ? -10.0 : 10.0;

    // Main step circle
    particles.add(
      MovingParticle(
        from: Vector2.zero(),
        to: Vector2(0, -5),
        lifespan: 0.35,
        child: CircleParticle(
          radius: 4,
          paint: Paint()..color = const Color(0xFFAAAAAA).withValues(alpha: 0.5),
        ),
      ),
    );

    // Slight trailing circle to simulate the second foot dragging back a little
    particles.add(
      MovingParticle(
        from: Vector2(4, 4),
        to: Vector2(6, -4),
        lifespan: 0.45,
        child: CircleParticle(
          radius: 5,
          paint: Paint()..color = const Color(0xFFAAAAAA).withValues(alpha: 0.3),
        ),
      ),
    );

    final particleComponent = ParticleSystemComponent(
      position: position + Vector2(footOffsetX, size.y / 2), // left or right of feet
      anchor: Anchor.center,
      priority: -1,
      particle: ComposedParticle(children: particles),
    );

    parent?.add(particleComponent);
  }
  

  List<Upgrade> rollUpgrades(int count) 
  {
    final upgradeTypes = UpgradeType.values.toList()..shuffle();
    return List.generate(count, (_) {
      final type = upgradeTypes.removeLast();

      return Upgrade
      (
        type: type,
        rarity: getRandomRarity(),
        size: Vector2(300, 500),
      );
    });
  }

  Rarity getRandomRarity() {
    final roll = Random().nextDouble();
    if (roll < 0.6) return Rarity.common;
    if (roll < 0.9) return Rarity.rare;
    return Rarity.epic;
  }

  void onLevelUp() 
  {
    game.isGamePaused = true;
    final upgrades = rollUpgrades(3);
    direction = Vector2.zero();
    _stats.level ++;
    hud.showUpgradePanel(upgrades, onSelect: (upgrade) 
    {
      hud.hideUpgradePanel();
      game.isGamePaused = false;
    });
  }

  void addXp (double amount)
  {
    _stats.currentXP += amount;
    hud.setXp(_stats.currentXP, _stats.xpNeededForLevelUp, _stats.level);
  }
}
