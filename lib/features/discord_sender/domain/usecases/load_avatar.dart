import 'dart:typed_data';
import 'package:discord_sender/core/resources/data_state.dart';
import 'package:discord_sender/features/discord_sender/data/repository/profile_repository_impl.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/usecase/usecase.dart';

class LoadAvatarUseCase
    implements UseCase<DataState<Uint8List>, (String, String, String)> {
  final ProfileRepositoryImpl _profileRepositoryImpl;

  LoadAvatarUseCase(this._profileRepositoryImpl);

  @override
  Future<DataState<Uint8List>> call({(String, String, String)? params}) async {
    final dataState = await _profileRepositoryImpl.loadAvatar(
        params!.$1, params.$2, params.$3);
    return dataState;
  }
}
