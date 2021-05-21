part of 'typing_notification_bloc.dart';

abstract class TypingNotificationState extends Equatable {
  const TypingNotificationState();
  factory TypingNotificationState.initial() => TypingNotificationInitial();
  factory TypingNotificationState.sent() => TypingNotificationSentSuccess();
  factory TypingNotificationState.received(TypingEvent event) =>
      TypingNotificationReceivedSuccess(event);
  @override
  List<Object> get props => [];
}

class TypingNotificationInitial extends TypingNotificationState {}

class TypingNotificationSentSuccess extends TypingNotificationState {}

class TypingNotificationReceivedSuccess extends TypingNotificationState {
  const TypingNotificationReceivedSuccess(this.event);

  final TypingEvent event;

  @override
  List<Object> get props => [event];
}
