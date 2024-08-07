import '../../domain/entities/message.dart';

class MessageModel extends MessageEntity {
  const MessageModel({
    required int key,
    required String token,
    required String name,
    required String channel,
    required String text,
    required List<String> files,
    required int repeats,
    required int timeout,
    required bool firstTimeout,
    required int typingDelay,
    required int randomDelay,
  }) : super(
          key: key,
          token: token,
          name: name,
          channel: channel,
          text: text,
          files: files,
          repeats: repeats,
          timeout: timeout,
          firstTimeout: firstTimeout,
          typingDelay: typingDelay,
          randomDelay: randomDelay,
        );

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      key: json['key'] as int,
      token: json['token'] as String,
      name: json['name'] as String,
      channel: json['channel'] as String,
      text: json['text'] as String,
      files: (json['files'] as List<dynamic>).map((e) => e as String).toList(),
      repeats: json['repeats'] as int,
      timeout: json['timeout'] as int,
      firstTimeout: json['firstTimeout'] as bool,
      typingDelay: json['typingDelay'] as int,
      randomDelay: json['randomDelay'] as int,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'key': key,
        'token': token,
        'channel': channel,
        'text': text,
        'timeout': timeout,
        'repeats': repeats,
        'firstTimeout': firstTimeout,
        'name': name,
        'files': files,
        'typingDelay': typingDelay,
        'randomDelay': randomDelay,
      };

  Map<String, dynamic> toJsonMessage() => <String, dynamic>{
        'content': text,
        'tts': false,
      };

  MessageEntity toEntity() {
    return MessageEntity(
        key: key,
        token: token,
        name: name,
        channel: channel,
        text: text,
        files: files,
        repeats: repeats,
        timeout: timeout,
        firstTimeout: firstTimeout,
        typingDelay: typingDelay,
        randomDelay: randomDelay);
  }

  factory MessageModel.fromEntity(MessageEntity entity) {
    return MessageModel(
        key: entity.key,
        token: entity.token,
        name: entity.name,
        channel: entity.channel,
        text: entity.text,
        files: entity.files,
        repeats: entity.repeats,
        timeout: entity.timeout,
        firstTimeout: entity.firstTimeout,
        typingDelay: entity.typingDelay,
        randomDelay: entity.randomDelay);
  }
}
