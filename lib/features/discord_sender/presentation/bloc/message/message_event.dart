part of 'message_bloc.dart';

abstract class MessageEvent {
  const MessageEvent();
}

final class MessageStatusChanged extends MessageEvent {
  const MessageStatusChanged(this.status);

  final MessageStatus status;
}

class StartMessage extends MessageEvent {
  const StartMessage();
}

class StopMessage extends MessageEvent {
  const StopMessage();
}

class DeleteMessage extends MessageEvent {
  const DeleteMessage();
}
