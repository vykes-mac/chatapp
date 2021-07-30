import 'package:chat/chat.dart';
import 'package:chat/src/models/user.dart';
import 'package:chat/src/services/typing/typing_notification.dart';
import 'package:chat/src/services/typing/typing_notification_service_contract.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rethinkdb_dart/rethinkdb_dart.dart';

import 'helpers.dart';

//class MockUserService extends Mock implements IUserService {}

void main() {
  Rethinkdb r = Rethinkdb();
  Connection connection;
  TypingNotification sut;

  setUp(() async {
    connection = await r.connect(host: "127.0.0.1", port: 28015);
    await createDb(r, connection);
    sut = TypingNotification(r, connection, null);
  });

  tearDown(() async {
    sut.dispose();
    await cleanDb(r, connection);
  });

  final user = User.fromJson({
    'id': '1234',
    'active': true,
    'lastSeen': DateTime.now(),
  });

  final user2 = User.fromJson({
    'id': '1111',
    'active': true,
    'lastSeen': DateTime.now(),
  });

  test('sent typing notifcation successfully', () async {
    TypingEvent typingEvent =
        TypingEvent(from: user2.id, to: user.id, event: Typing.start);

    final res = await sut.send(event: typingEvent);
    expect(res, true);
  });

  test('successfully subscribe and receive typing events', () async {
    sut.subscribe(user2, [user.id]).listen(expectAsync1((event) {
      expect(event.from, user.id);
    }, count: 2));

    TypingEvent typing = TypingEvent(
      to: user2.id,
      from: user.id,
      event: Typing.start,
    );

    TypingEvent stopTyping = TypingEvent(
      to: user2.id,
      from: user.id,
      event: Typing.stop,
    );

    await sut.send(event: typing);
    await sut.send(event: stopTyping);
  });
}
