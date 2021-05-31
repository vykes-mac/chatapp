import 'package:chat/chat.dart';
import 'package:chatapp/data/services/image_uploader.dart';
import 'package:chatapp/states_mngmt/onboarding/onboarding_cubit.dart';
import 'package:chatapp/states_mngmt/onboarding/profile_image_cubit.dart';
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
    ImageUploader imageUploader = ImageUploader('http://localhost:3000/upload');
    OnboardingCubit onboardingCubit =
        OnboardingCubit(_userService, imageUploader);
    ProfileImageCubit imageCubit = ProfileImageCubit();

    return MultiBlocProvider(
      providers: [
        BlocProvider<OnboardingCubit>(
            create: (BuildContext context) => onboardingCubit),
        BlocProvider<ProfileImageCubit>(
            create: (BuildContext context) => imageCubit)
      ],
      child: Onboarding(),
    );
  }
}
