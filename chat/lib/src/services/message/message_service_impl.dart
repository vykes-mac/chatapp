import 'dart:async';

import 'package:chat/src/models/message.dart';
import 'package:chat/src/models/session.dart';
import 'package:flutter/material.dart';
import 'package:rethinkdb_dart/rethinkdb_dart.dart';

import 'message_service_contract.dart';

class MessageService implements IMessageService {
  final Connection _connection;
  final Rethinkdb r;

  final _controller = StreamController<Message>.broadcast();
  StreamSubscription _changefeed;

  MessageService(this.r, this._connection);

  @override
  Future<bool> send(Message message) async {
    Map record =
        await r.table('messages').insert(message.toJson()).run(_connection);
    return record['inserted'] == 1;
  }

  @override
  Stream<Message> messages({@required Session activeSession}) {
    _startReceivingMessages(activeSession);
    return _controller.stream;
  }

  @override
  dispose() {
    _changefeed?.cancel();
    _controller?.close();
  }

  _startReceivingMessages(Session session) {
    _changefeed = r
        .table('messages')
        .filter({'to': session.id})
        .changes({'include_initial': true})
        .run(_connection)
        .asStream()
        .cast<Feed>()
        .listen((event) {
          event
              .forEach((feedData) {
                if (feedData['new_val'] == null) return;

                final message = _messageFromFeed(feedData);
                _controller.sink.add(message);
              })
              .catchError((err) => print(err))
              .onError((error, stackTrace) => print(error));

          // await for (var feedData in event) {
          //   if (feedData['new_val'] == null) continue;

          //   final message = _messageFromFeed(feedData);
          //   _controller.sink.add(message);
          // }
        });
  }

  Message _messageFromFeed(feedData) {
    return Message(
        id: feedData['new_val']['id'],
        from: feedData['new_val']['from'],
        to: feedData['new_val']['to'],
        contents: feedData['new_val']['contents'],
        date: feedData['new_val']['date']);
  }
}
