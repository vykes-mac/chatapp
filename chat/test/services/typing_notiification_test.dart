import 'package:chat/src/models/session.dart';
import 'package:chat/src/services/typing/typing_notification.dart';
import 'package:chat/src/services/typing/typing_notification_service_contract.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rethinkdb_dart/rethinkdb_dart.dart';

import 'helpers.dart';

void main() {
  Rethinkdb r = Rethinkdb();
  Connection connection;
  TypingNotification sut;

  setUp(() async {
    connection = await r.connect(host: "127.0.0.1", port: 28015);
    await createDb(r, connection);
    sut = TypingNotification(r, connection);
  });

  tearDown(() async {
    sut.dispose();
    await cleanDb(r, connection);
  });

  final session = Session.fromJson({
    'id': '1234',
    'active': true,
    'lastSeen': DateTime.now(),
  });

  final session2 = Session.fromJson({
    'id': '1111',
    'active': true,
    'lastSeen': DateTime.now(),
  });

  test('sent typing notifcation successfully', () async {
    TypingEvent typingEvent =
        TypingEvent(from: session2.id, to: session.id, event: Typing.start);

    final res = await sut.send(event: typingEvent, to: session);
    expect(res, true);
  });

  test('successfully subscribe and receive typing events', () async {
    sut.subscribe(session2, [session.id]).listen(expectAsync1((event) {
      expect(event.from, session.id);
    }, count: 2));

    TypingEvent typing = TypingEvent(
      to: session2.id,
      from: session.id,
      event: Typing.start,
    );

    TypingEvent stopTyping = TypingEvent(
      to: session2.id,
      from: session.id,
      event: Typing.stop,
    );

    await sut.send(event: typing, to: session2);
    await sut.send(event: stopTyping, to: session2);
  });
}
