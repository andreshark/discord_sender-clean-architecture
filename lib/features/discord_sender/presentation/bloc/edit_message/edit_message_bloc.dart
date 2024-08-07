// ignore_for_file: unused_field

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:bloc/bloc.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:discord_sender/core/resources/data_state.dart';
import 'package:discord_sender/features/discord_sender/domain/usecases/get_channel.dart';
import 'package:discord_sender/features/discord_sender/domain/usecases/get_guild_channels.dart';
import 'package:discord_sender/features/discord_sender/domain/usecases/get_profile_data.dart';
import 'package:discord_sender/features/discord_sender/domain/usecases/load_avatar.dart';
import 'package:discord_sender/features/discord_sender/domain/usecases/load_guild_icon.dart';
import 'package:discord_sender/features/discord_sender/presentation/bloc/edit_message/edit_message_state.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import '../../../domain/entities/channel.dart';
import '../../../domain/entities/guild.dart';
import '../../../domain/entities/message.dart';
import '../../../domain/entities/profile.dart';
import '../../../domain/usecases/get_guilds.dart';

class EditMessageCubit extends Cubit<EditMessageState> {
  EditMessageCubit(
      this._loadAvatarUseCase,
      this._getProfileDataUseCase,
      this._getChannelUseCase,
      this._getGuildsUseCase,
      this._getGuildChannelsUseCase,
      this._loadGuildIConUseCase,
      this._message,
      this._name)
      : super(EditMessageState(
            name: _name,
            message: _message,
            text: _message == null ? '' : _message.text,
            timeout: _message == null ? 1 : _message.timeout,
            token: _message == null ? '' : _message.token,
            repeats: _message == null ? 1 : _message.repeats,
            typingDelay: _message == null ? 0 : _message.typingDelay,
            randomDelay: _message == null ? 0 : _message.randomDelay,
            firstTimeout: _message == null ? false : _message.firstTimeout,
            channel: _message == null
                ? const ChannelEntity(id: '', name: '', guildId: '', type: 0)
                : ChannelEntity(
                    id: _message.channel, name: '', guildId: '', type: 0),
            files: _message == null
                ? const []
                : _message.files.map((e) => File(e)).toList()));

  final LoadAvatarUseCase _loadAvatarUseCase;
  final GetProfileDataUseCase _getProfileDataUseCase;
  final GetChannelUseCase _getChannelUseCase;
  final GetGuildsUseCase _getGuildsUseCase;
  final GetGuildChannelsUseCase _getGuildChannelsUseCase;
  final LoadGuildIConUseCase _loadGuildIConUseCase;
  final MessageEntity? _message;
  final String? _name;
  String? _cachedToken;
  Uint8List? _cachedProfileAvatar;

  String get token => state.token;
  set token(String token) {
    emit(state.copyWith(token: token));
  }

  String get text => state.text;
  set text(String text) {
    emit(state.copyWith(text: text));
  }

  ProfileEntity get profile => state.profile;
  set profile(ProfileEntity profile) {
    emit(state.copyWith(profile: profile));
  }

  int get repeats => state.repeats;
  set repeats(int repeats) {
    emit(state.copyWith(repeats: repeats));
  }

  bool get firstTimeout => state.firstTimeout;
  set firstTimeout(bool firstTimeout) {
    emit(state.copyWith(firstTimeout: firstTimeout));
  }

  bool get isDragging => state.isDragging;
  set isDragging(bool isDragging) {
    emit(state.copyWith(isDragging: isDragging));
  }

  int get timeout => state.timeout;
  set timeout(int timeout) {
    emit(state.copyWith(timeout: timeout));
  }

  int get typingDelay => state.typingDelay;
  set typingDelay(int typingDelay) {
    emit(state.copyWith(typingDelay: typingDelay));
  }

  int get randomDelay => state.randomDelay;
  set randomDelay(int randomDelay) {
    emit(state.copyWith(randomDelay: randomDelay));
  }

  List<File> get files => state.files;
  set files(List<File> files) {
    emit(state.copyWith(files: files));
  }

  bool get errorChannel => state.errorChannel;
  set errorChannel(bool errorChannel) {
    emit(state.copyWith(errorChannel: errorChannel));
  }

  bool get seeToken => state.seeToken;
  set seeToken(bool seeToken) {
    emit(state.copyWith(seeToken: seeToken));
  }

  bool get errorToken => state.errorToken;
  set errorToken(bool errorToken) {
    emit(state.copyWith(errorToken: errorToken));
  }

  ChannelEntity get channel => state.channel;
  set channel(ChannelEntity channel) {
    emit(state.copyWith(channel: channel));
  }

  Map<String, GuildEntity> get guilds => state.guilds;
  set guildAvatar(Map<String, GuildEntity> guilds) {
    emit(state.copyWith(guilds: guilds));
  }

  bool get errorLenFiles => state.errorLenFiles;
  set errorLenFiles(bool errorLenFiles) {
    emit(state.copyWith(errorLenFiles: errorLenFiles));
  }

  String get name {
    return state.name != null ? state.name! : state.message!.name;
  }

  bool get errorSizeFile => state.errorSizeFile;
  set errorSizeFile(bool errorSizeFile) {
    emit(state.copyWith(errorSizeFile: errorSizeFile));
  }

  bool get errorEmptyData => state.errorEmptyData;
  set errorEmptyData(bool errorEmptyData) {
    emit(state.copyWith(errorEmptyData: errorEmptyData));
  }

  void init() async {
    DataState<ChannelEntity> datastate =
        await _getChannelUseCase(params: (token, channel.id));
    if (datastate is DataSuccess) {
      emit(state.copyWith(channel: datastate.data, errorChannel: false));
    }
  }

  Future<Uint8List> loadAvatar() async {
    if (_cachedToken == token) {
      return _cachedProfileAvatar!;
    } else {
      if (String.fromCharCodes(base64.decoder.convert(token.split('.')[0])) ==
          profile.profileId) {
        DataState<Uint8List> data = await _loadAvatarUseCase(
            params: (token, profile.profileId, profile.avatarId));
        if (data is DataSuccess) {
          _cachedProfileAvatar = data.data!;
          _cachedToken = token;
          return _cachedProfileAvatar!;
        } else {
          return Uint8List(1);
        }
      } else {
        return await Future.delayed(
            const Duration(milliseconds: 500), loadAvatar);
      }
    }
  }

  Future<DataState<Uint8List>> loadGuildIcon(
      String guildId, String guildAvatarId) async {
    DataState<Uint8List> dataState =
        await _loadGuildIConUseCase(params: (token, guildId, guildAvatarId));
    return dataState;
  }

  void dragFileEvent(DropDoneDetails url) {
    if (url.files.length + state.files.length > 10) {
      emit(state.copyWith(errorLenFiles: true));
    } else if (url.files
        .any((file) => (File(file.path).lengthSync() / (1024 * 1024)) > 25)) {
      emit(state.copyWith(errorSizeFile: true));
    } else {
      List<File> newFiles = url.files.map((xfile) => File(xfile.path)).toList();
      emit(state.copyWith(
          errorLenFiles: false,
          errorSizeFile: false,
          files: state.files + newFiles));
    }
  }

  Future<void> addFileEvent() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(allowMultiple: true);

    if (result != null) {
      if (result.count + state.files.length > 10) {
        emit(state.copyWith(errorLenFiles: true));
      } else if (result.paths
          .any((path) => (File(path!).lengthSync() / (1024 * 1024)) > 25)) {
        emit(state.copyWith(errorSizeFile: true));
      } else {
        List<File> newFiles = result.paths.map((path) => File(path!)).toList();
        emit(state.copyWith(
            errorLenFiles: false,
            errorSizeFile: false,
            files: state.files + newFiles));
      }
    }
  }

  Future<void> saveEvent(List<int> items) async {
    if (!(token.isEmpty ||
        channel.id.isEmpty ||
        (text.isEmpty && files.isEmpty))) {
      int key = state.message?.key ?? generateKey(items);
      List<File> newFiles = List<File>.from(files);
      for (int i = 0; i < state.files.length; i++) {
        if (!File('saves/${state.files[i].uri.pathSegments.last}')
            .existsSync()) {
          state.files[i]
              .copySync('saves/${state.files[i].uri.pathSegments.last}');
        }
        newFiles[i] = File('saves/${state.files[i].uri.pathSegments.last}');
      }
      emit(SaveMessageState(
          state: state.copyWith(
              message: MessageEntity(
                  key: key,
                  token: token,
                  name: name,
                  channel: channel.id,
                  text: text,
                  files: newFiles.map((file) => file.path).toList(),
                  repeats: repeats,
                  timeout: timeout,
                  firstTimeout: firstTimeout,
                  typingDelay: typingDelay,
                  randomDelay: randomDelay)),
          snackMessage: true));
    } else {
      emit(SaveMessageState(
          state: state.copyWith(
            errorToken: token.isEmpty ? true : false,
            errorEmptyData: text.isEmpty && files.isEmpty ? true : false,
            errorChannel: channel.id.isEmpty ? true : false,
          ),
          snackMessage: false));
    }
  }

  int generateKey(List<int> items) {
    int num = 0;
    final list = List.from(items);
    list.sort();

    for (int i = 0; i < list.length; i++) {
      if (list[i] != i) {
        return num;
      }
      num += 1;
    }

    return num;
  }

  Future<void> onChangeToken(String text) async {
    if (text.isNotEmpty) {
      emit(state.copyWith(errorToken: false, token: text));
      DataState<ProfileEntity> dataState =
          await _getProfileDataUseCase(params: text);
      if (dataState is DataSuccess) {
        emit(state.copyWith(
            errorToken: false, token: text, profile: dataState.data));
      } else {
        emit(state.copyWith(
            errorToken: false,
            token: text,
            profile: const ProfileEntity(name: 'invalid token')));
        // emit(ErrorMessageState(
        //     state: state.copyWith(
        //       token: text,
        //       errorToken: false,
        //     ),
        //     errorMessage: dataState.error!.message!));
      }
    } else {
      emit(state.copyWith(
          errorToken: false,
          token: '',
          profile: const ProfileEntity(name: '')));
    }
  }

  Future<void> onChangeChannel(String channelText) async {
    if (channelText.isNotEmpty) {
      emit(state.copyWith(
          channel: ChannelEntity(
              id: channelText, name: channel.name, guildId: '', type: 0),
          errorChannel: false));
      DataState<ChannelEntity> dataState =
          await _getChannelUseCase(params: (token, channelText));
      if (channelText == channel.id) {
        if (dataState is DataSuccess) {
          emit(state.copyWith(channel: dataState.data, errorChannel: false));
        } else {
          emit(state.copyWith(
              channel: ChannelEntity(
                  id: channelText,
                  name: 'Invalid channel',
                  guildId: '',
                  type: 0),
              errorChannel: false));
        }
      }
    } else {
      emit(state.copyWith(
          channel: const ChannelEntity(id: '', name: '', guildId: '', type: 0),
          errorChannel: false));
    }
  }

  Future<bool> guildsInfo() async {
    if (guilds.isEmpty) {
      var datastate = await _getGuildsUseCase(params: (token, profile.guilds));
      if (datastate is DataSuccess) {
        emit(state.copyWith(guilds: datastate.data));
      } else {
        // emit(ErrorMessageState(
        //     state: state, errorMessage: datastate.error!.message!));
      }
    }
    return true;
  }

  Future<List<TreeViewItem>> channelsInfo(String guildId) async {
    List<TreeViewItem> items = [];

    DataState<Map<dynamic, List<dynamic>>> datastate =
        await _getGuildChannelsUseCase(params: (token, guildId));

    if (datastate is DataSuccess) {
      Map<dynamic, List<dynamic>> data = datastate.data!;

      for (Map<String, dynamic>? parent in data.keys) {
        if (parent == null) {
          items.addAll(List.generate(
              data[parent]!.length,
              (int index) => TreeViewItem(
                    content: Text(data[parent]![index]['name'],
                        style: const TextStyle(fontSize: 16)),
                    value: ChannelEntity(
                        id: data[parent]![index]['id'],
                        name: data[parent]![index]['name'],
                        guildId: guildId,
                        type: data[parent]![index]['type']),
                  )));
        } else {
          items.add(TreeViewItem(
              expanded: false,
              content:
                  Text(parent['name'], style: const TextStyle(fontSize: 16)),
              value: ChannelEntity(
                  id: parent['id'],
                  name: parent['name'],
                  guildId: guildId,
                  type: parent['type']),
              children: List.generate(
                  data[parent]!.length,
                  (int index) => TreeViewItem(
                        content: Text(data[parent]![index]['name'],
                            style: const TextStyle(fontSize: 16)),
                        value: ChannelEntity(
                            id: data[parent]![index]['id'],
                            name: data[parent]![index]['name'],
                            guildId: guildId,
                            type: data[parent]![index]['type']),
                      ))));
        }
      }
    }

    return items;
  }
}
