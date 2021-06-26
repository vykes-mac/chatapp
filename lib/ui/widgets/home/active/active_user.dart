import 'package:chat/chat.dart';
import 'package:chatapp/states_mngmt/home/home_cubit.dart';
import 'package:chatapp/states_mngmt/home/home_state.dart';
import 'package:chatapp/ui/widgets/home/profile_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ActiveUsers extends StatefulWidget {
  @override
  _ActiveUsersState createState() => _ActiveUsersState();
}

class _ActiveUsersState extends State<ActiveUsers> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(builder: (_, state) {
      if (state is HomeLoading)
        return Center(child: CircularProgressIndicator.adaptive());
      if (state is HomeSuccess) return _buildList(state.onlineUsers);
      return Container();
    });
  }

  _listItem(User user) => ListTile(
        leading: ProfileImage(
          imageUrl: user.photoUrl,
          online: true,
        ),
        title: Text(
          user.username,
          style: Theme.of(context).textTheme.caption.copyWith(
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
              ),
        ),
      );

  _buildList(List<User> users) => ListView.separated(
      padding: EdgeInsets.only(top: 30, right: 16),
      itemBuilder: (BuildContext context, indx) => _listItem(users[indx]),
      separatorBuilder: (_, __) => Divider(),
      itemCount: users.length);
}
