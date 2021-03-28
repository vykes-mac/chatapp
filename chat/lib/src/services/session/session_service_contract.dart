import 'package:chat/src/models/session.dart';

abstract class ISessionService {
  Future<bool> connect(Session session);
  Future<List<Session>> online();
  Future<void> disconnect(Session session);
}
