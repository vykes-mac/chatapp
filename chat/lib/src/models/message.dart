class Message {
  final String? from;
  final String? to;
  String? groupId;
  String? get id => _id;
  final DateTime? timestamp;
  final String? contents;
  String? _id;

  Message(
      {required this.from,
      required this.to,
      required this.timestamp,
      required this.contents,
      this.groupId});

  toJson() => {
        'from': this.from,
        'to': this.to,
        'timestamp': this.timestamp,
        'contents': this.contents,
        'group_id': this.groupId
      };
  factory Message.fromJson(Map<String, dynamic> json) {
    var message = Message(
        to: json['to'],
        from: json['from'],
        contents: json['contents'],
        timestamp: json['timestamp'],
        groupId: json['group_id']);
    message._id = json['id'];
    return message;
  }
}
