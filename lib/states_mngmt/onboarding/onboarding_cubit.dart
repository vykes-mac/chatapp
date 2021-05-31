import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:chat/chat.dart';
import 'package:chatapp/states_mngmt/onboarding/onboarding_state.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  final IUserService _userService;

  OnboardingCubit(this._userService) : super(OnboardingInitial());

  Future<void> connect(String name, File profileImage) async {
    emit(Loading());
    //upload image here
    final user = User(
      username: name,
      photoUrl: '',
      active: true,
      lastSeen: DateTime.now(),
    );
    final createdUser = await _userService.connect(user);
    emit(OnboardingSuccess(createdUser));
  }
}
