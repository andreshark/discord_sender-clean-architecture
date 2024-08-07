import 'dart:io';
import 'package:discord_sender/features/discord_sender/domain/entities/channel.dart';
import 'package:discord_sender/features/discord_sender/domain/entities/guild.dart';
import 'package:discord_sender/features/discord_sender/domain/entities/message.dart';
import 'package:equatable/equatable.dart';

import '../../../domain/entities/profile.dart';

class EditMessageState extends Equatable {
  final MessageEntity? message;
  final ProfileEntity profile;
  final String? name;
  final String token;
  final String text;
  final ChannelEntity channel;
  final int repeats;
  final bool firstTimeout;
  final int timeout;
  final int typingDelay;
  final int randomDelay;
  final List<File> files;
  final bool errorChannel;
  final bool errorLenFiles;
  final bool errorSizeFile;
  final bool isDragging;
  final bool seeToken;
  final bool errorToken;
  final Map<String, GuildEntity> guilds;
  final bool errorEmptyData;

  const EditMessageState({
    this.message,
    this.name,
    this.profile = const ProfileEntity(name: ''),
    this.token = '',
    this.channel = const ChannelEntity(id: '', name: '', guildId: '', type: 0),
    this.errorChannel = false,
    this.files = const [],
    this.firstTimeout = false,
    this.repeats = 1,
    this.text = '',
    this.timeout = 1,
    this.randomDelay = 0,
    this.typingDelay = 0,
    this.errorLenFiles = false,
    this.errorSizeFile = false,
    this.isDragging = false,
    this.seeToken = false,
    this.errorToken = false,
    this.guilds = const {},
    this.errorEmptyData = false,
  });

  EditMessageState copyWith({
    MessageEntity? message,
    ProfileEntity? profile,
    String? token,
    String? text,
    ChannelEntity? channel,
    int? repeats,
    bool? firstTimeout,
    int? timeout,
    int? typingDelay,
    int? randomDelay,
    List<File>? files,
    bool? errorChannel,
    bool? errorLenFiles,
    bool? errorSizeFile,
    bool? isDragging,
    bool? seeToken,
    bool? errorToken,
    Map<String, GuildEntity>? guilds,
    bool? errorEmptyData,
  }) =>
      EditMessageState(
        message: message ?? this.message,
        name: name,
        token: token ?? this.token,
        channel: channel ?? this.channel,
        text: text ?? this.text,
        repeats: repeats ?? this.repeats,
        firstTimeout: firstTimeout ?? this.firstTimeout,
        timeout: timeout ?? this.timeout,
        typingDelay: typingDelay ?? this.typingDelay,
        randomDelay: randomDelay ?? this.randomDelay,
        files: files ?? this.files,
        errorChannel: errorChannel ?? this.errorChannel,
        errorLenFiles: errorLenFiles ?? this.errorLenFiles,
        errorSizeFile: errorSizeFile ?? this.errorSizeFile,
        isDragging: isDragging ?? this.isDragging,
        seeToken: seeToken ?? this.seeToken,
        errorToken: errorToken ?? this.errorToken,
        guilds: guilds ?? this.guilds,
        errorEmptyData: errorEmptyData ?? this.errorEmptyData,
        profile: profile ?? this.profile,
      );
//!!!!!!!!!!!!!!!!!!!!
  @override
  List<Object?> get props => [
        message,
        token,
        text,
        channel,
        repeats,
        firstTimeout,
        timeout,
        typingDelay,
        randomDelay,
        files,
        errorChannel,
        errorLenFiles,
        errorSizeFile,
        isDragging,
        seeToken,
        errorToken,
        profile,
        guilds,
        errorEmptyData,
      ];
}

class SaveMessageState extends EditMessageState {
  final bool snackMessage;

  SaveMessageState(
      {required EditMessageState state, required this.snackMessage})
      : super(
          message: state.message,
          name: state.name,
          token: state.token,
          channel: state.channel,
          errorChannel: state.errorChannel,
          files: state.files,
          firstTimeout: state.firstTimeout,
          repeats: state.repeats,
          text: state.text,
          timeout: state.timeout,
          randomDelay: state.randomDelay,
          typingDelay: state.typingDelay,
          errorLenFiles: state.errorLenFiles,
          errorSizeFile: state.errorSizeFile,
          isDragging: state.isDragging,
          seeToken: state.seeToken,
          errorToken: state.errorToken,
          profile: state.profile,
          guilds: state.guilds,
          errorEmptyData: state.errorEmptyData,
        );
  @override
  List<Object?> get props => [
        message,
        token,
        text,
        channel,
        repeats,
        firstTimeout,
        timeout,
        typingDelay,
        randomDelay,
        files,
        errorChannel,
        errorLenFiles,
        errorSizeFile,
        isDragging,
        seeToken,
        errorToken,
        profile,
        guilds,
        errorEmptyData,
        snackMessage
      ];
}

class ErrorMessageState extends EditMessageState {
  final String errorMessage;

  ErrorMessageState(
      {required EditMessageState state, required this.errorMessage})
      : super(
          message: state.message,
          name: state.name,
          token: state.token,
          channel: state.channel,
          errorChannel: state.errorChannel,
          files: state.files,
          firstTimeout: state.firstTimeout,
          repeats: state.repeats,
          text: state.text,
          timeout: state.timeout,
          randomDelay: state.randomDelay,
          typingDelay: state.typingDelay,
          errorLenFiles: state.errorLenFiles,
          errorSizeFile: state.errorSizeFile,
          isDragging: state.isDragging,
          seeToken: state.seeToken,
          errorToken: state.errorToken,
          profile: state.profile,
          guilds: state.guilds,
          errorEmptyData: state.errorEmptyData,
        );

  @override
  List<Object?> get props => [
        message,
        token,
        text,
        channel,
        repeats,
        firstTimeout,
        timeout,
        typingDelay,
        randomDelay,
        files,
        errorChannel,
        errorLenFiles,
        errorSizeFile,
        isDragging,
        seeToken,
        errorToken,
        profile,
        guilds,
        errorEmptyData,
        errorMessage
      ];
}
