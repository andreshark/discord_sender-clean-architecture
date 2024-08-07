import 'dart:convert';
import 'dart:io';
import 'package:discord_sender/features/discord_sender/data/models/group.dart';
import 'package:discord_sender/features/discord_sender/data/models/message.dart';
import '../../../../../core/constants.dart';
import '../../../../../core/resources/data_state.dart';
import '../../models/keyauth.dart';
import 'app_data_service.dart';

class AppDataServiceImpl implements AppDataService {
  File file = File(dataPath);

  @override
  Future<void> writeData(Map<int, MessageModel> messages,
      List<GroupModel> groups, KeyauthModel keyauth) async {
    List<MessageModel> mes = [];

    for (var i in messages.keys) {
      mes.add(messages[i]!);
    }
    try {
      final String jsonString = jsonEncode({
        'key': keyauth.key,
        'groups': groups,
        'messages': mes,
      });
      file.writeAsStringSync(jsonString);
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<DataState<(Map<int, MessageModel>, List<GroupModel>)>>
      readData() async {
    Map<int, MessageModel> messages = {};
    List<GroupModel> groups = [];
    String contents = await file.readAsString();
    try {
      var jsonResponse = (jsonDecode(contents) as Map<String, dynamic>);

      for (Map<String, dynamic> p in jsonResponse['messages']) {
        MessageModel mes = MessageModel.fromJson(p);
        messages[mes.key] = mes;
        // messageControllers[mes.key] =
        //     MessageController(message: mes, logsController: logsController);
      }

      for (Map<String, dynamic> p in jsonResponse['groups']) {
        GroupModel group = GroupModel.fromJson(p);
        groups.add(group);
      }

      return DataSuccess((messages, groups));
    } catch (e) {
      return const DataFailedMessage('invalid json file, data file recreated');
    }
  }

  @override
  Future<DataState<String>> getKey() async {
    File file = File(dataPath);
    try {
      String contents = await file.readAsString();
      var jsonResponse = (jsonDecode(contents) as Map<String, dynamic>);
      return DataSuccess(jsonResponse['key']);
    } catch (e) {
      return const DataFailedMessage('invalid json file, data file recreated');
    }
  }

  @override
  Future<void> writeKey(String key) async {
    String contents = await file.readAsString();
    try {
      var jsonResponse = jsonDecode(contents);
      jsonResponse['key'] = key;
      file.writeAsStringSync(jsonEncode(jsonResponse));
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<void> createJson() async {
    try {
      Map<String, dynamic> data = {
        'key': '',
        'groups': [
          {"name": "All messages", "items": []}
        ],
        'messages': []
      };
      File file = File(dataPath);
      await file.writeAsString(jsonEncode(data));
    } catch (e) {
      throw Exception(e);
    }
  }
}
