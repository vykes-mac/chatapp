import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:chat/chat.dart';
import 'package:chatapp/data/services/image_uploader.dart';
import 'package:chatapp/states_mngmt/onboarding/onboarding_state.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  final IUserService _userService;
  final ImageUploader _imageUploader;

  OnboardingCubit(this._userService, this._imageUploader)
      : super(OnboardingInitial());

  Future<void> connect(String name, File profileImage) async {
    emit(Loading());
    final url = await _imageUploader.uploadImage(profileImage);
    final user = User(
      username: name,
      photoUrl: url,
      active: true,
      lastSeen: DateTime.now(),
    );
    final createdUser = await _userService.connect(user);
    emit(OnboardingSuccess(createdUser));
  }
}
