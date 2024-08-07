import 'package:discord_sender/features/discord_sender/domain/entities/channel.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/resources/data_state.dart';
import '../entities/guild.dart';

abstract class GuildRepository {
  // API methods
  Future<DataState<Map<String, GuildEntity>>> getGuilds(
      String token, List<String> guildId);

  Future<DataState<List<dynamic>>> getGuildChannels(
      String token, String guildId);

  Future<DataState<ChannelEntity>> getGuildChannel(
      String token, String channeld);

  Future<DataState<Uint8List>> loadGuildIcon(
      String token, String guildId, String avatarId);
}
