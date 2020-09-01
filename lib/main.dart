import 'package:firebase_todo/services/authentication.dart';
import 'package:firebase_todo/view/root_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: RootPage(
        auth: Auth(),
      ),
    );
  }
}
