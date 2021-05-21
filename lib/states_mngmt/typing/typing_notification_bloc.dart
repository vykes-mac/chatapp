import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:chat/chat.dart';
import 'package:equatable/equatable.dart';

part 'typing_notification_event.dart';
part 'typing_notification_state.dart';

class TypingNotificationBloc
    extends Bloc<TypingNotificationEvent, TypingNotificationState> {
  TypingNotificationBloc(this._typingNotification)
      : super(TypingNotificationState.initial());

  final ITypingNotification _typingNotification;
  User _user;
  List<String> _usersWithChat;
  StreamSubscription _subscription;

  @override
  Stream<TypingNotificationState> mapEventToState(
      TypingNotificationEvent typingEvent) async* {
    if (typingEvent is Subscribed) {
      if (typingEvent.usersWithChat == null) {
        add(NotSubscribed());
        return;
      }
      _user = typingEvent._user;
      _usersWithChat = typingEvent.usersWithChat;
      await _subscription?.cancel();
      _subscription = _typingNotification
          .subscribe(_user, _usersWithChat)
          .listen(
              (typingEvent) => add(_TypingNotificationReceived(typingEvent)));
    }
    if (typingEvent is _TypingNotificationReceived) {
      yield TypingNotificationState.received(typingEvent.event);
    }
    if (typingEvent is TypingNotificationSent) {
      await _typingNotification.send(event: typingEvent.event);
      yield TypingNotificationState.sent();
    }

    if (typingEvent is NotSubscribed) {
      yield TypingNotificationState.initial();
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    _typingNotification.dispose();
    return super.close();
  }
}
