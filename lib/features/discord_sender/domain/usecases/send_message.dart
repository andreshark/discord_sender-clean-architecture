import 'dart:async';
import 'dart:math';
import 'package:discord_sender/core/resources/data_state.dart';
import 'package:discord_sender/features/discord_sender/data/repository/message_repository_impl.dart';
import 'package:discord_sender/features/discord_sender/domain/entities/message.dart';
import 'package:discord_sender/features/discord_sender/presentation/bloc/logs/logs_bloc.dart';
import 'package:fluent_ui/fluent_ui.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../../injection_container.dart';

class SendMessageUseCase
    implements StreamUseCase<MessageStatus, SendMessageParams> {
  final MessageRepositoryImpl _messageRepositoryImpl;

  SendMessageUseCase(this._messageRepositoryImpl);

  @override
  Stream<MessageStatus> call({SendMessageParams? params}) {
    Timer? timer;
    bool typing = false;
    bool isActive = false;
    int currentRepeats = params!.startRepeats;
    int remaining = params.remaining.inSeconds;
    late StreamController<MessageStatus> controller;

    void stopTimer() {
      timer?.cancel();
      isActive = false;
      timer = null;
    }

    void addEvent(MessageStatus event) {
      if (!controller.isClosed) {
        controller.add(event);
      }
    }

    void startTimer() async {
      if ((timer == null || !isActive) && currentRepeats != 0) {
        isActive = true;
        timer = Timer.periodic(const Duration(seconds: 1), (Timer _) async {
          if (remaining > 0 &&
              (params.startRepeats != currentRepeats || params.firstTimeout) &&
              currentRepeats != 0) {
            remaining -= 1;
            if (!typing && params.typingDelay > remaining) {
              _messageRepositoryImpl.typingImitation(params.message);
              typing = true;
              Future.delayed(const Duration(seconds: 9), () {
                typing = false;
              });
            }
            addEvent(TimerTicked(remaining, currentRepeats));
          } else if (currentRepeats != 0) {
            // выключаем таймер, пока сообщение отправляется
            stopTimer();
            isActive = false;
            DataState ans =
                await _messageRepositoryImpl.sendMessage(params.message);
            if (ans is DataSuccess) {
              sl<LogsCubit>().log(
                  text: 'Message ${params.message.name} has sended.',
                  color: Colors.green);
              currentRepeats -= 1;
              remaining = params.duration.inSeconds +
                  (params.randomDelay != 0
                      ? Random().nextInt(params.randomDelay)
                      : 0);
              addEvent(MessageSend(ans, remaining, currentRepeats));
            } else {
              sl<LogsCubit>().log(
                  text:
                      'Failed to send meesage  ${params.message.name}. ${ans.errorMessage ?? ans.error} ',
                  color: Colors.red);
              addEvent(MessageSend(ans, remaining, currentRepeats));
              await Future.delayed(const Duration(seconds: 15));
            }
            // обратно включаем таймер, после отправки, если остались еще повторения
            //  if (timer.hashCode == _.hashCode) {
            if (!isActive && !controller.isPaused) {
              startTimer();
            }
            //   }
          } else {
            stopTimer();
            addEvent(MessagePause(params.duration.inSeconds));
          }
        });
      } else {
        await Future.delayed(const Duration(milliseconds: 200));
        addEvent(MessagePause(params.duration.inSeconds));
      }
    }

    controller = StreamController<MessageStatus>(
        onListen: null, onPause: stopTimer, onResume: startTimer);

    return controller.stream;
  }
}

abstract class MessageStatus {
  final int? repeats;
  final int? remaining;
  final DataState? mesState;

  const MessageStatus({this.repeats, this.remaining, this.mesState});
}

class TimerTicked extends MessageStatus {
  TimerTicked(remaining, repeats)
      : super(repeats: repeats, remaining: remaining);
}

class MessagePause extends MessageStatus {
  MessagePause(remaining) : super(remaining: remaining);
}

class MessageSend extends MessageStatus {
  MessageSend(mesState, remaining, repeats)
      : super(mesState: mesState, repeats: repeats, remaining: remaining);
}

class SendMessageParams {
  MessageEntity message;
  final int startRepeats;
  int typingDelay;
  int randomDelay;
  final Duration duration;
  Duration remaining;
  final bool firstTimeout;

  SendMessageParams(this.message)
      : duration = Duration(seconds: message.timeout),
        remaining = Duration(seconds: message.timeout),
        firstTimeout = message.firstTimeout,
        startRepeats = message.repeats,
        typingDelay = message.typingDelay,
        randomDelay = message.randomDelay;
}
