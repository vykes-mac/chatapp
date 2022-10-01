import 'package:chat/src/models/user.dart';
import 'package:chat/src/services/session/user_service_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rethink_db_ns/rethink_db_ns.dart';

import '../services/helpers.dart';

void main() {
  RethinkDb r = RethinkDb();
  Connection? connection;
  late UserService sut;

  setUp(() async {
    connection = await r.connect(
        host: "localhost", port: 28015, user: "admin", password: "");
    await createDb(r, connection!);
    sut = UserService(r, connection);
  });

  tearDown(() async {
    await cleanDb(r, connection!);
  });

  tearDownAll(() {
    r.dbDrop('test').run(connection!).then((value) => print(value));
  });

  test('creates a new user document in database', () async {
    final user = User(
      username: 'test',
      photoUrl: 'url',
      active: true,
      lastSeen: DateTime.now(),
    );
    final userWithId = await sut.connect(user);
    expect(userWithId.id, isNotEmpty);
  });

  test('get online users', () async {
    final user = User(
      username: 'test',
      photoUrl: 'url',
      active: true,
      lastSeen: DateTime.now(),
    );
    //arrange
    await sut.connect(user);
    //act
    final users = await sut.online();
    //assert
    expect(users.length, 1);
  });

  test('get fetch online users by ids', () async {
    final user = User(
      username: 'test',
      photoUrl: 'url',
      active: true,
      lastSeen: DateTime.now(),
    );

    final user2 = User(
      username: 'test',
      photoUrl: 'url',
      active: true,
      lastSeen: DateTime.now(),
    );
    //arrange
    final u1 = await sut.connect(user);
    final u2 = await sut.connect(user2);
    //act
    final users = await sut.fetch([u1.id, u2.id]);
    //assert
    expect(users.length, 2);
  });
}
