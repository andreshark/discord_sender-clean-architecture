import '../../../../core/resources/data_state.dart';
import '../entities/message.dart';

abstract class MessageRepository {
  // API methods
  Future<DataState> sendMessage(MessageEntity message);

  Future<void> typingImitation(MessageEntity message);
}
