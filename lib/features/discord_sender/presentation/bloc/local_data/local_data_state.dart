import 'package:discord_sender/features/discord_sender/presentation/bloc/message/message_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/group.dart';
import '../../../domain/entities/message.dart';

abstract class LocalDataState extends Equatable {
  final Map<int, MessageEntity>? messages;
  final Map<int, MessageBloc>? messageBlocs;
  final List<GroupEntity>? groups;
  final String? errorMessage;

  const LocalDataState(
      {this.messages, this.groups, this.errorMessage, this.messageBlocs});
}

class LocalDataLoading extends LocalDataState {
  const LocalDataLoading();

  @override
  List<Object> get props => [];
}

class LocalDataDone extends LocalDataState {
  const LocalDataDone(Map<int, MessageEntity> messages,
      List<GroupEntity> groups, Map<int, MessageBloc> messageBlocs)
      : super(messages: messages, groups: groups, messageBlocs: messageBlocs);

  @override
  List<Object> get props => [messages!, groups!, messageBlocs!];
}

class LocalDataError extends LocalDataState {
  const LocalDataError(String errorMessage) : super(errorMessage: errorMessage);

  @override
  List<Object> get props => [];
}
