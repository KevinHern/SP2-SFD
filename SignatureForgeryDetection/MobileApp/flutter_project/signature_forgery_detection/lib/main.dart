// Basic Imports
import 'package:flutter/material.dart';

// Routes
import 'package:signature_forgery_detection/login.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: LoginScreen(),
    );
  }
}