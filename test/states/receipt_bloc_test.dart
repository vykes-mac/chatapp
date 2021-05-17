import 'package:chat/chat.dart';
import 'package:chatapp/states_mngmt/receipt/receipt_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class FakeReceiptService extends Mock implements IReceiptService {}

void main() {
  ReceiptBloc sut;
  IReceiptService receiptService;
  User user;

  setUp(() {
    receiptService = FakeReceiptService();
    user = User(
      username: 'test',
      photoUrl: '',
      active: true,
      lastSeen: DateTime.now(),
    );
    sut = ReceiptBloc(receiptService, user);
  });

  tearDown(() => sut.close());

  test('should emit initial state only without subscriptions', () {
    expect(sut.state, ReceiptInitial());
  });

  test('should emit receipt sent state when receipt is sent', () {
    final receipt = Receipt(
      recipient: '123',
      messageId: '456',
      status: ReceiptStatus.sent,
      timestamp: DateTime.now(),
    );

    when(receiptService.send(receipt)).thenAnswer((_) async => true);
    sut.add(ReceiptEvent.onReceiptSent(receipt));
    expectLater(sut.stream, emits(ReceiptState.sent(receipt)));
  });

  test('should emit receipts received from service', () {
    final receipt = Receipt(
      recipient: '123',
      messageId: '456',
      status: ReceiptStatus.deliverred,
      timestamp: DateTime.now(),
    );

    when(receiptService.receipts(any))
        .thenAnswer((_) => Stream.fromIterable([receipt]));

    sut.add(ReceiptEvent.onSubscribed());
    expectLater(sut.stream, emitsInOrder([ReceiptReceivedSuccess(receipt)]));
  });
}
