import 'package:chat/src/models/session.dart';
import 'package:chat/src/services/session_service.dart';
import 'package:rethinkdb_dart/rethinkdb_dart.dart';

class SessionService implements ISessionService {
  final Connection _connection;
  final Rethinkdb r;

  SessionService(this.r, this._connection);

  @override
  Future<bool> connect(Session session) async {
    var isConnected = false;
    await r
        .table('sessions')
        .insert({
          'id': session.id,
          'active': session.active,
          'last_seen': session.lastSeen,
        }, {
          'conflict': 'update'
        })
        .run(_connection)
        .then((_) => isConnected = true);
    return isConnected;
  }

  @override
  Future<bool> disconnect(Session session) {
    // TODO: implement disconnect
    throw UnimplementedError();
  }

  @override
  Future<List<Session>> online() {
    // TODO: implement online
    throw UnimplementedError();
  }
}
