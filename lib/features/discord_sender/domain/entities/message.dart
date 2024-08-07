import 'package:equatable/equatable.dart';

class MessageEntity extends Equatable {
  const MessageEntity({
    required this.key,
    required this.token,
    required this.name,
    required this.channel,
    required this.text,
    required this.files,
    required this.repeats,
    required this.timeout,
    required this.firstTimeout,
    required this.typingDelay,
    required this.randomDelay,
  });

  final int key;
  final String token;
  final String channel;
  final String text;
  final int timeout;
  final int repeats;
  final bool firstTimeout;
  final String name;
  final List<String> files;
  final int typingDelay;
  final int randomDelay;

  @override
  List<Object?> get props {
    return [
      token,
      channel,
      text,
      timeout,
      repeats,
      firstTimeout,
      name,
      files,
      typingDelay,
      randomDelay,
    ];
  }

  MessageEntity copyWith({
    String? token,
    String? channel,
    String? text,
    List<String>? files,
    int? repeats,
    int? timeout,
    bool? firstTimeout,
    int? typingDelay,
    int? randomDelay,
  }) {
    return MessageEntity(
      key: key,
      token: token ?? this.token,
      name: name,
      channel: channel ?? this.channel,
      text: text ?? this.text,
      files: files ?? this.files,
      repeats: repeats ?? this.repeats,
      timeout: timeout ?? this.timeout,
      firstTimeout: firstTimeout ?? this.firstTimeout,
      typingDelay: typingDelay ?? this.typingDelay,
      randomDelay: randomDelay ?? this.randomDelay,
    );
  }
}
