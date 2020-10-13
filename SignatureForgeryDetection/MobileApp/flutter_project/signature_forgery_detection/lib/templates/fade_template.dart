import 'package:flutter/material.dart';

class FadeAnimation{
  AnimationController _animationController;
  Animation _animation;

  FadeAnimation(TickerProvider tickerProvider){
    this._animationController = AnimationController(
      vsync: tickerProvider,
      duration: Duration(milliseconds: 750),
    );

    this._animation = CurvedAnimation(parent: this._animationController, curve: Curves.easeIn);
  }

  Widget fadeNow(Widget childWidget){
    this._animationController.value = 0;
    this._animationController.forward();
    return new FadeTransition(
      opacity: this._animation,
      child: childWidget,
    );
  }
}