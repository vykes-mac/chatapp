import 'package:chat/chat.dart';
import 'package:chatapp/colors.dart';
import 'package:chatapp/models/chat.dart';
import 'package:chatapp/states_mngmt/home/chats_cubit.dart';
import 'package:chatapp/states_mngmt/home/group_cubit.dart';
import 'package:chatapp/states_mngmt/message_group/message_group_bloc.dart';
import 'package:chatapp/theme.dart';
import 'package:chatapp/ui/pages/home/home_router.dart';
import 'package:chatapp/ui/widgets/home/profile_image.dart';
import 'package:chatapp/ui/widgets/shared/custom_text_field.dart';
import 'package:chatapp/utils/color_generator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreateGroup extends StatefulWidget {
  final List<User> _activeUsers;
  final User _me;
  final ChatsCubit _chatsCubit;
  final IHomeRouter _router;

  CreateGroup(this._activeUsers, this._me, this._chatsCubit, this._router);

  @override
  _CreateGroupState createState() => _CreateGroupState();
}

class _CreateGroupState extends State<CreateGroup> {
  List<User> selectedUsers = [];
  GroupCubit _groupCubit;
  ChatsCubit _chatsCubit;
  MessageGroupBloc _messageGroupBloc;
  String _groupName = '';

  @override
  void initState() {
    super.initState();
    _groupCubit = context.read<GroupCubit>();
    _chatsCubit = widget._chatsCubit;
    _messageGroupBloc = context.read<MessageGroupBloc>();

    _messageGroupBloc.stream.listen((state) async {
      if (state is MessageGroupCreatedSuccess) {
        state.group.members.removeWhere((e) => e == widget._me.id);
        final membersId = state.group.members
            .map((e) => {e: RandomColorGenerator.getColor().value.toString()})
            .toList();
        final chat = Chat(
          state.group.id,
          ChatType.group,
          membersId: membersId,
          name: _groupName,
        );
        await _chatsCubit.viewModel.createNewChat(chat);
        final chats = await _chatsCubit.viewModel.getChats();
        final receivers =
            chats.firstWhere((chat) => chat.id == state.group.id).members;
        await _chatsCubit.chats();
        Navigator.of(context).pop();
        widget._router
            .onShowMessageThread(context, receivers, widget._me, chat);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<GroupCubit, List<User>>(
        bloc: _groupCubit,
        builder: (_, state) {
          selectedUsers = state;
          return SizedBox.expand(
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _header(selectedUsers.length > 1),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 16.0),
                    child: CustomTextField(
                      height: 43,
                      hint: 'Group name',
                      inputAction: TextInputAction.done,
                      onChanged: (val) {
                        _groupName = val;
                      },
                    ),
                  ),
                  state.isEmpty
                      ? SizedBox.shrink()
                      : Container(
                          height: 65,
                          child: ListView.builder(
                            itemBuilder: (__, idx) =>
                                _selectedUsersListItem(selectedUsers[idx]),
                            itemCount: selectedUsers.length,
                            scrollDirection: Axis.horizontal,
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                          ),
                        ),
                  Expanded(child: _buildList(widget._activeUsers))
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  _header(bool enableButton) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Container(
          height: 40,
          child: Row(
            children: [
              TextButton(
                style: ButtonStyle(
                    textStyle: MaterialStateProperty.all<TextStyle>(
                        Theme.of(context).textTheme.caption)),
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Cancel',
                ),
              ),
              Center(
                child: Text(
                  'New Group',
                  style: Theme.of(context).textTheme.caption,
                ),
              ),
              TextButton(
                style: ButtonStyle(
                    textStyle: MaterialStateProperty.all<TextStyle>(
                        Theme.of(context).textTheme.caption)),
                onPressed: enableButton
                    ? () {
                        if (_groupName.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Enter Group Name'),
                            ),
                          );

                          return;
                        }
                        _createGroup();
                      }
                    : null,
                child: Text(
                  'Create',
                ),
              )
            ],
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
          ),
        ),
      );

  _selectedUsersListItem(User user) => Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: GestureDetector(
          onTap: () => _groupCubit.remove(user),
          child: Container(
            width: 40,
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: CircleAvatar(
                      backgroundColor: kIconLight,
                      radius: 30,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(40),
                        child: Image.network(
                          user.photoUrl,
                          fit: BoxFit.fill,
                          width: 40,
                          height: 40,
                        ),
                      )),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Container(
                      width: 16,
                      height: 16,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isLightTheme(context)
                              ? Colors.black54
                              : kAppBarDark),
                      child: Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 12.0,
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Text(
                    user.username.split(' ').first,
                    softWrap: false,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.caption.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  _listItem(User user) => ListTile(
        leading: ProfileImage(
          imageUrl: user.photoUrl,
          online: true,
        ),
        title: Text(
          user.username,
          style: Theme.of(context).textTheme.caption.copyWith(
                fontSize: 12.0,
                fontWeight: FontWeight.bold,
              ),
        ),
        trailing: _checkBox(
          size: 20.0,
          isChecked: selectedUsers.any((element) => element.id == user.id),
        ),
      );

  _buildList(List<User> users) => ListView.separated(
      padding: EdgeInsets.only(top: 20, right: 2),
      itemBuilder: (BuildContext context, indx) => GestureDetector(
            child: _listItem(users[indx]),
            onTap: () {
              if (selectedUsers
                  .any((element) => element.id == users[indx].id)) {
                _groupCubit.remove(users[indx]);
                return;
              }
              _groupCubit.add(users[indx]);
            },
          ),
      separatorBuilder: (_, __) => Divider(
            endIndent: 16.0,
          ),
      itemCount: users.length);

  _checkBox({@required double size, @required bool isChecked}) => ClipRRect(
        borderRadius: BorderRadius.circular(size / 2),
        child: AnimatedContainer(
          duration: Duration(microseconds: 500),
          height: size,
          width: size,
          decoration: BoxDecoration(
            color: isChecked ? kPrimary : Colors.transparent,
            border: Border.all(
              color: Colors.grey,
            ),
            borderRadius: BorderRadius.circular(size / 2),
          ),
        ),
      );

  void _createGroup() {
    MessageGroup group = MessageGroup(
        createdBy: widget._me.id,
        name: _groupName,
        members:
            selectedUsers.map<String>((e) => e.id).toList() + [widget._me.id]);
    final event = MessageGroupEvent.onGroupCreated(group);
    _messageGroupBloc.add(event);
  }
}
