import 'package:chat/chat.dart';
import 'package:chatapp/states_mngmt/typing/typing_notification_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class FakeTypingNotificationService extends Mock
    implements ITypingNotification {}

void main() {
  TypingNotificationBloc sut;
  ITypingNotification typingNotificationService;
  User user;

  setUp(() {
    typingNotificationService = FakeTypingNotificationService();
    user = User(
      username: 'test',
      photoUrl: '',
      active: true,
      lastSeen: DateTime.now(),
    );
    sut = TypingNotificationBloc(typingNotificationService);
  });

  tearDown(() => sut.close());

  test('should emit initial state only without subscriptions', () {
    expect(sut.state, TypingNotificationInitial());
  });

  test('should emit typing sent state when typing event is sent', () {
    final typingEvent =
        TypingEvent(chatId: '123', from: '111', to: '222', event: Typing.start);
    when(typingNotificationService.send(events: [typingEvent]))
        .thenAnswer((_) async => true);
    sut.add(TypingNotificationEvent.onTypingEventSent([typingEvent]));
    expectLater(sut.stream, emits(TypingNotificationState.sent()));
  });

  test('should not subscribe if no chats exist', () {
    final typingEvent =
        TypingEvent(chatId: '123', from: '111', to: '222', event: Typing.start);

    when(typingNotificationService.subscribe(any, any))
        .thenAnswer((_) => Stream.fromIterable([typingEvent]));

    sut.add(TypingNotificationEvent.onSubscribed(user));
    verifyNever(typingNotificationService.subscribe(any, any));
    expectLater(sut.stream, emits(TypingNotificationState.initial()));
  });
  test('should receive typing events from service', () {
    final typingEvent =
        TypingEvent(chatId: '123', from: '111', to: '222', event: Typing.start);

    when(typingNotificationService.subscribe(any, any))
        .thenAnswer((_) => Stream.fromIterable([typingEvent]));

    sut.add(TypingNotificationEvent.onSubscribed(user, usersWithChat: ['123']));
    verifyNever(typingNotificationService.subscribe(any, any));
    expectLater(sut.stream,
        emitsInOrder([TypingNotificationReceivedSuccess(typingEvent)]));
  });
}
