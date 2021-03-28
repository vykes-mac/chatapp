import 'package:chat/src/models/receipt.dart';
import 'package:chat/src/models/session.dart';
import 'package:chat/src/services/receipt/receipt_service_impl.dart';
import 'package:chat/src/services/session/session_service_contract.dart';
import 'package:chat/src/services/session/session_service_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rethinkdb_dart/rethinkdb_dart.dart';

import 'helpers.dart';

void main() {
  Rethinkdb r = Rethinkdb();
  Connection connection;
  ReceiptService sut;
  ISessionService sessionService;

  setUp(() async {
    connection = await r.connect(host: "127.0.0.1", port: 28015);
    await createDb(r, connection);
    sut = ReceiptService(r, connection);
    sessionService = SessionService(r, connection);
  });

  tearDown(() async {
    sut.dispose();
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

  test('sent receipt successfully', () async {
    await sessionService.connect(session);
    Receipt receipt = Receipt(
        id: '123',
        recipient: '444',
        messageId: '1234',
        status: ReceiptStatus.deliverred,
        timestamp: DateTime.now());

    final res = await sut.send(receipt);
    expect(res, true);
  });

  test('successfully subscribe and receive receipts', () async {
    sut.receipts(session2).listen(expectAsync1((receipt) {
          expect(receipt.recipient, session2.id);
        }, count: 2));

    await sessionService.connect(session);
    await sessionService.connect(session2);

    Receipt receipt = Receipt(
        id: '123',
        recipient: session2.id,
        messageId: '1234',
        status: ReceiptStatus.deliverred,
        timestamp: DateTime.now());

    Receipt anotherReceipt = Receipt(
        id: '1235',
        recipient: session2.id,
        messageId: '1234',
        status: ReceiptStatus.read,
        timestamp: DateTime.now());

    await sut.send(receipt);
    await sut.send(anotherReceipt);
  });
}
