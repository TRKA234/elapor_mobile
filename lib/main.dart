import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(ELaporApp());
}

class ELaporApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-Lapor Mobile',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
