import 'package:chat/chat.dart';
import 'package:chat/src/models/message_group.dart';
import 'package:chat/src/services/group/group_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rethinkdb_dart/rethinkdb_dart.dart';

import 'helpers.dart';

void main() {
  Rethinkdb r = Rethinkdb();
  Connection connection;
  MessageGroupService sut;

  setUp(() async {
    connection = await r.connect(host: "127.0.0.1", port: 28015);
    await createDb(r, connection);
    sut = MessageGroupService(r, connection);
  });

  tearDown(() async {
    sut.dispose();
    await cleanDb(r, connection);
  });

  test('create group successfully', () async {
    MessageGroup group = MessageGroup(
        createdBy: '123', name: 'test', members: List.from(['abc', 'cdd']));

    final res = await sut.create(group);
    expect(res.id, isNotEmpty);
  });

  test('successfully subscribe and receive created groups', () async {
    final User user = User.fromJson({
      'id': '1234',
      'active': true,
      'lastSeen': DateTime.now(),
    });

    final User user2 = User.fromJson({
      'id': 'abc',
      'active': true,
      'lastSeen': DateTime.now(),
    });

    sut.groups(me: user2).listen(expectAsync1((group) {
          expect(group.id, isNotEmpty);
          expect(group.members.length, 2);
        }, count: 2));

    sut.groups(me: user).listen(expectAsync1((group) {
          expect(group.id, isNotEmpty);
          expect(group.members.length, 2);
        }, count: 2));

    MessageGroup group =
        MessageGroup(createdBy: '124', name: 'test', members: ['1234', 'abc']);

    await sut.create(group);
  });
}
