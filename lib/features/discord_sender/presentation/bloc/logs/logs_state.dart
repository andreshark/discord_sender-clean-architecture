import 'package:equatable/equatable.dart';
import 'package:fluent_ui/fluent_ui.dart';

class LogsState extends Equatable {
  final List<(AccentColor?, String)> logs;

  const LogsState({required this.logs});

  @override
  List<Object?> get props => [
        logs,
      ];
}
