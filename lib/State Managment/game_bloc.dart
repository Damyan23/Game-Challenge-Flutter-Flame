// game_bloc.dart
import 'package:bloc/bloc.dart';
import 'game_event.dart';
import 'game_state.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  GameBloc() : super(GameStart()) 
  {
    on<StartGameEvent>((event, emit) => emit(GamePlaying()));
    on<GameOverEvent>((event, emit) => emit(GameOver()));
    on<ResetGameEvent>((event, emit) => emit(GameStart()));
  }
}
