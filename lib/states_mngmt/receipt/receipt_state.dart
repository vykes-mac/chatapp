part of 'receipt_bloc.dart';

abstract class ReceiptState extends Equatable {
  const ReceiptState();
  factory ReceiptState.initial() => ReceiptInitial();
  factory ReceiptState.sent(Receipt receipt) => ReceiptSentSuccess(receipt);
  factory ReceiptState.received(Receipt receipt) =>
      ReceiptReceivedSuccess(receipt);
  @override
  List<Object> get props => [];
}

class ReceiptInitial extends ReceiptState {}

class ReceiptSentSuccess extends ReceiptState {
  const ReceiptSentSuccess(this.receipt);

  final Receipt receipt;

  @override
  List<Object> get props => [receipt];
}

class ReceiptReceivedSuccess extends ReceiptState {
  const ReceiptReceivedSuccess(this.receipt);

  final Receipt receipt;

  @override
  List<Object> get props => [receipt];
}
