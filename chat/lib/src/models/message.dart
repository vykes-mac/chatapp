import 'package:flutter/foundation.dart';

class Message {
  final String from;
  final String to;
  final String id;
  final DateTime date;
  final String contents;

  Message({
    @required this.id,
    @required this.from,
    @required this.to,
    @required this.date,
    @required this.contents,
  });

  toJson() => {
        'id': this.id,
        'from': this.from,
        'to': this.to,
        'date': DateTime.now(),
        'contents': this.contents,
      };
}
