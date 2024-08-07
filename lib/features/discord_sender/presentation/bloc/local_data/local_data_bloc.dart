import 'package:discord_sender/features/discord_sender/domain/entities/group.dart';
import 'package:discord_sender/features/discord_sender/presentation/bloc/logs/logs_bloc.dart';
import 'package:flutter/foundation.dart';
import '../../../../../injection_container.dart';
import '../../../domain/entities/message.dart';
import '../../../domain/usecases/load_data.dart';
import '../message/message_bloc.dart';
import 'local_data_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/resources/data_state.dart';
import '../../../domain/usecases/close_app.dart';
import '../../../domain/usecases/save_data.dart';
import 'local_data_event.dart';

class LocalDataBloc extends Bloc<LocalDataEvent, LocalDataState> {
  final LoadDataUseCase _loadDataUseCase;
  final SaveDataUseCase _saveDataUseCase;
  final CloseAppUseCase _closeAppUseCase;

  LocalDataBloc(
      this._loadDataUseCase, this._saveDataUseCase, this._closeAppUseCase)
      : super(const LocalDataLoading()) {
    on<WriteData>(writeData);
    on<ReadData>(readData);
    on<CloseApp>(closeApp);
    on<UpdateGroup>(updateGroup);
    on<AddGroup>(addGroup);
    on<AddMessage>(addMessage);
    on<RemoveMessage>(removeMessage);
    on<RemoveGroup>(removeGroup);
    on<UpdateRepeats>(updateRepeats);
  }

  void writeData(WriteData event, Emitter<LocalDataState> emit) {
    _saveDataUseCase(params: (state.messages!, state.groups!));
    return;
  }

  Future<void> readData(ReadData event, Emitter<LocalDataState> emit) async {
    final dataState = await _loadDataUseCase();
    if (dataState is DataSuccess) {
      Map<int, MessageBloc> messageBlocs = {};
      for (int key in dataState.data!.$1.keys) {
        messageBlocs[key] = MessageBloc(dataState.data!.$1[key]!, sl());
      }

      emit(LocalDataDone(dataState.data!.$1, dataState.data!.$2, messageBlocs));
    }

    if (dataState is DataFailedMessage) {
      emit(LocalDataError(dataState.errorMessage!));
    }
  }

  void updateRepeats(UpdateRepeats event, Emitter<LocalDataState> emit) {
    Map<int, MessageEntity>? messages = state.messages;
    messages![event.message!.key] = event.message!;
    emit(LocalDataDone(messages, state.groups!, state.messageBlocs!));
  }

  void addGroup(AddGroup event, Emitter<LocalDataState> emit) {
    List<GroupEntity>? groups = List.from(state.groups!);
    if (event.index == null) {
      groups.add(event.group!);
    } else {
      groups.insert(event.index!, event.group!);
    }
    _saveDataUseCase(params: (state.messages!, state.groups!));
    emit(LocalDataDone(state.messages!, groups, state.messageBlocs!));
  }

  void updateGroup(UpdateGroup event, Emitter<LocalDataState> emit) {
    List<GroupEntity>? groups = List.from(state.groups!);
    if (!state.groups![event.index! + 1].items.contains(event.message!.key)) {
      groups[event.index! + 1] = groups[event.index! + 1].clone()
        ..items.add(event.message!.key);
    } else {
      groups[event.index! + 1] = groups[event.index! + 1].clone()
        ..items.remove(event.message!.key);
    }
    _saveDataUseCase(params: (state.messages!, groups));
    emit(LocalDataDone(state.messages!, groups, state.messageBlocs!));
  }

  void addMessage(AddMessage event, Emitter<LocalDataState> emit) {
    Map<int, MessageEntity> messages =
        state.messages == null ? {} : Map.from(state.messages!)
          ..[event.message!.key] = event.message!;
    Map<int, MessageBloc> messageBlocs =
        !state.messageBlocs!.containsKey(event.message!.key)
            ? state.messageBlocs!
            : (state.messageBlocs!..[event.message!.key]!.close());
    messageBlocs[event.message!.key] = MessageBloc(event.message!, sl());
    List<GroupEntity>? groups = List.from(state.groups!);
    if (!groups[0].items.contains(event.message!.key)) {
      groups[0].items.add(event.message!.key);
      sl<LogsCubit>()
          .log(text: 'Message ${event.message!.name} successfully created.');
    } else {
      sl<LogsCubit>()
          .log(text: 'Message ${event.message!.name} successfully changed.');
    }
    _saveDataUseCase(params: (messages, state.groups!));
    emit(LocalDataDone(messages, state.groups!, messageBlocs));
  }

  void removeGroup(RemoveGroup event, Emitter<LocalDataState> emit) {
    List<GroupEntity> groups = List.from(state.groups!);
    groups.removeAt(event.index!);
    _saveDataUseCase(params: (state.messages!, groups));
    emit(LocalDataDone(state.messages!, groups, state.messageBlocs!));
  }

  void removeMessage(RemoveMessage event, Emitter<LocalDataState> emit) {
    Map<int, MessageBloc> messageBlocs =
        Map<int, MessageBloc>.of(state.messageBlocs!)
          ..[event.message!.key]!.close();
    Map<int, MessageEntity> messages =
        Map<int, MessageEntity>.of(state.messages!);
    List<GroupEntity> groups = List<GroupEntity>.of(state.groups!);
    messageBlocs.remove(event.message!.key);
    messages.remove(event.message!.key);

    for (int i = 0; i < groups.length; i++) {
      groups[i].items.remove(event.message!.key);
    }

    _saveDataUseCase(params: (messages, groups));
    emit(LocalDataDone(messages, groups, messageBlocs));
  }

  Future<void> closeApp(CloseApp event, Emitter<LocalDataState> emit) async {
    await _closeAppUseCase(params: (state.messages ?? {}, state.groups ?? []));
    return;
  }
}
