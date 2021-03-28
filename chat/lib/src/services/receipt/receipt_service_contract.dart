import 'package:chat/src/models/receipt.dart';
import 'package:chat/src/models/session.dart';

abstract class IReceiptService {
  Future<bool> send(Receipt receipt);
  Stream<Receipt> receipts(Session session);
  void dispose();
}
