import 'package:dio/dio.dart';
import 'package:discord_sender/core/resources/data_state.dart';
import 'package:discord_sender/features/discord_sender/data/data_sources/remote/discord_api_service.dart';
import 'package:discord_sender/features/discord_sender/data/repository/message_repository_impl.dart';
import 'package:discord_sender/features/discord_sender/domain/entities/message.dart';
import 'package:flutter_test/flutter_test.dart';

void main() async {
  group('send messages', () {
    final discordApiService = DiscordApiService(Dio());
    final messageRepositoryImpl = MessageRepositoryImpl(discordApiService);

    test('send message with text', () async {
      const message = MessageEntity(
          key: 1,
          token:
              'OTA3MTY4MzM2NjYyNjM0NTI5.G985Be.YFTg2j8CwbRytKaFWvsKmYHIjrWaH_DTc65eyQ',
          name: 'name',
          channel: '1227646949931483218',
          text: 'new cool text',
          files: [],
          repeats: 1,
          timeout: 1,
          firstTimeout: true,
          typingDelay: 1,
          randomDelay: 1);

      final result = await messageRepositoryImpl.sendMessage(message);
      expect(result.runtimeType, DataSuccess<dynamic>);
    });
    test('send message text and images', () async {
      const message = MessageEntity(
          key: 1,
          token:
              'OTA3MTY4MzM2NjYyNjM0NTI5.G985Be.YFTg2j8CwbRytKaFWvsKmYHIjrWaH_DTc65eyQ',
          name: 'name',
          channel: '1227646949931483218',
          text: 'message text and images',
          files: [
            'lib/test/134.png',
            'lib/test/400.png',
            'lib/test/134.png',
            'lib/test/134.png',
            'lib/test/134.png',
            'lib/test/134.png',
            'lib/test/134.png',
            'lib/test/134.png',
            'lib/test/134.png'
          ],
          repeats: 1,
          timeout: 1,
          firstTimeout: true,
          typingDelay: 1,
          randomDelay: 1);

      final result = await messageRepositoryImpl.sendMessage(message);
      expect(result.runtimeType, DataSuccess<dynamic>);
    });

    test('send message text and image', () async {
      const message = MessageEntity(
          key: 1,
          token:
              'OTA3MTY4MzM2NjYyNjM0NTI5.G985Be.YFTg2j8CwbRytKaFWvsKmYHIjrWaH_DTc65eyQ',
          name: 'one image test and text',
          channel: '1227646949931483218',
          text: 'fedor2004',
          files: [
            'lib/test/134.png',
          ],
          repeats: 1,
          timeout: 1,
          firstTimeout: true,
          typingDelay: 1,
          randomDelay: 1);

      final result = await messageRepositoryImpl.sendMessage(message);
      expect(result.runtimeType, DataSuccess<dynamic>);
    });

    test('send message  image', () async {
      const message = MessageEntity(
          key: 1,
          token:
              'OTA3MTY4MzM2NjYyNjM0NTI5.G985Be.YFTg2j8CwbRytKaFWvsKmYHIjrWaH_DTc65eyQ',
          name: 'name',
          channel: '1227646949931483218',
          text: '',
          files: [
            'lib/test/134.png',
          ],
          repeats: 1,
          timeout: 1,
          firstTimeout: true,
          typingDelay: 1,
          randomDelay: 1);

      final result = await messageRepositoryImpl.sendMessage(message);
      expect(result.runtimeType, DataSuccess<dynamic>);
    });

    test('send message throw error without data', () async {
      const message = MessageEntity(
          key: 1,
          token:
              'OTA3MTY4MzM2NjYyNjM0NTI5.G985Be.YFTg2j8CwbRytKaFWvsKmYHIjrWaH_DTc65eyQ',
          name: 'name',
          channel: '1227646949931483218',
          text: '',
          files: [],
          repeats: 1,
          timeout: 1,
          firstTimeout: true,
          typingDelay: 1,
          randomDelay: 1);

      final result = await messageRepositoryImpl.sendMessage(message);
      expect(result.runtimeType, DataFailed<dynamic>);
    });
  });
}
