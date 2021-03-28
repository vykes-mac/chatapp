import 'package:chat/src/models/session.dart';
import 'package:flutter/foundation.dart';

enum Typing { start, stop }

extension TypingParser on Typing {
  String value() {
    return this.toString().split('.').last;
  }

  static Typing fromString(String event) {
    return Typing.values.firstWhere((element) => element.value() == event);
  }
}

class TypingEvent {
  final String from;
  final String to;
  final Typing event;

  TypingEvent({
    @required this.from,
    @required this.to,
    @required this.event,
  });
}

abstract class ITypingNotification {
  Future<bool> send({@required TypingEvent event});
  Stream<TypingEvent> subscribe(Session session, List<String> sessionIds);
  dispose();
}
