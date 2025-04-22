// game_state.dart
abstract class GameState {}

class GameStart extends GameState {}
class GamePlaying extends GameState {}
class GameOver extends GameState {}
