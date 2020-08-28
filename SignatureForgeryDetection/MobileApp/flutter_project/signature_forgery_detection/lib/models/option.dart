import 'package:flutter/cupertino.dart';

class Option {
  int option;
  Option({@required this.option});

  int getOption(){
    return this.option;
  }

  void setOption (int newVal) {
    this.option = newVal;
  }
}