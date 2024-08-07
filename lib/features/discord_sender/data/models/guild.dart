import '../../domain/entities/guild.dart';

class GuildModel extends GuildEntity {
  const GuildModel({
    required super.name,
    required super.avatar,
  });

  factory GuildModel.fromJson(Map<String, dynamic> json) {
    return GuildModel(
      name: json['name'] as String,
      avatar: json['icon'] ?? "",
    );
  }
}
