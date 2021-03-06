import 'package:chat/src/models/session.dart';
import 'package:chat/src/services/session_service_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rethinkdb_dart/rethinkdb_dart.dart';

void main() {
  Rethinkdb r = Rethinkdb();
  Connection connection;
  SessionService sut;
  setUp(() async {
    connection = await r.connect(db: "test", host: "127.0.0.1", port: 28015);
    sut = SessionService(r, connection);
  });

  group('connect', () {
    final session = Session(
      id: '1234',
      active: true,
      lastSeen: DateTime.now(),
    );
    test('creates a new session document in database', () async {
      final res = await sut.connect(session);
      expect(res, true);
    });
  });
}
