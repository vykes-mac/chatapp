import 'package:chat/chat.dart';
import 'package:flutter/material.dart';

abstract class IOnboardingRouter {
  void onSessionSuccess(BuildContext context, User user);
}

class OnboardingRouter implements IOnboardingRouter {
  final Widget Function(User user) onSessionConnected;

  OnboardingRouter({@required this.onSessionConnected});

  @override
  void onSessionSuccess(BuildContext context, User user) {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => onSessionConnected(user),
        ),
        (Route<dynamic> route) => false);
  }
}
