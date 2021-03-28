import 'package:chat/src/models/message.dart';
import 'package:chat/src/models/session.dart';
import 'package:chat/src/services/message/message_service_impl.dart';
import 'package:chat/src/services/session/session_service_contract.dart';
import 'package:chat/src/services/session/session_service_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rethinkdb_dart/rethinkdb_dart.dart';

import 'helpers.dart';

void main() {
  Rethinkdb r = Rethinkdb();
  Connection connection;
  MessageService sut;
  ISessionService sessionService;

  setUp(() async {
    connection = await r.connect(host: "127.0.0.1", port: 28015);
    await createDb(r, connection);
    sut = MessageService(r, connection);
    sessionService = SessionService(r, connection);
  });

  tearDown(() async {
    await sut.dispose();
    await cleanDb(r, connection);
  });

  final session = Session(
    id: '1234',
    active: true,
    lastSeen: DateTime.now(),
  );

  final session2 = Session(
    id: '1111',
    active: true,
    lastSeen: DateTime.now(),
  );
  test('sent message successfully', () async {
    await sessionService.connect(session);
    Message message = Message(
      id: '123',
      from: session.id,
      to: '3456',
      date: DateTime.now(),
      contents: 'this is a message',
    );

    final res = await sut.send(message);
    expect(res, true);
  });

  test('successfully subscribe and receive messages', () async {
    sut.messages(activeSession: session2).listen(expectAsync1((message) {
          expect(message.to, session2.id);
        }, count: 2));

    await sessionService.connect(session);
    await sessionService.connect(session2);

    Message message = Message(
      id: '123',
      from: session.id,
      to: session2.id,
      date: DateTime.now(),
      contents: 'this is a message',
    );

    Message secondMessage = Message(
      id: '1234',
      from: session.id,
      to: session2.id,
      date: DateTime.now(),
      contents: 'this is another message',
    );

    await sut.send(message);
    await sut.send(secondMessage);
  });

  test('successfully subscribe and receive new messages ', () async {
    await sessionService.connect(session);
    await sessionService.connect(session2);

    Message message = Message(
      id: '123',
      from: session.id,
      to: session2.id,
      date: DateTime.now(),
      contents: 'this is a message',
    );

    Message secondMessage = Message(
      id: '1234',
      from: session.id,
      to: session2.id,
      date: DateTime.now(),
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
