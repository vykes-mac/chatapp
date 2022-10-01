import 'package:chat/src/models/message.dart';
import 'package:chat/src/models/user.dart';

abstract class IMessageService {
  Future<Message> send(List<Message> message);
  Stream<Message> messages({required User activeUser});
  dispose();
}
