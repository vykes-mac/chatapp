import 'package:chat/src/models/receipt.dart';
import 'package:chat/src/models/session.dart';
import 'package:chat/src/services/receipt/receipt_service_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rethinkdb_dart/rethinkdb_dart.dart';

import 'helpers.dart';

void main() {
  Rethinkdb r = Rethinkdb();
  Connection connection;
  ReceiptService sut;

  setUp(() async {
    connection = await r.connect(host: "127.0.0.1", port: 28015);
    await createDb(r, connection);
    sut = ReceiptService(r, connection);
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

  test('sent receipt successfully', () async {
    Receipt receipt = Receipt(
        recipient: '444',
        messageId: '1234',
        status: ReceiptStatus.deliverred,
        timestamp: DateTime.now());

    final res = await sut.send(receipt);
    expect(res, true);
  });

  test('successfully subscribe and receive receipts', () async {
    sut.receipts(session).listen(expectAsync1((receipt) {
          expect(receipt.recipient, session.id);
        }, count: 2));

    Receipt receipt = Receipt(
        recipient: session.id,
        messageId: '1234',
        status: ReceiptStatus.deliverred,
        timestamp: DateTime.now());

    Receipt anotherReceipt = Receipt(
        recipient: session.id,
        messageId: '1234',
        status: ReceiptStatus.read,
        timestamp: DateTime.now());

    await sut.send(receipt);
    await sut.send(anotherReceipt);
  });
}
