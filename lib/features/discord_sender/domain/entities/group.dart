import 'package:equatable/equatable.dart';

class GroupEntity extends Equatable {
  const GroupEntity({required this.name, required this.items});
  final List<int> items;
  final String name;

  @override
  List<Object?> get props {
    return [items, name];
  }

  GroupEntity clone() {
    return GroupEntity(name: name, items: List.from(items));
  }
}
