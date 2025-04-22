import 'package:flame/camera.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/widgets.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/services.dart';
import 'package:my_game/State%20Managment/game_bloc.dart';
import 'package:my_game/State%20Managment/game_event.dart';
import 'package:my_game/State%20Managment/game_state.dart';
import 'level.dart';
import 'package:my_game/overlays/hud.dart';
import 'package:my_game/overlays/menu_overlay.dart';

class MyGame extends FlameGame with HasKeyboardHandlerComponents, HasCollisionDetection 
{
  MyGame();

  late final GameBloc gameBloc; // BLoC instance
  late Level level;
  late Hud hud;
  static Offset mousePosition = Offset.zero;
  static bool isMouseButtonPressed = false;
  late CameraComponent _defaultCamera; // An default camera instance, so that after I remove the level from the game, I can set the camera back to this instance

  @override
  Color backgroundColor() => const Color.fromARGB(255, 90, 33, 33);

  late bool isGamePaused = false;


  @override
  Future<void> onLoad() async 
  {
    _defaultCamera = camera;
    // Load assets
    await images.loadAllImages();
    FlameAudio.audioCache.loadAll([
      "Falcon_133 BPM_Full.wav",
      "20 Gauge Burst Isolated.mp3",
    ]);

    // Initialize BLoC
    gameBloc = GameBloc();

    // Set initial state to show the start menu
    gameBloc.add(ResetGameEvent());

    // Listen for state changes and react accordingly
    gameBloc.stream.listen((state) 
    {
      if (state is GameStart) 
      {
        showStartMenu();
      } else if (state is GamePlaying) 
      {
        startGame();
      } else if (state is GameOver) 
      {
        showGameOverMenu();
      }
    });


    FlameAudio.bgm.initialize();
    camera.viewport.anchor = Anchor.topLeft;

    await super.onLoad();
  }

  void showStartMenu() {
    // Clear existing overlays
    camera.viewport.children.whereType<MenuOverlay>().forEach((e) => e.removeFromParent());

    // Add new start menu overlay
    camera.viewport.add(MenuOverlay(
      menuState: MenuState.start,
      onButtonPressed: () 
      {
        gameBloc.add(StartGameEvent());
      },
    )..position = size / 2);
  }

  void showGameOverMenu() 
  {
    level.removeFromParent();
    FlameAudio.bgm.stop();

    camera = _defaultCamera;

    // Clear existing overlays
    camera.viewport.children.whereType<MenuOverlay>().forEach((e) => e.removeFromParent());

    // Add new start menu overlay
    camera.viewport.add(MenuOverlay(
      menuState: MenuState.gameOver,
      onButtonPressed: () 
      {
        gameBloc.add(ResetGameEvent());
      },
    )..position = size / 2);
  }

  void startGame() {
    // Remove menu overlay
    children.whereType<MenuOverlay>().forEach((e) => e.removeFromParent());

    // Reset game state
    level = Level();
    camera = CameraComponent(world: level);

    // Play background music
    FlameAudio.bgm.play("Falcon_133 BPM_Full.wav", volume: 0.1);

    // Set up HUD
    hud = Hud(
      position: Vector2.zero(),
      size: size,
      scale: Vector2.all(1.0),
      anchor: Anchor.topLeft,
    );

    add(level);
    level.player.hud = hud;
    camera.viewport.add(hud);
    camera.follow(level.player);
  }
  

  void resetGame() {
    // Remove menu overlay
    children.whereType<MenuOverlay>().forEach((e) => e.removeFromParent());

    // Reset game state
    level = Level();

    // Set up HUD
    hud = Hud(
      position: Vector2.zero(),
      size: size,
      scale: Vector2.all(1.0),
      anchor: Anchor.topLeft,
    );

    add(level);
    level.player.hud = hud;
    camera.viewport.add(hud);
    camera.follow(level.player);
  }
}
