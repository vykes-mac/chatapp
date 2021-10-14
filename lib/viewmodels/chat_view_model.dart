import 'package:chat/chat.dart';
import 'package:chatapp/data/datasources/datasource_contract.dart';
import 'package:chatapp/models/local_message.dart';
import 'package:chatapp/viewmodels/base_view_model.dart';

class ChatViewModel extends BaseViewModel {
  IDatasource _datasource;
  String _chatId = '';
  int otherMessages = 0;
  String get chatId => _chatId;
  ChatViewModel(this._datasource) : super(_datasource);

  Future<List<LocalMessage>> getMessages(chatId) async {
    final messages = await _datasource.findMessages(chatId);
    if (messages.isNotEmpty) _chatId = chatId;
    return messages;
  }

  Future<void> sentMessage(Message message) async {
    final chatId = message.groupId != null ? message.groupId : message.to;
    LocalMessage localMessage =
        LocalMessage(chatId, message, ReceiptStatus.sent);
    if (_chatId.isNotEmpty) return await _datasource.addMessage(localMessage);
    _chatId = localMessage.chatId;
    await addMessage(localMessage);
  }

  Future<void> receivedMessage(Message message) async {
    final chatId = message.groupId != null ? message.groupId : message.from;
    LocalMessage localMessage =
        LocalMessage(chatId, message, ReceiptStatus.deliverred);
    if (_chatId.isEmpty) _chatId = localMessage.chatId;
    if (localMessage.chatId != _chatId) otherMessages++;
    await addMessage(localMessage);
  }

  Future<void> updateMessageReceipt(Receipt receipt) async {
    await _datasource.updateMessageReceipt(receipt.messageId, receipt.status);
  }
}
