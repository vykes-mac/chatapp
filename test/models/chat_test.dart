import 'dart:ui';

import 'package:chatapp/models/chat.dart';
import 'package:chatapp/utils/color_generator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('chats model created from db object', () {
    final chat = Chat('1234', ChatType.individual, membersId: [
      {"12323": "asss"},
      {"12323": "asss"}
    ]);

    final res = chat.toMap();
    final c = Chat.fromMap(res);
    expect(res, isNotEmpty);
    expect(c, chat);
  });

  test('color to string', () {
    final color = RandomColorGenerator.getColor();
    final colorString = color.value.toString();

    Color newColor = Color(int.parse(colorString));

    expect(newColor.value, color.value);
  });
}
