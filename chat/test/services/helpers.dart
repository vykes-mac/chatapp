import 'package:rethinkdb_dart/rethinkdb_dart.dart';

Future<void> createDb(Rethinkdb r, Connection connection) async {
  await r.dbCreate('test').run(connection);
  await r.tableCreate('sessions').run(connection);
}

Future<void> dropDb(Rethinkdb r, Connection connection) async {
  await r.dbDrop('test').run(connection);
}
