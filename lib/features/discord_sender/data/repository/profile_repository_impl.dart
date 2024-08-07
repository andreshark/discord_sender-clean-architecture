import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:discord_sender/core/resources/data_state.dart';
import 'package:discord_sender/features/discord_sender/data/data_sources/remote/discord_api_service.dart';
import 'package:discord_sender/features/discord_sender/domain/entities/profile.dart';
import 'package:discord_sender/features/discord_sender/domain/repository/profile_repository.dart';
import 'package:flutter/widgets.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final DiscordApiService _discordApiService;
  final DiscordAvatarService _discordAvatarService;
  const ProfileRepositoryImpl(
      this._discordApiService, this._discordAvatarService);

  @override
  Future<DataState<ProfileEntity>> getProfileData(String token) async {
    try {
      // length must be multiple of four
      String encodedId = token.split('.')[0].length % 4 == 0
          ? token.split('.')[0]
          : token.split('.')[0] + '=' * (token.split('.')[0].length % 4);
      String profileId =
          String.fromCharCodes(base64.decoder.convert(encodedId));
      final httpResponse = await _discordApiService.getProfileData(
        profileId: profileId,
        token: token,
      );

      if (httpResponse.response.statusCode == HttpStatus.ok) {
        // ProfileEntity profileEntity =
        //     ProfileModel.fromJson(httpResponse.data as Map<String, dynamic>);
        return DataSuccess(httpResponse.data);
      } else {
        return DataFailed(DioException(
            error: httpResponse.response.statusMessage,
            response: httpResponse.response,
            type: DioExceptionType.badResponse,
            requestOptions: httpResponse.response.requestOptions));
      }
    } catch (e) {
      return DataFailedMessage(e.toString());
    }
  }

  @override
  Future<DataState<Uint8List>> loadAvatar(
      String token, String profileId, String avatarId) async {
    try {
      final httpResponse = await _discordAvatarService.getAvatar(
          token: token, avatarId: avatarId, profileId: profileId);

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
      debugPrint(e.message);
      return DataFailed(e);
    }
  }
}
