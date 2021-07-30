import 'package:bloc/bloc.dart';
import 'package:chatapp/models/local_message.dart';
import 'package:chatapp/viewmodels/chat_view_model.dart';

class MessageThreadCubit extends Cubit<List<LocalMessage>> {
  final ChatViewModel viewModel;
  MessageThreadCubit(this.viewModel) : super([]);

  Future<void> messages(String chatId) async {
    final messages = await viewModel.getMessages(chatId);
    emit(messages);
  }
}
