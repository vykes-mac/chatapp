import 'package:chat/src/models/session.dart';
import 'package:chat/src/services/session/session_service_contract.dart';
import 'package:rethinkdb_dart/rethinkdb_dart.dart';

class SessionService implements ISessionService {
  final Connection _connection;
  final Rethinkdb r;

  SessionService(this.r, this._connection);

  @override
  Future<Session> connect({String sessionId}) async {
    var data = {
      'active': true,
      'last_seen': DateTime.now(),
    };
    if (sessionId != null) data['id'] = sessionId;

    final result = await r.table('sessions').insert(data, {
      'conflict': 'update',
      'return_changes': true,
    }).run(_connection);

    return Session.fromJson(result['changes'].first['new_val']);
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
          (item) => Session.fromJson(item),
        )
        .toList();
  }
}
