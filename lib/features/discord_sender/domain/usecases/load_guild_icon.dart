import 'dart:typed_data';
import 'package:discord_sender/core/resources/data_state.dart';
import 'package:discord_sender/features/discord_sender/data/repository/guild_repository_impl.dart';
import '../../../../core/usecase/usecase.dart';

class LoadGuildIConUseCase
    implements UseCase<DataState<Uint8List>, (String, String, String)> {
  final GuildRepositoryImpl _guildRepositoryImpl;

  LoadGuildIConUseCase(this._guildRepositoryImpl);

  @override
  Future<DataState<Uint8List>> call({(String, String, String)? params}) async {
    final dataState = await _guildRepositoryImpl.loadGuildIcon(
        params!.$1, params.$2, params.$3);
    return dataState;
  }
}
