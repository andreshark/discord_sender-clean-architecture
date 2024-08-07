import 'package:discord_sender/features/discord_sender/data/models/group.dart';
import 'package:discord_sender/features/discord_sender/data/models/message.dart';
import 'package:discord_sender/features/discord_sender/domain/entities/group.dart';
import 'package:discord_sender/features/discord_sender/domain/entities/message.dart';
import 'package:discord_sender/features/discord_sender/domain/repository/app_data_repository.dart';
import '../../../../core/resources/data_state.dart';
import '../data_sources/local/app_data_service_impl.dart';
import '../models/keyauth.dart';

class AppDataRepositoryImpl extends AppDataRepository {
  final AppDataServiceImpl appDataService;
  final KeyauthModel keyauth;

  AppDataRepositoryImpl(this.appDataService, this.keyauth);
  @override
  Future<DataState<(Map<int, MessageModel>, List<GroupModel>)>>
      readData() async {
    return await appDataService.readData();
  }

  @override
  Future<void> writeData(
      Map<int, MessageEntity> messages, List<GroupEntity> groups) async {
    appDataService.writeData(
        messages
            .map((key, value) => MapEntry(key, MessageModel.fromEntity(value))),
        groups.map((e) => GroupModel.fromEntity(e)).toList(),
        keyauth);
  }

  @override
  Future<DataState<String>> readKey() async {
    return await appDataService.getKey();
  }

  @override
  Future<void> writeKey(String key) async {
    appDataService.writeKey(key);
  }

  @override
  Future<void> createJson() async {
    appDataService.createJson();
  }
}
