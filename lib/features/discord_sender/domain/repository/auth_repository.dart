import '../../../../core/resources/data_state.dart';

abstract class AuthRepository {
  Future<DataState> init();

  Future<DataState> checkLicense(String key);

  Future<void> checkSession();

  Future<void> closeSession();
}
