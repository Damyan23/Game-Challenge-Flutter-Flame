import 'dart:async';
import 'dart:math';
import 'package:flame/components.dart';
import 'package:my_game/Bullets/ranged_enemy_bullet.dart';
import 'package:my_game/Pools/object_pool.dart';
import 'package:my_game/enemy.dart';
import 'package:my_game/my_game.dart';

class WaveSpawner extends Component with HasGameReference<MyGame>
{
  List<Enemy> enemies = [];

  final Random _random = Random();
  final double _gameDuration = 300.0; // 5 minutes
  final double _spawnInterval = 5.0; // seconds between waves
  final double _unspawnableRadius = 200.0;

  double _timePassed = 0.0;
  double _timeSinceLastSpawn = 0.0;

  // Base values
  final int _baseEnemyCount = 3;
  final int _baseHealth = 50;
  final double _baseXP = 2;

  late ObjectPool<Enemy> _rangedEnemyPoll;
  late ObjectPool<Enemy> _meleeEnemyPool;
  // ignore: unused_field
  late ObjectPool<RangedEnemyBullet> _rangedEnemyBulletPool;

  @override
  FutureOr<void> onLoad() {
    _rangedEnemyPoll = game.level.rangedEnemyPool;
    _meleeEnemyPool = game.level.meleeEnemyPool;
    _rangedEnemyBulletPool = game.level.rangedEnemyBulletPool;
    return super.onLoad();
  }

  @override
  void update(double dt) 
  {
    super.update(dt);
    if (game.isGamePaused) return;

    _timePassed += dt;
    _timeSinceLastSpawn += dt;

    if (_timePassed >= _gameDuration) return;

    if (_timeSinceLastSpawn >= _spawnInterval) {
      spawnWave();
      _timeSinceLastSpawn = 0.0;
    }
  }

  void spawnWave() 
  {
    final double difficultyMultiplier = _timePassed / _gameDuration; // 0.0 to 1.0

    final int enemiesThisWave = (_baseEnemyCount + difficultyMultiplier * 12).round();
    final int healthThisWave = _baseHealth + difficultyMultiplier.toInt() * 40;
    final double xpThisWave = _baseXP + difficultyMultiplier * 8;

    for (int i = 0; i < enemiesThisWave; i++) {
      final bool isRanged = _random.nextDouble() < 0.25;

      final ObjectPool<Enemy> pool = isRanged ? _rangedEnemyPoll : _meleeEnemyPool;
      final Enemy enemy = pool.obtain();

      enemy.setPool(pool);

      enemy.reset(getValidSpawnPosition(), enemy.behaviorStrategy, healthThisWave, xpThisWave);

      enemies.add(enemy);
      parent?.add(enemy);
    }

  }

  Vector2 getValidSpawnPosition() {
    final playerPos = game.level.player.position;
    final camera = game.camera;
    final zoom = camera.viewfinder.zoom;
    final camCenter = camera.viewfinder.position;
    final screenSize = game.size / zoom;

    // Calculate world corners of the screen
    final halfScreen = screenSize / 2;

    final left = camCenter.x - halfScreen.x;
    final right = camCenter.x + halfScreen.x;
    final top = camCenter.y - halfScreen.y;
    final bottom = camCenter.y + halfScreen.y;

    // Choose a side: 0 = top, 1 = bottom, 2 = left, 3 = right
    final side = _random.nextInt(4);
    double x, y;

    switch (side) {
      case 0: // Top
        x = _random.nextDouble() * (right - left) + left;
        y = top - 50;
        break;
      case 1: // Bottom
        x = _random.nextDouble() * (right - left) + left;
        y = bottom + 50;
        break;
      case 2: // Left
        x = left - 50;
        y = _random.nextDouble() * (bottom - top) + top;
        break;
      case 3: // Right
      default:
        x = right + 50;
        y = _random.nextDouble() * (bottom - top) + top;
        break;
    }

    Vector2 pos = Vector2(x, y);
    // Still make sure it's not too close to the player (e.g. if camera is zoomed out)
    if ((pos - playerPos).length < _unspawnableRadius) {
      return getValidSpawnPosition();
    }
    return pos;
  }

}
