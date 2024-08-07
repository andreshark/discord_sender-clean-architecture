import 'package:discord_sender/core/resources/data_state.dart';
import 'package:discord_sender/features/discord_sender/data/repository/guild_repository_impl.dart';
import '../../../../core/usecase/usecase.dart';

class GetGuildChannelsUseCase
    implements
        UseCase<DataState<Map<dynamic, List<dynamic>>>, (String, String)> {
  final GuildRepositoryImpl _guildRepositoryImpl;

  GetGuildChannelsUseCase(this._guildRepositoryImpl);

  @override
  Future<DataState<Map<dynamic, List<dynamic>>>> call(
      {(String, String)? params}) async {
    final dataState =
        await _guildRepositoryImpl.getGuildChannels(params!.$1, params.$2);
    if (dataState is DataSuccess) {
      List<dynamic> parents = dataState.data!
          .map((e) => {
                'id': e['id'],
                'type': e['type'],
                'name': e['name'],
                'parent_id': e['parent_id'],
                'position': e['position']
              })
          .where((element) => element['type'] == 4)
          .toList();
      List<dynamic> channels = dataState.data!
          .map((e) => {
                'id': e['id'],
                'type': e['type'],
                'name': e['name'],
                'parent_id': e['parent_id'],
                'position': e['position']
              })
          .where((element) => element['type'] == 0)
          .toList();
      parents.sort((a, b) => a['position'].compareTo(b['position']));
      channels.sort((a, b) => a['position'].compareTo(b['position']));
      Map<dynamic, List<dynamic>> items = {};
      items[null] =
          channels.where((channel) => channel['parent_id'] == null).toList();

      items.addAll(Map.fromIterables(
          parents,
          List.generate(parents.length, (int index) {
            return channels
                .where(
                    (channel) => channel['parent_id'] == parents[index]['id'])
                .toList();
          })));

      return DataSuccess(items);
    } else {
      return DataFailed(dataState.error!);
    }
  }
}
