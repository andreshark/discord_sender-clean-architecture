import 'dart:math';

import 'package:discord_sender/features/discord_sender/data/models/channel.dart';
import 'package:discord_sender/features/discord_sender/data/models/guild.dart';
import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart' hide Headers;
import '../../../../../core/constants.dart';
import '../../models/profile.dart';
part 'discord_api_service.g.dart';

@RestApi(baseUrl: discordAPIBaseURL)
abstract class DiscordApiService {
  factory DiscordApiService(Dio dio) = _DiscordApiService;

  @POST('/channels/{channel}/messages')
  @MultiPart()
  @Headers(<String, dynamic>{'Content-Type': 'application/json; charset=UTF-8'})
  Future<HttpResponse> sendMessage(
      {@Path('channel') required String channel,
      @Part(name: 'content') String? text,
      @Part(name: 'tts') required bool tts,
      @Header('authorization') required String token,
      @Part() required List<MultipartFile> files});

  @POST('/channels/{channel}/typing')
  Future<HttpResponse<void>> typingImitation({
    @Path('channel') required String channel,
    @Header('authorization') required String token,
  });

  @GET('/users/{profileId}/profile')
  Future<HttpResponse<ProfileModel>> getProfileData({
    @Path('profileId') required String profileId,
    @Header('authorization') required String token,
  });

  @GET('/guilds/{guildId}')
  Future<HttpResponse<GuildModel>> getGuild({
    @Path('guildId') required String guildId,
    @Header('authorization') required String token,
  });

  @GET('/guilds/{guildId}/channels')
  Future<HttpResponse> getGuildChannels({
    @Path('guildId') required String guildId,
    @Header('authorization') required String token,
  });

  @GET('/channels/{channeld}')
  Future<HttpResponse<ChannelModel>> getChannel({
    @Path('channeld') required String channeld,
    @Header('authorization') required String token,
  });
}

@RestApi(baseUrl: discordAvatarBaseURL)
abstract class DiscordAvatarService {
  factory DiscordAvatarService(Dio dio) = _DiscordAvatarService;

  @GET('/avatars/{profileId}/{avatarId}.webp?size=80')
  Future<HttpResponse> getAvatar({
    @DioResponseType(ResponseType.bytes)
    @Path('profileId')
    required String profileId,
    @Path('avatarId') required String avatarId,
    @Header('authorization') required String token,
  });

  @GET('/icons/{guildId}/{avatarId}.webp?size=80')
  Future<HttpResponse> getGuildIcon({
    @DioResponseType(ResponseType.bytes)
    @Path('guildId')
    required String guildId,
    @Path('avatarId') required String avatarId,
    @Header('authorization') required String token,
  });
}
