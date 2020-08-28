import 'package:flutter/material.dart';

class ListItem{
  Widget _display;
  int _value;

  ListItem(Widget display, int value){
    this._display = display;
    this._value = value;
  }

  Widget getDisplay(){ return this._display; }
  int getValue(){ return this._value; }
}