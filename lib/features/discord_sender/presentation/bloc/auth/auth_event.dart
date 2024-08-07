import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  final String? key;

  const AuthEvent({this.key});

  @override
  List<Object> get props => [key!];
}

class CheckLicense extends AuthEvent {
  const CheckLicense({super.key});
}
