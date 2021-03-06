enum Receipt { sent, deliverred, read }

class Message {
  final String from;
  final String to;
  final String id;
  final DateTime date;
  final String contents;
  Receipt receipt;

  Message(
    this.id,
    this.from,
    this.to,
    this.date,
    this.contents, {
    Receipt receipt,
  }) : this.receipt = receipt;
}
