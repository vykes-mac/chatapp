import 'package:chat/src/models/session.dart';
import 'package:chat/src/services/session/session_service_contract.dart';
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
  Future<void> disconnect(Session session) async {
    await r.table('sessions').update({
      'id': session.id,
      'active': false,
      'last_seen': DateTime.now(),
    }).run(_connection);
    _connection.close();
  }

  @override
  Future<List<Session>> online() async {
    Cursor sessions =
        await r.table('sessions').filter({'active': true}).run(_connection);

    final sessionsList = await sessions.toList();
    return sessionsList
        .map(
          (item) => Session(
              id: item['id'],
              active: item['active'],
              lastSeen: item['last_seen']),
        )
        .toList();
  }
}
