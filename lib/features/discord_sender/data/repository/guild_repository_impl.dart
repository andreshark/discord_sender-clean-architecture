import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:discord_sender/core/resources/data_state.dart';
import 'package:discord_sender/features/discord_sender/data/data_sources/remote/discord_api_service.dart';
import 'package:discord_sender/features/discord_sender/data/models/channel.dart';
import 'package:discord_sender/features/discord_sender/domain/entities/guild.dart';
import '../../domain/repository/guild_repository.dart';

class GuildRepositoryImpl implements GuildRepository {
  final DiscordApiService _discordApiService;
  final DiscordAvatarService _discordAvatarService;
  const GuildRepositoryImpl(
      this._discordApiService, this._discordAvatarService);

  @override
  Future<DataState<ChannelModel>> getGuildChannel(
      String token, String channeld) async {
    try {
      final httpResponse = await _discordApiService.getChannel(
        channeld: channeld,
        token: token,
      );

      if (httpResponse.response.statusCode == HttpStatus.ok) {
        return DataSuccess(httpResponse.data);
      } else {
        return DataFailed(DioException(
            error: httpResponse.response.statusMessage,
            response: httpResponse.response,
            type: DioExceptionType.badResponse,
            requestOptions: httpResponse.response.requestOptions));
      }
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<List>> getGuildChannels(String token, String guildId) async {
    try {
      final httpResponse = await _discordApiService.getGuildChannels(
        guildId: guildId,
        token: token,
      );

      if (httpResponse.response.statusCode == HttpStatus.ok) {
        var data = httpResponse.data as List<dynamic>;
        return DataSuccess(data);
      } else {
        return DataFailed(DioException(
            error: httpResponse.response.statusMessage,
            response: httpResponse.response,
            type: DioExceptionType.badResponse,
            requestOptions: httpResponse.response.requestOptions));
      }
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<Map<String, GuildEntity>>> getGuilds(
      String token, List<String> guildId) async {
    Map<String, GuildEntity> guilds = {};
    for (int i = 0; i < guildId.length; i++) {
      try {
        final httpResponse = await _discordApiService.getGuild(
          guildId: guildId[i],
          token: token,
        );

        if (httpResponse.response.statusCode == HttpStatus.ok) {
          guilds[guildId[i]] = httpResponse.data;
        } else {
          guilds[guildId[i]] = const GuildEntity(name: '', avatar: '');
        }
      } on DioException {
        guilds[guildId[i]] = const GuildEntity(name: '', avatar: '');
      }
    }

    return DataSuccess(guilds);
  }

  @override
  Future<DataState<Uint8List>> loadGuildIcon(
      String token, String guildId, String avatarId) async {
    try {
      final httpResponse = await _discordAvatarService.getGuildIcon(
          token: token, guildId: guildId, avatarId: avatarId);

      if (httpResponse.response.statusCode == HttpStatus.ok) {
        return DataSuccess(httpResponse.data);
      } else {
        return DataFailed(DioException(
            error: httpResponse.response.statusMessage,
            response: httpResponse.response,
            type: DioExceptionType.badResponse,
            requestOptions: httpResponse.response.requestOptions));
      }
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }
}
