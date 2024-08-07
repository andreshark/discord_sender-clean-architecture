import 'package:discord_sender/features/discord_sender/data/repository/app_data_repository_impl.dart';
import 'package:discord_sender/features/discord_sender/data/repository/auth_repository_impl.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/resources/data_state.dart';
import '../../../../core/usecase/usecase.dart';

class CheckLicenseUseCase implements UseCase<DataState, String> {
  final AuthRepositoryImpl _authRepositoryImpl;
  final AppDataRepositoryImpl _appDataRepositoryImpl;

  CheckLicenseUseCase(this._authRepositoryImpl, this._appDataRepositoryImpl);

  @override
  Future<DataState> call({String? params}) async {
    final String key;
    if (params == null) {
      debugPrint('get key from db');
      final dataState = await _appDataRepositoryImpl.readKey();
      if (dataState is DataSuccess) {
        key = dataState.data!;
      } else {
        _appDataRepositoryImpl.createJson();
        return dataState;
      }
    } else {
      key = params;
    }
    DataState dataState = await _authRepositoryImpl.init();
    if (dataState is DataSuccess) {
      dataState = await _authRepositoryImpl.checkLicense(key);
      if (dataState is DataSuccess) {
        _appDataRepositoryImpl.writeKey(key);
      }
    }

    return dataState;
  }
}
