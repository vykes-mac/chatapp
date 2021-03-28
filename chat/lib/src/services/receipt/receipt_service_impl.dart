import 'dart:async';

import 'package:chat/src/models/receipt.dart';
import 'package:chat/src/models/session.dart';
import 'package:chat/src/services/receipt/receipt_service_contract.dart';
import 'package:rethinkdb_dart/rethinkdb_dart.dart';

class ReceiptService implements IReceiptService {
  final Connection _connection;
  final Rethinkdb _r;

  final _controller = StreamController<Receipt>.broadcast();
  StreamSubscription _changefeed;

  ReceiptService(this._r, this._connection);

  @override
  Stream<Receipt> receipts(Session session) {
    _startReceivingReceipts(session);
    return _controller.stream;
  }

  @override
  Future<bool> send(Receipt receipt) async {
    Map record =
        await _r.table('receipts').insert(receipt.toJson()).run(_connection);
    return record['inserted'] == 1;
  }

  @override
  dispose() {
    _changefeed?.cancel();
    _controller?.close();
  }

  _startReceivingReceipts(Session session) {
    _changefeed = _r
        .table('receipts')
        .filter({'recipient': session.id})
        .changes({'include_initial': true})
        .run(_connection)
        .asStream()
        .cast<Feed>()
        .listen((event) {
          event
              .forEach((feedData) {
                if (feedData['new_val'] == null) return;

                final receipt = _receiptFromFeed(feedData);
                _controller.sink.add(receipt);
              })
              .catchError((err) => print(err))
              .onError((error, stackTrace) => print(error));
        });
  }

  Receipt _receiptFromFeed(feedData) {
    return Receipt(
        id: feedData['new_val']['id'],
        recipient: feedData['new_val']['recipient'],
        messageId: feedData['new_val']['message_id'],
        status: EnumParsing.fromString(feedData['new_val']['status']),
        timestamp: feedData['new_val']['timestamp']);
  }
}
