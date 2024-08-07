import 'package:equatable/equatable.dart';

class GuildEntity extends Equatable {
  const GuildEntity({
    required this.name,
    required this.avatar,
  });

  final String name;
  final String avatar;

  @override
  List<Object?> get props {
    return [
      name,
      avatar,
    ];
  }
}
