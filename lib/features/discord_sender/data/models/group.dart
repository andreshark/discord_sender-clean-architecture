import '../../domain/entities/group.dart';

class GroupModel extends GroupEntity {
  const GroupModel({required super.name, required super.items});

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
        name: json['name'] as String,
        items: (json['items'] as List<dynamic>).map((e) => e as int).toList());
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'name': name,
        'items': items,
      };

  factory GroupModel.fromEntity(GroupEntity entity) {
    return GroupModel(name: entity.name, items: entity.items);
  }

  GroupEntity toEntity() {
    return GroupEntity(name: name, items: items);
  }
}
