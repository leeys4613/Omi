import 'package:flutter/material.dart';
import 'screens/main_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OMI HOME',
      theme: ThemeData(
        fontFamily: 'Lato',
      ),
      home: const MainScreen(),
    );
  }
}
