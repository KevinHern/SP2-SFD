// Basic Imports
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


// Routes
import 'package:signature_forgery_detection/employee/employee_form.dart';
import 'package:signature_forgery_detection/employee/employee_search.dart';

// Templates
import 'package:signature_forgery_detection/templates/container_template.dart';
import 'package:signature_forgery_detection/templates/fade_template.dart';
import 'package:signature_forgery_detection/templates/navbar_template.dart';

// Models
import 'package:signature_forgery_detection/models/employee.dart';
import 'package:signature_forgery_detection/models/navbar.dart';

class MainEmployeeScreen extends StatefulWidget {
  final Employee employee;
  MainEmployeeScreen({Key key, @required this.employee}) : super(key: key);

  @override
  MainEmployeeScreenState createState() => MainEmployeeScreenState(employee: this.employee);
}

class MainEmployeeScreenState extends State<MainEmployeeScreen> with SingleTickerProviderStateMixin {
  final Employee employee;
  NavBar navBar;
  FadeAnimation _fadeAnimation;
  String registerText = "", searchText = "";
  final int _iconColor = 0xff3949AB;

  @override
  void initState(){
    super.initState();
    this.navBar = new NavBar(1, 1);
    this._fadeAnimation = new FadeAnimation(this);
  }

  MainEmployeeScreenState({Key key, @required this.employee});

  Widget defaultScreen() {
    return new Center(
      child: ListView(
        shrinkWrap: true,
        children: <Widget>[
          ContainerTemplate.buildContainer(
            new Padding(
              padding: new EdgeInsets.all(10),
              child: new Column(
                children: <Widget>[
                  new Text(
                    "Employee Section",
                    style: new TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                        color: new Color(0xFF002FD3)
                    ),
                    textAlign: TextAlign.center,
                  ),
                  new Padding(
                    padding: new EdgeInsets.only(bottom: 5, top: 5),
                    child: new Divider(color: new Color(0x000000).withOpacity(0.15), thickness: 1,),
                  ),
                  new Text(
                    "In this section you can consult all the information related to the employees.\nYou can also register new employees.",
                    style: new TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
            [30, 0, 30, 30], 25,
            15, 15, 0.15, 30,
          ),
        ],
      ),
    );
  }

  Widget returnScreen() {
    switch(this.navBar.getPageIndex()) {
      case 0:
        return RegisterEmployee(issuer: this.employee.getParameterByString("name") + " " + this.employee.getParameterByString("lname"),);
      case 1:
        return defaultScreen();
      case 2:
        return new SearchPeople(issuer: this.employee.getParameterByString("name") + " " + this.employee.getParameterByString("lname"),);
      default:
        throw new NullThrownError();
    }
  }

  void navOnTap(index) {
    setState(() {
      this.navBar.setBoth(index);
      this.navBar.setOnMainScreen(index == 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return NavBarTemplate.buildBottomNavBar(
      this.navBar,
      NavBarTemplate.buildTripletItems([Icons.person_add, Icons.search], ["Register Employee", "Search"]),
      navOnTap,
      NavBarTemplate.buildFAB(
          this.navBar.isOnMainScreen()? Icons.home : Icons.keyboard_return,
              () {
            if(this.navBar.isOnMainScreen()) Navigator.of(context).pop();
            else setState(() {
              this.navBar.setBoth(1);
              this.navBar.setOnMainScreen(true);
            });
          },
          "employee_main_sc_fab"
      ),
      this._fadeAnimation.fadeNow(this.returnScreen()),
    );
  }
}