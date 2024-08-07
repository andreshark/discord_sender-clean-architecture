import 'package:discord_sender/features/discord_sender/domain/entities/profile.dart';

class ProfileModel extends ProfileEntity {
  const ProfileModel({
    super.profileId,
    required super.name,
    super.avatarId,
    super.guilds,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    if (json.keys.contains('code')) {
      return const ProfileModel(name: 'invalid token');
    }

    return ProfileModel(
        profileId: json['user']['id'],
        name: json['user']['global_name'],
        avatarId: json['user']['avatar'] ?? '',
        guilds: (json['mutual_guilds'] as List<dynamic>)
            .map((e) => e['id'] as String)
            .toList());
  }
}
