// Basic Imports
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:signature_forgery_detection/models/employee.dart';

// Routes
import 'package:signature_forgery_detection/client/client_form.dart';
import 'package:signature_forgery_detection/client/client_search.dart';
import 'package:signature_forgery_detection/ai/ai_models_screen.dart';

// Templates
import 'package:signature_forgery_detection/templates/container_template.dart';
import 'package:signature_forgery_detection/templates/fade_template.dart';
import 'package:signature_forgery_detection/templates/navbar_template.dart';

// Models
import 'package:signature_forgery_detection/models/navbar.dart';

class MainClientScreen extends StatefulWidget {
  final Employee employee;
  MainClientScreen({Key key, @required this.employee}) : super(key: key);

  @override
  MainClientScreenState createState() => MainClientScreenState(employee: this.employee);
}

class MainClientScreenState extends State<MainClientScreen> with SingleTickerProviderStateMixin {
  NavBar navBar;
  final Employee employee;
  FadeAnimation _fadeAnimation;

  @override
  void initState(){
    super.initState();
    navBar = new NavBar(1, 1);
    _fadeAnimation = new FadeAnimation(this);
  }

  MainClientScreenState({@required this.employee});

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
                    "Client Section",
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
                    "In this section you can consult all the information related to the clients.\nYou can also register new clients\n\n"
                        "Additionally you can consult some AI models",
                    style: new TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
            [30, 0, 30, 30], 25,
            15, 15, 0.15, 30,
          ),
          new Visibility(
            visible: this.employee.getPowers(),
            child: ContainerTemplate.buildTileOption(
                Icons.android,
                "AI Models",
                    () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => AIMainScreen(isClient: true, employee: this.employee))).then((value) => setState(() {}));
                }
            ),
          ),
        ],
      ),
    );
  }

  Widget returnScreen() {
    switch(this.navBar.getPageIndex()) {
      case 0:
        return new RegisterClient(issuer: this.employee.getParameterByString("name") + " " + this.employee.getParameterByString("lname"),);
      case 1:
        return defaultScreen();
      case 2:
        return new SearchPeople(issuer: this.employee.getParameterByString("name") + " " + this.employee.getParameterByString("lname"), issuerPowers: this.employee.getPowers(),);
      default:
        return new Container();
    }
  }

  void navOnTap(index){
    setState(() {
      this.navBar.setBoth(index);
      this.navBar.setOnMainScreen(index == 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return NavBarTemplate.buildBottomNavBar(
      this.navBar,
      NavBarTemplate.buildTripletItems([Icons.person_add, Icons.search], ["Register Client", "Search"]),
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
        "client_main_fab"
      ),
      this._fadeAnimation.fadeNow(this.returnScreen()),
    );
  }
}