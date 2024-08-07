import 'package:discord_sender/features/discord_sender/data/repository/app_data_repository_impl.dart';

import '../../../../core/usecase/usecase.dart';
import '../entities/group.dart';
import '../entities/message.dart';

class SaveDataUseCase
    implements UseCase<void, (Map<int, MessageEntity>, List<GroupEntity>)> {
  final AppDataRepositoryImpl _appDataRepositoryImpl;

  SaveDataUseCase(this._appDataRepositoryImpl);

  @override
  Future<void> call({(Map<int, MessageEntity>, List<GroupEntity>)? params}) {
    return _appDataRepositoryImpl.writeData(params!.$1, params.$2);
  }
}
