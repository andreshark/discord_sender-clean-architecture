import 'package:discord_sender/core/resources/data_state.dart';
import 'package:discord_sender/features/discord_sender/data/repository/guild_repository_impl.dart';
import 'package:discord_sender/features/discord_sender/domain/entities/guild.dart';
import '../../../../core/usecase/usecase.dart';

class GetGuildsUseCase
    implements
        UseCase<DataState<Map<String, GuildEntity>>, (String, List<String>)> {
  final GuildRepositoryImpl _guildRepositoryImpl;

  GetGuildsUseCase(this._guildRepositoryImpl);

  @override
  Future<DataState<Map<String, GuildEntity>>> call(
      {(String, List<String>)? params}) async {
    final dataState =
        await _guildRepositoryImpl.getGuilds(params!.$1, params.$2);

    return dataState;
  }
}
