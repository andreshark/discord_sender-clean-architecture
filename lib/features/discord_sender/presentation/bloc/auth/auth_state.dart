abstract class AuthState {
  final String? errorMessage;

  const AuthState({this.errorMessage});
}

class NotValidLicense extends AuthState {
  const NotValidLicense(String errorMessage)
      : super(errorMessage: errorMessage);
}

class ValidLicense extends AuthState {
  const ValidLicense();
}

class StartLicenseState extends AuthState {
  const StartLicenseState();
}
