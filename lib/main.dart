import 'package:elapor_mobile/screens/login_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(ELaporApp());
}

class ELaporApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-Lapor Mobile',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
