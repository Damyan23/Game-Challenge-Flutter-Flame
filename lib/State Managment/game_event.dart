// game_event.dart
abstract class GameEvent {}

class StartGameEvent extends GameEvent {}
class GameOverEvent extends GameEvent {}
class ResetGameEvent extends GameEvent {}
