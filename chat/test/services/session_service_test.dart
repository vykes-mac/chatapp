import 'package:chat/src/models/session.dart';
import 'package:chat/src/services/session/session_service_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rethinkdb_dart/rethinkdb_dart.dart';

import '../services/helpers.dart';

void main() {
  Rethinkdb r = Rethinkdb();
  Connection connection;
  SessionService sut;

  setUp(() async {
    connection = await r.connect(host: "127.0.0.1", port: 28015);
    await createDb(r, connection);
    sut = SessionService(r, connection);
  });

  tearDown(() async {
    await cleanDb(r, connection);
  });

  tearDownAll(() {
    r.dbDrop('test').run(connection).then((value) => print(value));
  });

  final session = Session(
    id: '1234',
    active: true,
    lastSeen: DateTime.now(),
  );
  test('creates a new session document in database', () async {
    final res = await sut.connect(session);
    expect(res, true);
  });

  test('get online sessions', () async {
    //arrange
    await sut.connect(session);
    //act
    final sessions = await sut.online();
    //assert
    expect(sessions.length, 1);
  });
}
