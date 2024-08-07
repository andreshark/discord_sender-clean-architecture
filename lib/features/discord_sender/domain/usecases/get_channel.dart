import 'package:discord_sender/core/resources/data_state.dart';
import 'package:discord_sender/features/discord_sender/data/repository/guild_repository_impl.dart';
import 'package:discord_sender/features/discord_sender/domain/entities/channel.dart';
import '../../../../core/usecase/usecase.dart';

class GetChannelUseCase
    implements UseCase<DataState<ChannelEntity>, (String, String)> {
  final GuildRepositoryImpl _guildRepositoryImpl;

  GetChannelUseCase(this._guildRepositoryImpl);

  @override
  Future<DataState<ChannelEntity>> call({(String, String)? params}) async {
    final dataState =
        await _guildRepositoryImpl.getGuildChannel(params!.$1, params.$2);
    return dataState;
  }
}
