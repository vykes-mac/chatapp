import 'dart:async';

import 'package:chat/src/models/message.dart';
import 'package:chat/src/models/user.dart';
import 'package:chat/src/services/encryption/encryption_contract.dart';
import 'package:flutter/material.dart';
import 'package:rethinkdb_dart/rethinkdb_dart.dart';

import 'message_service_contract.dart';

class MessageService implements IMessageService {
  final Connection _connection;
  final Rethinkdb r;

  final _controller = StreamController<Message>.broadcast();
  StreamSubscription _changefeed;
  final IEncryption _encryption;

  MessageService(this.r, this._connection, {IEncryption encryption})
      : _encryption = encryption;

  @override
  Future<bool> send(Message message) async {
    var data = message.toJson();
    if (_encryption != null)
      data['contents'] = _encryption.encrypt(message.contents);
    Map record = await r.table('messages').insert(data).run(_connection);
    return record['inserted'] == 1;
  }

  @override
  Stream<Message> messages({@required User activeUser}) {
    _startReceivingMessages(activeUser);
    return _controller.stream;
  }

  @override
  dispose() {
    _changefeed?.cancel();
    _controller?.close();
  }

  _startReceivingMessages(User user) {
    _changefeed = r
        .table('messages')
        .filter({'to': user.id})
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
                _removeDeliverredMessage(message);
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
    var data = feedData['new_val'];
    if (_encryption != null)
      data['contents'] = _encryption.decrypt(data['contents']);
    return Message.fromJson(data);
  }

  _removeDeliverredMessage(Message message) {
    r
        .table('messages')
        .get(message.id)
        .delete({'return_changes': false}).run(_connection);
  }
}
