import 'package:flutter/material.dart';

class Session {
  String get id => _id;
  String _id;
  bool active;
  DateTime lastSeen;

  Session({
    @required bool active,
    @required DateTime lastSeen,
  }) {
    this.active = active;
    this.lastSeen = lastSeen;
  }

  toJson() => {'active': active, 'last_seen': lastSeen};

  factory Session.fromJson(Map<String, dynamic> json) {
    final session =
        Session(active: json['active'], lastSeen: json['last_seen']);
    session._id = json['id'];
    return session;
  }
}
