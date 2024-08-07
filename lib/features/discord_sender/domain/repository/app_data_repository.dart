import 'package:discord_sender/features/discord_sender/domain/entities/group.dart';
import 'package:discord_sender/features/discord_sender/domain/entities/message.dart';

import '../../../../core/resources/data_state.dart';

abstract class AppDataRepository {
  // API methods
  Future<DataState<(Map<int, MessageEntity>, List<GroupEntity>)>> readData();

  Future<DataState<String>> readKey();

  Future<void> writeData(
      Map<int, MessageEntity> messages, List<GroupEntity> groups);

  Future<void> writeKey(String key);

  Future<void> createJson();
}
