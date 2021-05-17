part of 'message_bloc.dart';

abstract class MessageEvent extends Equatable {
  const MessageEvent();
  factory MessageEvent.onSubscribed() => Subscribed();
  factory MessageEvent.onMessageSent(Message message) => MessageSent(message);

  @override
  List<Object> get props => [];
}

class Subscribed extends MessageEvent {}

class MessageSent extends MessageEvent {
  final Message message;
  const MessageSent(this.message);

  @override
  List<Object> get props => [message];
}

class _MessageReceived extends MessageEvent {
  const _MessageReceived(this.message);

  final Message message;

  @override
  List<Object> get props => [message];
}
