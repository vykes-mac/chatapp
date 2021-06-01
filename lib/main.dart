import 'package:chatapp/composition_root.dart';
import 'package:chatapp/theme.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CompositionRoot.configure();
  final firstPage = CompositionRoot.start();
  runApp(MyApp(firstPage));
}

class MyApp extends StatelessWidget {
  final Widget firstPage;

  MyApp(this.firstPage);
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat App',
      debugShowCheckedModeBanner: false,
      theme: lightTheme(context),
      darkTheme: darkTheme(context),
      home: firstPage,
    );
  }
}
