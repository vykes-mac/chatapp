class User {
  String? get id => _id;
  String? username;
  String? photoUrl;
  String? _id;
  bool? active;
  DateTime? lastSeen;

  User({
    required this.username,
    required this.photoUrl,
    required this.active,
    required this.lastSeen,
  }) {
    this.active = active;
    this.lastSeen = lastSeen;
  }

  toJson() => {
        'username': username,
        'photo_url': photoUrl,
        'active': active,
        'last_seen': lastSeen
      };

  factory User.fromJson(Map<String, dynamic> json) {
    final user = User(
        username: json['username'],
        photoUrl: json['photo_url'],
        active: json['active'],
        lastSeen: json['last_seen']);
    user._id = json['id'];
    return user;
  }

  @override
  bool operator ==(Object other) => other is User && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
