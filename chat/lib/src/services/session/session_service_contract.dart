import 'package:chat/src/models/session.dart';

abstract class ISessionService {
  Future<Session> connect({String sessionId});
  Future<List<Session>> online();
  Future<void> disconnect(Session session);
}
