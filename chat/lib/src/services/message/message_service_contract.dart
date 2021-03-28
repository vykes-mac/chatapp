import 'package:chat/src/models/message.dart';
import 'package:chat/src/models/session.dart';
import 'package:flutter/foundation.dart';

abstract class IMessageService {
  Future<bool> send(Message message);
  Stream<Message> messages({@required Session activeSession});
  dispose();
}
