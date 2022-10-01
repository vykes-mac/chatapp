import 'dart:async';

import 'package:chat/src/models/receipt.dart';
import 'package:chat/src/models/user.dart';
import 'package:chat/src/services/receipt/receipt_service_contract.dart';
import 'package:rethink_db_ns/rethink_db_ns.dart';

class ReceiptService implements IReceiptService {
  final Connection? _connection;
  final RethinkDb _r;

  final _controller = StreamController<Receipt>.broadcast();
  StreamSubscription? _changefeed;

  ReceiptService(this._r, this._connection);

  @override
  Stream<Receipt> receipts(User user) {
    _startReceivingReceipts(user);
    return _controller.stream;
  }

  @override
  Future<bool> send(Receipt receipt) async {
    Map record =
        await (_r.table('receipts').insert(receipt.toJson()).run(_connection!));
    return record['inserted'] == 1;
  }

  @override
  Future<void> dispose() async {
    await _changefeed?.cancel();
    await _controller.close();
  }

  _startReceivingReceipts(User user) {
    _changefeed = _r
        .table('receipts')
        .filter({'recipient': user.id})
        .changes({'include_initial': true})
        .run(_connection!)
        .asStream()
        .cast<Feed>()
        .listen((event) {
          event
              .forEach((feedData) {
                if (feedData['new_val'] == null) return;

                final receipt = _receiptFromFeed(feedData);
                _controller.sink.add(receipt);
                _removeDeliverredReceipt(receipt);
              })
              .catchError((err) => null)
              .onError((dynamic error, stackTrace) => print(error));
        });
  }

  Receipt _receiptFromFeed(feedData) {
    return Receipt.fromJson(feedData['new_val']);
  }

  _removeDeliverredReceipt(Receipt receipt) {
    _r
        .table('receipts')
        .get(receipt.id)
        .delete({'return_changes': false}).run(_connection!);
  }
}
