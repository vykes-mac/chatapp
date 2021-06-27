import 'package:chatapp/states_mngmt/home/chats_cubit.dart';
import 'package:chatapp/states_mngmt/home/home_cubit.dart';
import 'package:chatapp/states_mngmt/home/home_state.dart';
import 'package:chatapp/states_mngmt/message/message_bloc.dart';
import 'package:chatapp/ui/widgets/home/active/active_user.dart';
import 'package:chatapp/ui/widgets/home/chats/chats.dart';
import 'package:chatapp/ui/widgets/home/profile_image.dart';
import 'package:chatapp/viewmodels/chats_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Home extends StatefulWidget {
  final ChatsViewModel viewModel;
  Home(this.viewModel);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with AutomaticKeepAliveClientMixin {
  @override
  void initState() {
    super.initState();
    _connectSession();
  }

  final _url =
      'http://localhost:3000/images/profile/image_picker_2C66C72E-9698-42CE-9451-44D268C53FAB-52133-00042FB9B32BF759.jpg';

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Container(
            width: double.maxFinite,
            child: Row(
              children: [
                ProfileImage(
                  imageUrl: _url,
                  online: true,
                ),
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        'Jess',
                        style: Theme.of(context)
                            .textTheme
                            .caption
                            .copyWith(fontSize: 14.0)
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 12.0),
                      child: Text(
                        'online',
                        style: Theme.of(context).textTheme.caption,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          bottom: TabBar(
            indicatorPadding: EdgeInsets.only(top: 10.0, bottom: 10.0),
            tabs: [
              Tab(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text('Messages'),
                  ),
                ),
              ),
              Tab(
                child: Padding(
                  padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Align(
                      alignment: Alignment.center,
                      child: BlocBuilder<HomeCubit, HomeState>(
                          builder: (BuildContext _, state) =>
                              state is HomeSuccess
                                  ? Text("Active(${state.onlineUsers.length})")
                                  : Text("Active(0)")),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        body: SafeArea(
          child: TabBarView(children: [
            Chats(widget.viewModel),
            ActiveUsers(),
          ]),
        ),
      ),
    );
  }

  _connectSession() async {
    context.read<ChatsCubit>().chats();
    final user = await context.read<HomeCubit>().connect();

    context.read<HomeCubit>().activeUsers(user);
    context.read<MessageBloc>().add(MessageEvent.onSubscribed(user));
  }

  @override
  bool get wantKeepAlive => true;
}
