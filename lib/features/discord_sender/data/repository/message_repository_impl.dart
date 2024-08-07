import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:discord_sender/features/discord_sender/data/data_sources/remote/discord_api_service.dart';
import 'package:discord_sender/features/discord_sender/domain/entities/message.dart';
import 'package:discord_sender/features/discord_sender/domain/repository/message_repository.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/resources/data_state.dart';

class MessageRepositoryImpl implements MessageRepository {
  final DiscordApiService _discordApiService;
  const MessageRepositoryImpl(this._discordApiService);

  @override
  Future<DataState> sendMessage(MessageEntity message) async {
    try {
      final multipartFiles = <MultipartFile>[];

      for (var i = 0; i < message.files.length; i++) {
        multipartFiles.add(MultipartFile.fromBytes(
            filename: message.files[i].split('\\').last,
            await File((message.files[i])).readAsBytes()));
      }

      final httpResponse = await _discordApiService.sendMessage(
          channel: message.channel,
          token: message.token,
          tts: false,
          text: message.text,
          files: multipartFiles);

      if (httpResponse.response.statusCode == HttpStatus.ok) {
        var data = httpResponse.data['name'] ?? '';
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
  Future<void> typingImitation(MessageEntity message) async {
    try {
      await _discordApiService.typingImitation(
        channel: message.channel,
        token: message.token,
      );
    } on DioException catch (e) {
      debugPrint(e.message);
    }
  }
}
