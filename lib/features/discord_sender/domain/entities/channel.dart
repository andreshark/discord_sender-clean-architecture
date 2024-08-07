import 'package:equatable/equatable.dart';

class ChannelEntity extends Equatable {
  final String id;
  final String name;
  final String guildId;
  final int type;

  const ChannelEntity(
      {required this.id,
      required this.name,
      required this.guildId,
      required this.type});

  @override
  List<Object?> get props => [id, name, guildId, type];
}
