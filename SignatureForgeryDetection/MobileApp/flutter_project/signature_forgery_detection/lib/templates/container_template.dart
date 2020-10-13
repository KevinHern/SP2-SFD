import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ContainerTemplate {
  static final _tileIconColor = new Color(0xff3949AB);
  static final _buttonColor = new Color(0xFF002FD3);
  static final _buttonSplashColor = new Color(0xFF001f6e);

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

  static Widget buildTileOption(IconData icon, String text, Function routing){
    return ContainerTemplate.buildFixedContainer(
      new Center(
        /*child: new ListTile(
          leading: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Icon(icon, size: 80, color: _tileIconColor.withOpacity(0.9)),
              new Text(text, style: new TextStyle(fontSize: 38), textAlign: TextAlign.center,)
            ],
          ), //new Icon(icon, size: 80, color: _tileIconColor.withOpacity(0.9)),
          title: new Wrap(
            children: <Widget>[new Text(text, style: new TextStyle(fontSize: 38), textAlign: TextAlign.center,)],
          ),
          onTap: routing,
        ), */
        child: new GestureDetector(
          onTap: routing,
          child: new Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              new Icon(icon, size: 80, color: _tileIconColor.withOpacity(0.9)),
              new Wrap(
                children: <Widget>[new Text(text, style: new TextStyle(fontSize: 40), textAlign: TextAlign.center,)],
              ),
            ],
          ),
        ),
      ),
      [35, 15, 35, 0], 25,
      15, 15, 0.15, 30,
      120, 120,
    );
  }

  static buildBasicButton(Function onTap, Widget textWidget){
    return new RaisedButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0),
      ),
      //padding: new EdgeInsets.only(left: 20, right: 20),
      onPressed: onTap,
      color: _buttonColor,
      splashColor: _buttonSplashColor,
      textColor: Colors.white,
      child: textWidget,
    );
  }
}