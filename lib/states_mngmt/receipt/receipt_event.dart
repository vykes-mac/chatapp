part of 'receipt_bloc.dart';

abstract class ReceiptEvent extends Equatable {
  const ReceiptEvent();
  factory ReceiptEvent.onSubscribed() => Subscribed();
  factory ReceiptEvent.onReceiptSent(Receipt receipt) => ReceiptSent(receipt);

  @override
  List<Object> get props => [];
}

class Subscribed extends ReceiptEvent {}

class ReceiptSent extends ReceiptEvent {
  final Receipt receipt;
  const ReceiptSent(this.receipt);

  @override
  List<Object> get props => [receipt];
}

class _ReceiptReceived extends ReceiptEvent {
  const _ReceiptReceived(this.receipt);

  final Receipt receipt;

  @override
  List<Object> get props => [receipt];
}
