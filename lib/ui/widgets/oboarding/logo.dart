import 'package:chatapp/theme.dart';
import 'package:flutter/widgets.dart';

class Logo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: isLightTheme(context)
          ? Image.asset('assets/logo_light.png', fit: BoxFit.fill)
          : Image.asset('assets/logo_dark.png', fit: BoxFit.fill),
    );
  }
}
