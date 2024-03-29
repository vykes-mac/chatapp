import 'package:chat/chat.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:rethink_db_ns/rethink_db_ns.dart';

import 'helpers.dart';

class MockUserService extends Mock implements IUserService {
  @override
  Future<List<User>> fetch(List<String?>? id) {
    return super.noSuchMethod(Invocation.method(#fetch, [id]),
        returnValue: Future<List<User>>.value([]));
  }
}

void main() {
  RethinkDb r = RethinkDb();
  Connection? connection;
  late TypingNotification sut;
  MockUserService? userService;

  setUp(() async {
    connection = await r.connect(host: "127.0.0.1", port: 28015);
    userService = MockUserService();
    await createDb(r, connection!);
    sut = TypingNotification(r, connection, userService);
  });

  tearDown(() async {
    sut.dispose();
    await cleanDb(r, connection!);
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
    TypingEvent typingEvent = TypingEvent(
        chatId: '123', from: user2.id, to: user.id, event: Typing.start);

    TypingEvent typingEvent2 = TypingEvent(
        chatId: '123', from: user2.id, to: user2.id, event: Typing.start);

    when(userService!.fetch(any)).thenAnswer((_) async => [user]);

    final res = await sut.send(events: [typingEvent, typingEvent2]);
    expect(res, true);
  });

  test('successfully subscribe and receive typing events', () async {
    sut.subscribe(user2, [user.id]).listen(expectAsync1((event) {
      expect(event.from, user.id);
    }, count: 2));

    when(userService!.fetch(any)).thenAnswer((_) async => [user2]);

    TypingEvent typing = TypingEvent(
      chatId: '123',
      to: user2.id,
      from: user.id,
      event: Typing.start,
    );

    TypingEvent stopTyping = TypingEvent(
      chatId: '123',
      to: user2.id,
      from: user.id,
      event: Typing.stop,
    );

    await sut.send(events: [typing]);
    await sut.send(events: [stopTyping]);
  });
}
