part of 'message_bloc.dart';

abstract class MessageState extends Equatable {
  const MessageState();
  factory MessageState.initial() => MessageInitial();
  factory MessageState.sent() => MessageSentSuccess();
  factory MessageState.received(Message message) =>
      MessageReceivedSuccess(message);
  @override
  List<Object> get props => [];
}

class MessageInitial extends MessageState {}

class MessageSentSuccess extends MessageState {}

class MessageReceivedSuccess extends MessageState {
  const MessageReceivedSuccess(this.message);

  final Message message;

  @override
  List<Object> get props => [message];
}
