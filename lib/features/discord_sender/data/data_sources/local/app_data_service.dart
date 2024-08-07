import 'package:discord_sender/core/resources/data_state.dart';

import '../../models/group.dart';
import '../../models/keyauth.dart';
import '../../models/message.dart';

abstract class AppDataService {
  Future<void> writeData(Map<int, MessageModel> messages,
      List<GroupModel> groups, KeyauthModel keyauth);

  Future<DataState<(Map<int, MessageModel>, List<GroupModel>)>> readData();

  Future<DataState<String>> getKey();

  Future<void> writeKey(String key);

  Future<void> createJson();
}
