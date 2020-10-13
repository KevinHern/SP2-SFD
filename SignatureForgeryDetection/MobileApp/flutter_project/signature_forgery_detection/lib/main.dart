// Basic Imports
import 'package:flutter/material.dart';

// Routes
import 'package:signature_forgery_detection/login/login.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      //home: LoginScreen(primaryColor: new Color(0xFF3949AB), backgroundColor: Colors.white, backgroundImage: new AssetImage("assets/full-bloom.png"),),
      home: LoginScreen(),
    );
  }
}