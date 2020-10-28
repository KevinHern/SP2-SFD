// Basic Imports
import 'package:flutter/material.dart';
import 'package:signature_forgery_detection/templates/dialog_template.dart';
import 'models/option.dart';

// Routes
import 'package:signature_forgery_detection/profile/profile_screen.dart';
import 'package:signature_forgery_detection/client/client_main_screen.dart';
import 'package:signature_forgery_detection/employee/employee_main_screen.dart';
import 'package:signature_forgery_detection/log/logs_main_screen.dart';

// Templates
import 'package:signature_forgery_detection/templates/container_template.dart';
import 'package:signature_forgery_detection/templates/navbar_template.dart';
import 'package:signature_forgery_detection/templates/fade_template.dart';

// Models
import 'package:signature_forgery_detection/models/navbar.dart';
import 'package:signature_forgery_detection/models/employee.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Screen extends StatelessWidget {
  final Employee employee;
  final bool isActive;
  Screen({Key key, @required this.employee, @required this.isActive});

  @override
  Widget build(BuildContext context) {
    return MainScreen(employee: this.employee, isActive: this.isActive,);
  }
}

class MainScreen extends StatefulWidget {
  final Employee employee;
  final bool isActive;
  MainScreen({Key key, @required this.employee, @required this.isActive}) : super(key: key);

  @override
  MainScreenState createState() => MainScreenState(employee: this.employee, isActive: this.isActive);
}

class MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
  final Employee employee;
  bool isActive;
  //Option option;
  NavBar navBar;
  final int _iconLabelColor = 0xFF002FD3;
  final int _borderColor = 0xff856fdd;
  final int _borderoFocusColor = 0xff5436cf;
  FadeAnimation _fadeAnimation;

  @override
  void initState(){
    super.initState();
    navBar = new NavBar(1, 1);
    this._fadeAnimation = new FadeAnimation(this);
  }

  MainScreenState({Key key, @required this.employee, @required this.isActive});

  Widget manyOptionsScreen() {
    return new Center(
      child: ListView(
        shrinkWrap: true,
        children: <Widget>[
          ContainerTemplate.buildTileOption(
            Icons.person,
            "Check\nClients",
                () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => MainClientScreen(employee: this.employee,)));
            },
          ),
          ContainerTemplate.buildTileOption(
            Icons.work,
            "Check\nWorkers",
                () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => MainEmployeeScreen(employee: this.employee,)));
            },
          ),
          ContainerTemplate.buildTileOption(
              Icons.receipt,
              "Check\nLogs",
                  () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => LogScreen()));
              }
          ),
        ],
      ),
    );
  }

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
                    "Signature Forgery Detection",
                    style: new TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 30,
                        color: new Color(0xFF002FD3)
                    ),
                    textAlign: TextAlign.center,
                  ),
                  new Padding(
                    padding: new EdgeInsets.only(bottom: 5, top: 5),
                    child: new Divider(color: new Color(0x000000).withOpacity(0.15), thickness: 1,),
                  ),
                  new Text(
                    "Professional Seminary II\nKevin Hernández - 17001095",
                    style: new TextStyle(fontSize: 18), textAlign: TextAlign.center,
                  ),
                  new Padding(
                    padding: new EdgeInsets.only(bottom: 5, top: 5),
                    child: new Divider(color: new Color(0x000000).withOpacity(0.15), thickness: 1,),
                  ),
                  new Text(
                    "This is a mobile app to show a real life application of the research done.",
                    style: new TextStyle(fontSize: 15),
                  ),
                ],
              ),
            ),
            [30, 0, 30, 30], 25,
            15, 15, 0.15, 30,
          ),
          new Visibility(
            visible: employee.getPowers(),
            child: ContainerTemplate.buildContainer(
                new Padding(
                  padding: EdgeInsets.only(left: 10, top: 5, bottom: 5),
                  child: new Padding(
                    padding: EdgeInsets.only(left: 8.0, bottom: 5.0, top: 5.0, right: 8.0),
                    child: new ListTile(
                      leading: new Icon(Icons.add_to_home_screen, color: Color(this._iconLabelColor).withOpacity(0.60),),
                      title: new Text((this.isActive? "Deactivate" : "Activate") + " the services", style: new TextStyle(
                        color: new Color(this._iconLabelColor),
                      ),
                      ),
                      trailing: Switch(
                        value: this.isActive,
                        onChanged: (value) async {
                          this.isActive = value;
                          final CollectionReference misc = FirebaseFirestore.instance.collection('miscellaneous');
                          DialogTemplate.initLoader(context, "Please, wait for a moment...");
                          await misc.doc("active").set({
                            'isActive': this.isActive
                          });
                          DialogTemplate.terminateLoader();
                          DialogTemplate.showMessage(context, (this.isActive? "Reactivated the services." : "Deactivated the services."));
                          setState(() {});
                        },
                        activeTrackColor: new Color(this._borderoFocusColor),
                        activeColor: new Color(this._borderColor),
                      ),
                    ),
                  ),
                ),
                [30, 15, 30, 15],
                10, 15, 5, 0.15, 30
            ),
          )
        ],
      ),
    );
  }

  Widget returnScreen() {
    Widget to_show;
    switch(this.navBar.getPageIndex()) {
      case 0:
        to_show = this.manyOptionsScreen();
        break;
      case 1:
        to_show = this.defaultScreen();
        break;
      case 2:
        to_show = ProfileScreen(employee: this.employee,);
        break;
      default:
        to_show = new Container();
        break;
    }
    return to_show;
  }

  void navOnTap(index){
    print(this.employee.getPowers()? "Has powers": "does not have powers");
    setState(() {
      this.navBar.setBoth(index);
      if(this.navBar.getPageIndex() == 0 && !this.employee.getPowers()) {
        this.navBar.setBoth(1);
        Navigator.push(context, MaterialPageRoute(builder: (context) => MainClientScreen(employee: this.employee,)));
      }
      else {
        this.navBar.setBoth(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return NavBarTemplate.buildBottomNavBar(
      this.navBar,
      NavBarTemplate.buildTripletItems([Icons.menu, Icons.person], ["Menu", "Profile"]),
      navOnTap,
      NavBarTemplate.buildFAB(
          Icons.home,
              () {
            setState(() {
              this.navBar.setBoth(1);
            });
          },
          "main_screen_fab"
      ),
      this._fadeAnimation.fadeNow(this.returnScreen()),
    );
  }
}