// ignore_for_file: type_literal_in_constant_pattern

import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:discord_sender/core/resources/data_state.dart';
import 'package:discord_sender/features/discord_sender/domain/usecases/send_message.dart';
import 'package:discord_sender/features/discord_sender/presentation/bloc/message/message_state.dart';
import 'package:logger/logger.dart';
import '../../../../../injection_container.dart';
import '../../../domain/entities/message.dart';
part 'message_event.dart';

class MessageBloc extends Bloc<MessageEvent, MessageState> {
  // ignore: prefer_final_fields
  SendMessageUseCase _sendMessageUseCase;
  late StreamSubscription<MessageStatus> _messageStatusSubscription;

  MessageBloc(MessageEntity message, this._sendMessageUseCase)
      : super(MessageDontWork(message: message)) {
    on<MessageStatusChanged>(messageStatusChanged);
    on<StartMessage>(startMessage);
    on<StopMessage>(stopMessage);
    on<DeleteMessage>(deleteMessage);
    sl<Logger>().d('bloc create');
    _messageStatusSubscription =
        _sendMessageUseCase(params: SendMessageParams(message)).listen(
      (status) => add(MessageStatusChanged(status)),
    )..pause();
  }

  @override
  Future<void> close() {
    _messageStatusSubscription.pause();
    sl<Logger>().d('close event');
    return super.close();
  }

  void messageStatusChanged(
      MessageStatusChanged event, Emitter<MessageState> emit) {
    switch (event.status.runtimeType) {
      case TimerTicked:
        return emit(MessageWork(
            message: state.message,
            remaining: Duration(seconds: event.status.remaining!)));
      case MessagePause:
        _messageStatusSubscription.pause();
        return emit(MessageDontWork(
          message: state.message,
        ));
      case MessageSend:
        {
          if (event.status.mesState is DataSuccess) {
            return emit(MessageSuccess(
                remaining: Duration(seconds: event.status.remaining!),
                message:
                    state.message.copyWith(repeats: event.status.repeats)));
          } else {
            return emit(MessageFailed(
                message: state.message,
                remaining: Duration(seconds: event.status.remaining!)));
          }
        }
    }
  }

  Future<void> startMessage(
    StartMessage event,
    Emitter<MessageState> emit,
  ) async {
    _messageStatusSubscription.resume();
    return emit(
        MessageWork(message: state.message, remaining: state.remaining));
  }

  Future<void> stopMessage(
    StopMessage event,
    Emitter<MessageState> emit,
  ) async {
    _messageStatusSubscription.pause();
    return emit(
        MessageDontWork(message: state.message, remaining: state.remaining));
  }

  Future<void> deleteMessage(
    DeleteMessage event,
    Emitter<MessageState> emit,
  ) async {
    close();
  }
}
