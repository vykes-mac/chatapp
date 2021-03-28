import 'package:flutter/material.dart';

enum ReceiptStatus { sent, deliverred, read }

extension EnumParsing on ReceiptStatus {
  String value() {
    return this.toString().split('.').last;
  }

  static ReceiptStatus fromString(String status) {
    return ReceiptStatus.values
        .firstWhere((element) => element.value() == status);
  }
}

class Receipt {
  final String id;
  final String recipient;
  final String messageId;
  final ReceiptStatus status;
  final DateTime timestamp;

  Receipt(
      {@required this.id,
      @required this.recipient,
      @required this.messageId,
      @required this.status,
      @required this.timestamp});

  Map<String, dynamic> toJson() => {
        'id': this.id,
        'recipient': this.recipient,
        'message_id': this.messageId,
        'status': status.value(),
        'timestamp': timestamp
      };
}
