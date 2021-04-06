import 'package:rethinkdb_dart/rethinkdb_dart.dart';

Future<void> createDb(Rethinkdb r, Connection connection) async {
  await r.dbCreate('test').run(connection).catchError((err) => {});
  await r.tableCreate('users').run(connection).catchError((err) => {});
  await r.tableCreate('messages').run(connection).catchError((err) => {});
  await r.tableCreate('receipts').run(connection).catchError((err) => {});
  await r.tableCreate('typing_events').run(connection).catchError((err) => {});
}

Future<void> cleanDb(Rethinkdb r, Connection connection) async {
  await r.table('users').delete().run(connection);
  await r.table('messages').delete().run(connection);
  await r.table('receipts').delete().run(connection);
  await r.table('typing_events').delete().run(connection);
}
