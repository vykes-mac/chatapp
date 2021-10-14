import 'package:chat/chat.dart';
import 'package:chatapp/data/datasources/sqflite_datasource.dart';
import 'package:chatapp/models/chat.dart';
import 'package:chatapp/models/local_message.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';

class MockSqfliteDatabase extends Mock implements Database {}

class MockTransaction extends Mock implements Transaction {}

class MockBatch extends Mock implements Batch {}

void main() {
  SqfliteDatasource sut;
  MockSqfliteDatabase database;
  MockBatch batch;

  setUp(() {
    database = MockSqfliteDatabase();
    batch = MockBatch();
    sut = SqfliteDatasource(database);
  });

  final message = Message.fromJson({
    'from': '111',
    'to': '222',
    'contents': 'hey',
    'timestamp': DateTime.parse("2021-04-01"),
    'id': '4444'
  });

  test('should perform insert of chat to the database', () async {
    //arrange
    final chat = Chat('1234', ChatType.individual, membersId: List.empty());
    when(database.insert('chats', chat.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace))
        .thenAnswer((_) async => 1);
    //act
    await sut.addChat(chat);

    //assert
    verify(database.insert('chats', chat.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace))
        .called(1);
  });

  test('should perform insert of message to the database', () async {
    //arrange
    final localMessage = LocalMessage('1234', message, ReceiptStatus.sent);

    when(database.insert('messages', localMessage.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace))
        .thenAnswer((_) async => 1);
    //act
    await sut.addMessage(localMessage);

    //assert
    verify(database.insert('messages', localMessage.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace))
        .called(1);
  });

  test('should perform a database transaction and return chat', () async {
    //arrange

    when(database.transaction(any)).thenAnswer((_) async {
      return Chat('1', ChatType.individual, membersId: List.empty());
    });

    //act
    final chat = await sut.findChat('123');

    //assert
    verify(database.transaction(any)).called(1);
    expect(chat.id, '1');
  });

  test('should perform a database transaction and return chats', () async {
    //arrange

    when(database.transaction(any)).thenAnswer((_) async {
      return [Chat('1', ChatType.individual, membersId: List.empty())];
    });

    //act
    final chats = await sut.findAllChats();

    //assert
    verify(database.transaction(any)).called(1);
    expect(chats.length, 1);
  });

  test('should perform a database query and return message', () async {
    //arrange
    final messagesMap = [
      {
        'chat_id': '111',
        'id': '4444',
        'from': '111',
        'to': '222',
        'contents': 'hey',
        'receipt': 'sent',
        'timestamp': DateTime.parse("2021-04-01"),
      }
    ];
    when(database.query(
      'messages',
      where: anyNamed('where'),
      whereArgs: anyNamed('whereArgs'),
    )).thenAnswer((_) async => messagesMap);

    //act
    var messages = await sut.findMessages('111');

    //assert
    expect(messages.length, 1);
    expect(messages.first.chatId, '111');
    verify(database.query(
      'messages',
      where: anyNamed('where'),
      whereArgs: anyNamed('whereArgs'),
    )).called(1);
  });

  test('should perform database update on messages', () async {
    //arrange
    final localMessage = LocalMessage('1234', message, ReceiptStatus.sent);
    when(database.update('messages', localMessage.toMap(),
            where: anyNamed('where'), whereArgs: anyNamed('whereArgs')))
        .thenAnswer((_) async => 1);

    //act
    await sut.updateMessage(localMessage);

    //assert
    verify(database.update('messages', localMessage.toMap(),
            where: anyNamed('where'),
            whereArgs: anyNamed('whereArgs'),
            conflictAlgorithm: ConflictAlgorithm.replace))
        .called(1);
  });

  test('should perform database batch delete of chat', () async {
    //arrange
    final chatId = '111';
    when(database.batch()).thenReturn(batch);

    //act
    await sut.deleteChat(chatId);

    //assert
    verifyInOrder([
      database.batch(),
      batch.delete('messages', where: anyNamed('where'), whereArgs: [chatId]),
      batch.delete('chats', where: anyNamed('where'), whereArgs: [chatId]),
      batch.commit(noResult: true)
    ]);
  });
}
