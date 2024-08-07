import 'package:equatable/equatable.dart';
import '../../../domain/entities/group.dart';
import '../../../domain/entities/message.dart';

abstract class LocalDataEvent extends Equatable {
  final Map<int, MessageEntity>? messages;
  final List<GroupEntity>? groups;
  final GroupEntity? group;
  final MessageEntity? message;
  final int? index;
  final int? oldIndex;
  final int? newIndex;

  const LocalDataEvent(
      {this.oldIndex,
      this.newIndex,
      this.group,
      this.message,
      this.index,
      this.messages,
      this.groups});

  @override
  List<Object> get props => [messages!, groups!];
}

class WriteData extends LocalDataEvent {
  const WriteData();
}

class ReadData extends LocalDataEvent {
  const ReadData();
}

class AddGroup extends LocalDataEvent {
  const AddGroup({required GroupEntity super.group, super.index});
}

class UpdateGroup extends LocalDataEvent {
  const UpdateGroup({required int index, required MessageEntity message})
      : super(index: index, message: message);
}

class UpdateMessage extends LocalDataEvent {
  const UpdateMessage({required MessageEntity message})
      : super(message: message);
}

class UpdateRepeats extends LocalDataEvent {
  const UpdateRepeats({required MessageEntity message})
      : super(message: message);
}

class RemoveGroup extends LocalDataEvent {
  const RemoveGroup({required int index}) : super(index: index);
}

class AddMessage extends LocalDataEvent {
  const AddMessage({required MessageEntity message}) : super(message: message);
}

class RemoveMessage extends LocalDataEvent {
  const RemoveMessage({required MessageEntity message})
      : super(message: message);
}

class CloseApp extends LocalDataEvent {
  const CloseApp();
}
