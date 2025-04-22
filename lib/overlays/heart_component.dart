import 'package:flame/components.dart';
import 'package:my_game/my_game.dart';

class HeartComponent extends SpriteComponent with HasGameReference<MyGame> {

  HeartComponent
  ({
    required super.position,
    required super.size,
    super.priority,
  });

  @override
  Future<void> onLoad() async 
  {
    await super.onLoad();

    sprite = Sprite (game.images.fromCache ('heart.png'));

    anchor = Anchor.center;
  }

}
