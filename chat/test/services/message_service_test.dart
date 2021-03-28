import 'package:chat/src/models/message.dart';
import 'package:chat/src/models/session.dart';
import 'package:chat/src/services/message/message_service_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rethinkdb_dart/rethinkdb_dart.dart';

import 'helpers.dart';

void main() {
  Rethinkdb r = Rethinkdb();
  Connection connection;
  MessageService sut;

  setUp(() async {
    connection = await r.connect(host: "127.0.0.1", port: 28015);
    await createDb(r, connection);
    sut = MessageService(r, connection);
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
  test('sent message successfully', () async {
    Message message = Message(
      from: session.id,
      to: '3456',
      timestamp: DateTime.now(),
      contents: 'this is a message',
    );

    final res = await sut.send(message);
    expect(res, true);
  });

  test('successfully subscribe and receive messages', () async {
    sut.messages(activeSession: session2).listen(expectAsync1((message) {
          expect(message.to, session2.id);
          expect(message.id, isNotEmpty);
        }, count: 2));

    Message message = Message(
      from: session.id,
      to: session2.id,
      timestamp: DateTime.now(),
      contents: 'this is a message',
    );

    Message secondMessage = Message(
      from: session.id,
      to: session2.id,
      timestamp: DateTime.now(),
      contents: 'this is another message',
    );

    await sut.send(message);
    await sut.send(secondMessage);
  });

  test('successfully subscribe and receive new messages ', () async {
    Message message = Message(
      from: session.id,
      to: session2.id,
      timestamp: DateTime.now(),
      contents: 'this is a message',
    );

    Message secondMessage = Message(
      from: session.id,
      to: session2.id,
      timestamp: DateTime.now(),
      contents: 'this is another message',
    );

    await sut.send(message);
    await sut.send(secondMessage).whenComplete(
          () => sut.messages(activeSession: session2).listen(
                expectAsync1((message) {
                  expect(message.to, session2.id);
                }, count: 2),
              ),
        );
  });
}
