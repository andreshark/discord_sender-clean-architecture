import 'package:discord_sender/core/resources/data_state.dart';
import 'package:discord_sender/features/discord_sender/data/repository/profile_repository_impl.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/profile.dart';

class GetProfileDataUseCase
    implements UseCase<DataState<ProfileEntity>, String> {
  final ProfileRepositoryImpl _profileRepositoryImpl;

  GetProfileDataUseCase(this._profileRepositoryImpl);

  @override
  Future<DataState<ProfileEntity>> call({String? params}) async {
    final dataState = await _profileRepositoryImpl.getProfileData(params!);

    return dataState;
  }
}
