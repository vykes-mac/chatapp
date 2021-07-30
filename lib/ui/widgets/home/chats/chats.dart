import 'package:chat/chat.dart';
import 'package:chatapp/colors.dart';
import 'package:chatapp/models/chat.dart';
import 'package:chatapp/states_mngmt/home/chats_cubit.dart';
import 'package:chatapp/states_mngmt/message/message_bloc.dart';
import 'package:chatapp/states_mngmt/typing/typing_notification_bloc.dart';
import 'package:chatapp/theme.dart';
import 'package:chatapp/ui/pages/home/home_router.dart';
import 'package:chatapp/ui/widgets/home/profile_image.dart';
import 'package:chatapp/viewmodels/chats_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class Chats extends StatefulWidget {
  final ChatsViewModel viewModel;
  final User user;
  final IHomeRouter router;
  Chats(this.viewModel, this.user, this.router);

  @override
  _ChatsState createState() => _ChatsState();
}

class _ChatsState extends State<Chats> {
  List<Chat> chats = [];
  final typingEvents = [];

  @override
  void initState() {
    super.initState();
    _updateChatsOnMessageReceived();
    context.read<ChatsCubit>().chats();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatsCubit, List<Chat>>(builder: (__, chats) {
      this.chats = chats;
      if (this.chats.isEmpty) return Container();
      context.read<TypingNotificationBloc>().add(
          TypingNotificationEvent.onSubscribed(widget.user,
              usersWithChat: chats.map((e) => e.from.id).toList()));
      return _buildListView();
    });
  }

  _buildListView() {
    return ListView.separated(
        padding: EdgeInsets.only(top: 30, right: 16),
        itemBuilder: (BuildContext context, indx) => GestureDetector(
            child: _chatItem(chats[indx]),
            onTap: () async {
              await this.widget.router.onShowMessageThread(
                  context, chats[indx].from, widget.user,
                  chatId: chats[indx].id);

              await context.read<ChatsCubit>().chats();
            }),
        separatorBuilder: (_, __) => Divider(),
        itemCount: chats.length);
  }

  _chatItem(Chat chat) => ListTile(
        leading: ProfileImage(
          imageUrl: chat.from.photoUrl,
          online: chat.from.active,
        ),
        title: Text(
          chat.from.username,
          style: Theme.of(context).textTheme.subtitle2.copyWith(
              fontWeight: FontWeight.bold,
              color: isLightTheme(context) ? Colors.black : Colors.white),
        ),
        subtitle: BlocBuilder<TypingNotificationBloc, TypingNotificationState>(
            builder: (__, state) {
          if (state is TypingNotificationReceivedSuccess &&
              state.event.event == Typing.start &&
              state.event.from == chat.from.id)
            this.typingEvents.add(state.event.from);

          if (state is TypingNotificationReceivedSuccess &&
              state.event.event == Typing.stop &&
              state.event.from == chat.from.id)
            this.typingEvents.remove(state.event.from);

          if (this.typingEvents.contains(chat.from.id))
            return Text('typing...',
                style: Theme.of(context)
                    .textTheme
                    .caption
                    .copyWith(fontStyle: FontStyle.italic));

          return Text(
            chat.mostRecent.message.contents,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            softWrap: true,
            style: Theme.of(context).textTheme.overline.copyWith(
                color: isLightTheme(context) ? Colors.black54 : Colors.white70,
                fontWeight:
                    chat.unread > 0 ? FontWeight.bold : FontWeight.normal),
          );
        }),
        contentPadding: EdgeInsets.only(left: 16.0),
        trailing: Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                DateFormat('h:mm a').format(chat.mostRecent.message.timestamp),
                style: Theme.of(context).textTheme.overline.copyWith(
                    color: isLightTheme(context)
                        ? Colors.black54
                        : Colors.white70),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: chat.unread > 0
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(50.0),
                        child: Container(
                          height: 15.0,
                          width: 15.0,
                          color: kPrimary,
                          alignment: Alignment.center,
                          child: Text(
                            chat.unread.toString(),
                            style: Theme.of(context)
                                .textTheme
                                .overline
                                .copyWith(color: Colors.white),
                          ),
                        ),
                      )
                    : SizedBox.shrink(),
              )
            ],
          ),
        ),
      );

  void _updateChatsOnMessageReceived() {
    final chatsCubit = context.read<ChatsCubit>();
    context.read<MessageBloc>().stream.listen((state) async {
      if (state is MessageReceivedSuccess) {
        await chatsCubit.viewModel.receivedMessage(state.message);
        chatsCubit.chats();
      }
    });
  }
}
