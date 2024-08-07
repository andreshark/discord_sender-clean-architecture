// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:discord_sender/core/resources/data_state.dart';
import 'package:discord_sender/features/discord_sender/data/repository/app_data_repository_impl.dart';

import '../../../../core/usecase/usecase.dart';
import '../entities/group.dart';
import '../entities/message.dart';

class LoadDataUseCase
    implements
        UseCase<DataState<(Map<int, MessageEntity>, List<GroupEntity>)>, void> {
  final AppDataRepositoryImpl _appDataRepositoryImpl;

  LoadDataUseCase(this._appDataRepositoryImpl);

  @override
  Future<DataState<(Map<int, MessageEntity>, List<GroupEntity>)>> call(
      {void params}) async {
    final dataState = await _appDataRepositoryImpl.readData();
    if (dataState is DataSuccess) {
      return DataSuccess<(Map<int, MessageEntity>, List<GroupEntity>)>((
        dataState.data!.$1.map((key, value) => MapEntry(key, value.toEntity())),
        dataState.data!.$2.map((e) => e.toEntity()).toList()
      ));
    } else {
      await _appDataRepositoryImpl.createJson();
      return DataSuccess<(Map<int, MessageEntity>, List<GroupEntity>)>(
          ({}, [GroupEntity(name: "All messages", items: [])]));
    }
  }
}
