import 'package:discord_sender/features/discord_sender/presentation/bloc/logs/logs_bloc.dart';
import 'package:discord_sender/features/discord_sender/presentation/bloc/logs/logs_state.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LogsPage extends StatefulWidget {
  const LogsPage({super.key});

  @override
  State<LogsPage> createState() => _LogsPageState();
}

class _LogsPageState extends State<LogsPage> {
  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));

    return BlocBuilder<LogsCubit, LogsState>(
        builder: (BuildContext context, state) {
      return ScaffoldPage(
          header: const PageHeader(
            title: Text('Logs'),
          ),
          content: Padding(
            padding: const EdgeInsets.only(bottom: 15, left: 15, right: 15),
            child: Container(
              constraints: const BoxConstraints.expand(),
              decoration: BoxDecoration(
                  color: FluentTheme.of(context).brightness.isDark
                      ? Colors.grey[140]
                      : Colors.grey[30]), //Colors.white
              child: ListView.builder(
                  itemCount: state.logs.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Text(
                      state.logs[index].$2,
                      style: TextStyle(
                          color: state.logs[index].$1 ??
                              (FluentTheme.of(context).brightness.isDark
                                  ? Colors.white
                                  : Colors.black)),
                    );
                  }),
            ),
          ));
    });
  }
}
