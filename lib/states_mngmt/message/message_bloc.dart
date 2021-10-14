import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:chat/chat.dart';
import 'package:equatable/equatable.dart';

part 'message_event.dart';
part 'message_state.dart';

class MessageBloc extends Bloc<MessageEvent, MessageState> {
  MessageBloc(this._messageService) : super(MessageState.initial());

  final IMessageService _messageService;
  StreamSubscription _subscription;

  @override
  Stream<MessageState> mapEventToState(MessageEvent event) async* {
    if (event is Subscribed) {
      await _subscription?.cancel();
      _subscription = _messageService
          .messages(activeUser: event.user)
          .listen((message) => add(_MessageReceived(message)));
    }
    if (event is _MessageReceived) {
      yield MessageState.received(event.message);
    }
    if (event is MessageSent) {
      final message = await _messageService.send(event.messages);
      yield MessageState.sent(message);
    }
  }

  @override
  Future<void> close() {
    print('dispose called');
    _subscription?.cancel();
    _messageService.dispose();
    return super.close();
  }
}
