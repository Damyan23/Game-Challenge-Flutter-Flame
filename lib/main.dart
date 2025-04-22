import 'package:flame/game.dart';
import 'package:flutter/widgets.dart';
import 'package:my_game/my_game.dart';


void main() 
{
    final game = MyGame();
  runApp
  (
    // Use Listeners to track mouse events as the flame on pointer move function only works when the mouse button is not pressed.
    // Also the flame function for on tap up function only works if you click and release the mouse button faset.
    // This is a workaround to get the mouse position and button state.
    Listener
    (
      onPointerHover: (event) 
      {
        MyGame.mousePosition = event.position;
      },
      onPointerMove: (event) 
      {
        MyGame.mousePosition = event.position;
      },
      onPointerDown: (event)
      {

        MyGame.isMouseButtonPressed = true;

      },
      onPointerUp: (event)
      {
        MyGame.isMouseButtonPressed = false;
      },
      child: GameWidget(game: game),
    ),
  );
}
