import 'package:equatable/equatable.dart';

class ProfileEntity extends Equatable {
  const ProfileEntity({
    this.profileId = '',
    required this.name,
    this.avatarId = '',
    this.guilds = const [],
  });

  final String profileId;
  final String name;
  final String avatarId;
  final List<String> guilds;

  @override
  List<Object?> get props {
    return [profileId, name, avatarId, guilds];
  }
}
