import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:my_game/level.dart';
import 'package:my_game/overlays/Upgrades/upgrade.dart';
import 'package:my_game/my_game.dart';
import 'package:my_game/overlays/level_bar.dart';
import 'package:my_game/overlays/reload_bar.dart';
import 'package:my_game/player_stats.dart';
import 'heart_component.dart';

class Hud extends PositionComponent with HasGameReference<MyGame>, TapCallbacks {
  Hud
  ({
    super.position,
    super.size,
    super.scale,
    super.angle,
    super.anchor,
    super.children,
    super.priority = 5,
  });

  late final PlayerStats _stats;
  late Level _level;

  late SpriteComponent _crosshair;
  late TextComponent _bulletText;
  late ReloadBar _reloadBar;
  late LevelBar _levelBar;
  late TextComponent _timerText;

  final List<HeartComponent> _hearts = [];

  PositionComponent? _upgradePanel;

  late double _elapsedTime = 0;

  @override
  Future<void> onLoad() async 
  {
    await super.onLoad();
    _level = game.level;
    _stats = _level.stats;

    _levelBar = LevelBar();
    add(_levelBar);

    // Hearts
    for (var i = 0; i < _stats.health; i++) 
    {
      final heart = HeartComponent
      (
        position: Vector2(30 + i * 40, _levelBar.position.y + _levelBar.barHeight + 40),
        size: Vector2.all(32),
      ) ..anchor = Anchor.topLeft;
      _hearts.add(heart);
      add(heart);
    }

    // Crosshair
    final crosshairSprite = await game.loadSprite('crosshair.png');
    _crosshair = SpriteComponent(
      sprite: crosshairSprite,
      size: Vector2.all(32),
      anchor: Anchor.center,
    );
    add(_crosshair);

    // Bullet count next to crosshair
    _bulletText = TextComponent
    (
      text: '0',
      position: Vector2.zero(),
      anchor: Anchor.centerLeft,
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 20,
          color: Colors.white,
        ),
      ),
    );
    add(_bulletText);

        // Timer text
    _timerText = TextComponent(
      text: "00:00",
      position: Vector2(game.size.x - 80, 50),
      anchor: Anchor.topLeft,
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 24,
          color: Colors.white,
        ),
      ),
    );
    add(_timerText);

    _reloadBar = ReloadBar(
    position: Vector2(_crosshair.position.x, _crosshair.position.y - 40),
    size: Vector2(120, 24),
    ) ..anchor = Anchor.center;
  }

  @override
  void update(double dt)
  {
    super.update(dt);

    if (!game.isGamePaused) {
      _elapsedTime = _level.gameTimer;

      final minutes = _elapsedTime ~/ 60;
      final seconds = _elapsedTime.toInt() % 60;
      _timerText.text = "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
    }

    // Move crosshair to mouse position
    _crosshair.position = Vector2(MyGame.mousePosition.dx, MyGame.mousePosition.dy);
    if (game.level.isReloading) 
    {
      if (!contains(_reloadBar))
      {
        add(_reloadBar);
      }
      _reloadBar.setProgress(1.0 - (_stats.currentReloadTime / _stats.reloadSpeed));
    }
    else 
    {
      if (contains(_reloadBar)) 
      {
        remove(_reloadBar);
      }
    }
    _reloadBar.position = _crosshair.position - Vector2(0, 20);

    // Place bullet count to the right of crosshair
    _bulletText.position = _crosshair.position + Vector2(24, 0);
    _bulletText.text = '${_stats.currentBullets}';

    // Update hearts if health changes
    if (_hearts.length != _stats.health) 
    {
      for (final heart in _hearts) 
      {
        remove(heart);
      }

      _hearts.clear();

      for (var i = 0; i < _stats.health; i++) 
      {
        final heart = HeartComponent
        (
          position: Vector2(30 + i * 40, _levelBar.position.y + _levelBar.barHeight + 40),
          size: Vector2.all(32),
        ) ..anchor = Anchor.topLeft;
        _hearts.add(heart);
        add(heart);
      }
    }
  }

  void showUpgradePanel(List<Upgrade> upgrades, {required void Function(Upgrade upgrade) onSelect}) 
  {
    final panel = PositionComponent();
    panel.anchor = Anchor.center;
    final spacing = 30.0;

    final upgradeWidth = upgrades.first.size.x;
    final totalWidth = upgrades.length * upgradeWidth + (upgrades.length - 1) * spacing;

    final panelWidth = totalWidth;
    final panelHeight = upgrades.first.size.y;
    final screenSize = game.size;

    panel.size = Vector2(panelWidth, panelHeight);
    panel.position = screenSize / 2 + Vector2(upgradeWidth / 2, panelHeight / 2);

    for (var i = 0; i < upgrades.length; i++) {
      final upgrade = upgrades[i];
      final x = i * (upgradeWidth + spacing);
      upgrade.position = Vector2(x, 0);

      final originalOnTap = upgrade.onTap;

      upgrade.onTap = () 
      {
        originalOnTap?.call(); // Internal behavior
        onSelect(upgrade);     // External callback
      };

      panel.add(upgrade);
    }

    add(panel);
    _upgradePanel = panel; // Save reference to hide later if needed
  }

  void hideUpgradePanel() {
    if (_upgradePanel != null) 
    {
      remove(_upgradePanel!);
      _upgradePanel = null;
    }
  }


  void setXp (double xp, double xpNeeded, int level) 
  {
    _levelBar.setXP(xp, xpNeeded, level);
  }
}
