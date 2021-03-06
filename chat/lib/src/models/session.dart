import 'package:flutter/material.dart';

class Session {
  String id;
  bool active;
  DateTime lastSeen;

  Session({
    @required String id,
    @required bool active,
    @required DateTime lastSeen,
  }) {
    this.id = id;
    this.active = active;
    this.lastSeen = lastSeen;
  }
}
