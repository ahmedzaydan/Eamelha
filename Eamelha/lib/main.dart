import 'package:eamelha/layout/HomeLayoutScreen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const Eamelha());
}

class Eamelha extends StatelessWidget {
  const Eamelha({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeLayout(),
    );
  }
}
