import 'dart:async';

import 'package:chat/src/models/session.dart';
import 'package:chat/src/services/typing/typing_notification_service_contract.dart';
import 'package:flutter/foundation.dart';
import 'package:rethinkdb_dart/rethinkdb_dart.dart';

class TypingNotification implements ITypingNotification {
  final Connection _connection;
  final Rethinkdb _r;

  final _controller = StreamController<TypingEvent>.broadcast();
  StreamSubscription _changefeed;

  TypingNotification(this._r, this._connection);

  @override
  Stream<TypingEvent> subscribe(Session session, List<String> sessionIds) {
    _startReceivingTypingEvents(session, sessionIds);
    return _controller.stream;
  }

  @override
  Future<bool> send({@required TypingEvent event, @required Session to}) async {
    if (!to.active) return false;
    Map record = await _r
        .table('typing_events')
        .insert(event.toJson(), {'conflict': 'update'}).run(_connection);
    return record['inserted'] == 1;
  }

  @override
  dispose() {
    _changefeed?.cancel();
    _controller?.close();
  }

  _startReceivingTypingEvents(Session session, List<String> sessionIds) {
    _changefeed = _r
        .table('typing_events')
        .filter((event) {
          return event('to')
              .eq(session.id)
              .and(_r.expr(sessionIds).contains(event('from')));
        })
        .changes({'include_initial': true})
        .run(_connection)
        .asStream()
        .cast<Feed>()
        .listen((event) {
          event
              .forEach((feedData) {
                if (feedData['new_val'] == null) return;

                final typing = _eventFromFeed(feedData);
                _controller.sink.add(typing);
                _removeEvent(typing);
              })
              .catchError((err) => print(err))
              .onError((error, stackTrace) => print(error));
        });
  }

  TypingEvent _eventFromFeed(feedData) {
    return TypingEvent.fromJson(feedData['new_val']);
  }

  _removeEvent(TypingEvent event) {
    _r
        .table('typing_events')
        .get(event.id)
        .delete({'return_changes': false}).run(_connection);
  }
}
