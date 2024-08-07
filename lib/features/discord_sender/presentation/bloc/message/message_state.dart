import 'package:discord_sender/features/discord_sender/domain/entities/message.dart';
import 'package:equatable/equatable.dart';

abstract class MessageState extends Equatable {
  final MessageEntity message;
  final bool typing = false;
  final int? repeats;
  final Duration? remaining;

  MessageState({required this.message, remaining, this.repeats})
      : remaining = remaining ?? Duration(seconds: message.timeout);

  @override
  String toString() {
    if (remaining!.inSeconds != 0) {
      return 'Reapeats: ${message.repeats} Time left:${remaining!.inDays != 0 ? ' ${remaining!.inDays} days' : ''}${remaining!.inHours != 0 ? ' ${remaining!.inHours % 24} hours' : ''}${remaining!.inMinutes != 0 ? ' ${remaining!.inMinutes % 60} minutes' : ''}${remaining!.inSeconds != 0 ? ' ${remaining!.inSeconds % 60} seconds' : ''}';
    } else {
      return 'Message sending...';
    }
  }

  @override
  List<Object?> get props => [message, repeats, remaining];
}

class MessageWork extends MessageState {
  MessageWork({required super.message, super.remaining, super.repeats});
}

class MessageSuccess extends MessageState {
  MessageSuccess({required super.message, super.remaining, super.repeats});
}

class MessageFailed extends MessageState {
  MessageFailed({required super.message, super.remaining, super.repeats});
}

class MessageDontWork extends MessageState {
  MessageDontWork({required super.message, super.remaining, super.repeats});
}
