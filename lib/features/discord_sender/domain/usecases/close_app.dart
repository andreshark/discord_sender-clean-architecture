import 'package:discord_sender/features/discord_sender/data/repository/app_data_repository_impl.dart';
import 'package:discord_sender/features/discord_sender/data/repository/auth_repository_impl.dart';
import 'package:window_manager/window_manager.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/group.dart';
import '../entities/message.dart';

class CloseAppUseCase
    implements UseCase<void, (Map<int, MessageEntity>, List<GroupEntity>)> {
  final AuthRepositoryImpl _authRepositoryImpl;
  final AppDataRepositoryImpl _appDataRepositoryImpl;

  CloseAppUseCase(this._authRepositoryImpl, this._appDataRepositoryImpl);

  @override
  Future call({(Map<int, MessageEntity>, List<GroupEntity>)? params}) async {
    await _authRepositoryImpl.closeSession();
    _appDataRepositoryImpl.writeData(params!.$1, params.$2);
    windowManager.destroy();
  }
}
