import 'package:discord_sender/features/discord_sender/domain/usecases/check_license.dart';
import 'package:discord_sender/features/discord_sender/presentation/bloc/auth/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/resources/data_state.dart';
import 'auth_event.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final CheckLicenseUseCase _checkLicenseUseCase;

  AuthBloc(this._checkLicenseUseCase) : super(const StartLicenseState()) {
    on<CheckLicense>(checkLicense);
  }

  Future<void> checkLicense(CheckLicense event, Emitter<AuthState> emit) async {
    final dataState = await _checkLicenseUseCase(params: event.key);
    if (dataState is DataSuccess) {
      emit(const ValidLicense());
    }

    if (dataState is DataFailedMessage) {
      emit(NotValidLicense(dataState.errorMessage!));
    }
    if (dataState is DataFailed) {
      emit(NotValidLicense(dataState.error!.error!.toString()));
    }
  }
}
