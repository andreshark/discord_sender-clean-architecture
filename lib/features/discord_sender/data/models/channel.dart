import '../../domain/entities/channel.dart';

class ChannelModel extends ChannelEntity {
  const ChannelModel(
      {required super.name,
      required super.id,
      required super.guildId,
      super.type = 0});

  factory ChannelModel.fromJson(Map<String, dynamic> json) {
    return ChannelModel(
        name: json['name'] ?? json['recipients'][0]['username'] as String,
        id: json['id'] as String,
        guildId: json['guild_id'] ?? '');
  }
}
