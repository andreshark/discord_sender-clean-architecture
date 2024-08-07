import 'package:discord_sender/features/discord_sender/presentation/bloc/logs/logs_bloc.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:logger/logger.dart';

class LogsOutput extends LogOutput {
  final LogsCubit cubit;

  LogsOutput({required this.cubit});

  @override
  void output(OutputEvent event) {
    cubit.log(
        text: ('${event.origin.level} ${event.origin.message}'),
        color: levelColor[event.origin.level]);
    for (var line in event.lines) {
      cubit.log(text: line, color: levelColor[event.origin.level]);
      print(line);
    }
  }
}

Map<Level, AccentColor> levelColor = {
  Level.error: Colors.red,
  Level.info: Colors.blue,
  Level.warning: Colors.orange,
  Level.fatal: Colors.red,
};
