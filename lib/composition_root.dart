import 'package:chat/chat.dart';
import 'package:chatapp/cache/local_cache.dart';
import 'package:chatapp/data/datasources/datasource_contract.dart';
import 'package:chatapp/data/datasources/db_factory.dart';
import 'package:chatapp/data/datasources/sqflite_datasource.dart';
import 'package:chatapp/data/services/image_uploader.dart';
import 'package:chatapp/states_mngmt/home/chats_cubit.dart';
import 'package:chatapp/states_mngmt/home/group_cubit.dart';
import 'package:chatapp/states_mngmt/home/home_cubit.dart';
import 'package:chatapp/states_mngmt/message/message_bloc.dart';
import 'package:chatapp/states_mngmt/message_group/message_group_bloc.dart';
import 'package:chatapp/states_mngmt/message_thread/message_thread_cubit.dart';
import 'package:chatapp/states_mngmt/onboarding/onboarding_cubit.dart';
import 'package:chatapp/states_mngmt/onboarding/profile_image_cubit.dart';
import 'package:chatapp/states_mngmt/receipt/receipt_bloc.dart';
import 'package:chatapp/states_mngmt/typing/typing_notification_bloc.dart';
import 'package:chatapp/ui/pages/home/home.dart';
import 'package:chatapp/ui/pages/home/home_router.dart';
import 'package:chatapp/ui/pages/message_thread/message_thread.dart';
import 'package:chatapp/ui/pages/onboarding/onboarding.dart';
import 'package:chatapp/ui/pages/onboarding/onboarding_router.dart';
import 'package:chatapp/ui/widgets/home/create_group.dart';
import 'package:chatapp/viewmodels/chat_view_model.dart';
import 'package:chatapp/viewmodels/chats_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rethinkdb_dart/rethinkdb_dart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import 'models/chat.dart';

class CompositionRoot {
  static SharedPreferences _sharedPreferences;
  static Rethinkdb _r;
  static Connection _connection;
  static IUserService _userService;
  static ILocalCache _localCache;
  static IMessageService _messageService;
  static Database _db;
  static IDatasource _datasource;
  static ITypingNotification _typingNotification;
  static ChatsViewModel _viewModel;
  static ChatsCubit _chatsCubit;
  static MessageBloc _messageBloc;
  static TypingNotificationBloc _typingNotificationBloc;
  static IGroupService _groupService;
  static MessageGroupBloc _messageGroupBloc;
  static IHomeRouter _homeRouter;
  static configure() async {
    _sharedPreferences = await SharedPreferences.getInstance();
    _r = Rethinkdb();
    _connection = await _r.connect(host: "127.0.0.1", port: 28015);
    _userService = UserService(_r, _connection);
    _localCache = LocalCache(_sharedPreferences);
    _messageService = MessageService(_r, _connection);
    _typingNotification = TypingNotification(_r, _connection, _userService);
    _db = await LocalDatabaseFactory().createDatabase();
    await _db.delete('chats');
    await _db.delete('messages');
    _datasource = SqfliteDatasource(_db);
    _viewModel = ChatsViewModel(_datasource, _userService);
    _chatsCubit = ChatsCubit(_viewModel);
    _messageBloc = MessageBloc(_messageService);
    _typingNotificationBloc = TypingNotificationBloc(_typingNotification);
    _groupService = MessageGroupService(_r, _connection);
    _messageGroupBloc = MessageGroupBloc(_groupService);

    _homeRouter = HomeRouter(
        showMessageThread: composeMessageThreadUi,
        showCreateGroup: composeGroupUi);
  }

  static Widget start() {
    final user = _localCache.fetch('USER');
    return user.isEmpty
        ? composeOnboardingUi()
        : composeHomeUi(User.fromJson(user));
  }

  static Widget composeOnboardingUi() {
    ImageUploader imageUploader = ImageUploader('http://localhost:3000/upload');

    OnboardingCubit onboardingCubit =
        OnboardingCubit(_userService, imageUploader, _localCache);
    ProfileImageCubit imageCubit = ProfileImageCubit();
    IOnboardingRouter router =
        OnboardingRouter(onSessionConnected: composeHomeUi);

    return MultiBlocProvider(
      providers: [
        BlocProvider<OnboardingCubit>(
            create: (BuildContext context) => onboardingCubit),
        BlocProvider<ProfileImageCubit>(
            create: (BuildContext context) => imageCubit)
      ],
      child: Onboarding(router),
    );
  }

  static Widget composeHomeUi(User me) {
    HomeCubit homeCubit = HomeCubit(_userService, _localCache);

    return MultiBlocProvider(providers: [
      BlocProvider(create: (BuildContext context) => homeCubit),
      BlocProvider(create: (BuildContext context) => _messageBloc),
      BlocProvider(create: (BuildContext context) => _chatsCubit),
      BlocProvider(create: (BuildContext context) => _typingNotificationBloc),
      BlocProvider(create: (BuildContext context) => _messageGroupBloc)
    ], child: Home(_viewModel, _homeRouter, me));
  }

  static Widget composeMessageThreadUi(
      List<User> receivers, User me, Chat chat) {
    ChatViewModel viewModel = ChatViewModel(_datasource);
    MessageThreadCubit messageThreadCubit = MessageThreadCubit(viewModel);
    IReceiptService receiptService = ReceiptService(_r, _connection);
    ReceiptBloc receiptBloc = ReceiptBloc(receiptService);

    return MultiBlocProvider(
        providers: [
          BlocProvider(create: (BuildContext context) => messageThreadCubit),
          BlocProvider(create: (BuildContext context) => receiptBloc)
        ],
        child: MessageThread(receivers, me, _messageBloc, _chatsCubit,
            _typingNotificationBloc, chat));
  }

  static Widget composeGroupUi(List<User> activeUsers, User me) {
    GroupCubit groupCubit = GroupCubit();
    MessageGroupBloc messageGroupBloc = MessageGroupBloc(_groupService);
    return MultiBlocProvider(providers: [
      BlocProvider(create: (BuildContext context) => groupCubit),
      BlocProvider(create: (BuildContext context) => messageGroupBloc),
    ], child: CreateGroup(activeUsers, me, _chatsCubit, _homeRouter));
  }
}
