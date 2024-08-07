import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:discord_sender/features/discord_sender/presentation/bloc/edit_message/edit_message_bloc.dart';
import 'package:discord_sender/features/discord_sender/presentation/bloc/logs/logs_bloc.dart';

class AppBlocObserver extends BlocObserver {
  const AppBlocObserver();

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    if (bloc is! LogsCubit && bloc is! EditMessageCubit) {
      super.onChange(bloc, change);
      log('onChange(${bloc.runtimeType}, $change)');
    }
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    log('onError(${bloc.runtimeType}, $error, $stackTrace)');
    super.onError(bloc, error, stackTrace);
  }
}
