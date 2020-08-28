import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ContainerTemplate {
  static Widget buildContainer(Widget widget, var size, double radius,
      double shadowOffsetX, double shadowOffsetY, double opacity, double blur){
    return new Container(
      margin: EdgeInsets.only(left: double.parse(size[0].toString()), top: double.parse(size[1].toString()), right: double.parse(size[2].toString()), bottom: double.parse(size[3].toString())),
      width: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(radius)),
        border: Border.all(
            width: 1,
            color: Colors.black,
            style: BorderStyle.solid
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(opacity),
            spreadRadius: 5,
            blurRadius: blur,
            offset: Offset(shadowOffsetX, shadowOffsetY), // changes position of shadow
          ),
        ],
      ),
      child: widget,
    );
  }

  static Widget buildFixedContainer(Widget widget, var margin, double radius,
      double shadowOffsetX, double shadowOffsetY, double opacity, double blur, double height, double width){
    return new Container(
      margin: EdgeInsets.only(left: double.parse(margin[0].toString()), top: double.parse(margin[1].toString()), right: double.parse(margin[2].toString()), bottom: double.parse(margin[3].toString())),
      height: width,
      width: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(radius)),
        border: Border.all(
            width: 1,
            color: Colors.black,
            style: BorderStyle.solid
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(opacity),
            spreadRadius: 5,
            blurRadius: blur,
            offset: Offset(shadowOffsetX, shadowOffsetY), // changes position of shadow
          ),
        ],
      ),
      child: widget,
    );
  }

  static Widget buildFreeContainer(Widget widget, double radius,
      double shadowOffsetX, double shadowOffsetY, double opacity, double blur){
    return new Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(radius)),
        border: Border.all(
            width: 1,
            color: Colors.black,
            style: BorderStyle.solid
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(opacity),
            spreadRadius: 5,
            blurRadius: blur,
            offset: Offset(shadowOffsetX, shadowOffsetY), // changes position of shadow
          ),
        ],
      ),
      child: widget,
    );
  }
}