import 'package:chat/chat.dart';
import 'package:chatapp/states_mngmt/onboarding/onboarding_cubit.dart';
import 'package:chatapp/ui/pages/onboarding.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rethinkdb_dart/rethinkdb_dart.dart';

class CompositionRoot {
  static Rethinkdb _r;
  static Connection _connection;
  static IUserService _userService;

  static configure() async {
    _r = Rethinkdb();
    _connection = await _r.connect(host: "127.0.0.1", port: 28015);
    _userService = UserService(_r, _connection);
  }

  static Widget composeOnboardingUi() {
    OnboardingCubit onboardingCubit = OnboardingCubit(_userService);

    return BlocProvider<OnboardingCubit>(
      create: (BuildContext context) => onboardingCubit,
      child: Onboarding(),
    );
  }
}
