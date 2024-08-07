import 'package:bloc/bloc.dart';
import 'package:discord_sender/features/discord_sender/presentation/bloc/logs/logs_state.dart';
import 'package:fluent_ui/fluent_ui.dart';

class LogsCubit extends Cubit<LogsState> {
  LogsCubit()
      : super(const LogsState(
          logs: [],
        ));

  void log({required String text, AccentColor? color}) {
    DateTime now = DateTime.now();
    emit(LogsState(
        logs: List.from(state.logs)
          ..add((
            color,
            '[ ${twoDigits(now.hour)}:${twoDigits(now.minute)}:${twoDigits(now.second)}] $text'
          ))));
  }
}

String twoDigits(int n) => n.toString().padLeft(2, "0");
