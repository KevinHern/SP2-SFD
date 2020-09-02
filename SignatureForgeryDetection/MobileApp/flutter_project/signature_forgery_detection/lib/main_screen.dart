// Basic Imports
import 'package:flutter/material.dart';
import 'package:signature_forgery_detection/models/employee.dart';
import 'models/option.dart';

// Routes
import 'package:signature_forgery_detection/profile/profile_screen.dart';
import 'package:signature_forgery_detection/client/client_main_screen.dart';
import 'package:signature_forgery_detection/employee/employee_main_screen.dart';
import 'package:signature_forgery_detection/log/logs_main_screen.dart';

// Templates
import 'package:signature_forgery_detection/templates/container_template.dart';

class Screen extends StatelessWidget {
  final Employee employee;
  Screen({Key key, @required this.employee});

  @override
  Widget build(BuildContext context) {
    return MainScreen(employee: this.employee,);
  }
}

class MainScreen extends StatefulWidget {
  final Employee employee;
  MainScreen({Key key, @required this.employee}) : super(key: key);

  @override
  MainScreenState createState() => MainScreenState(employee: this.employee);
}

class MainScreenState extends State<MainScreen> {
  final Employee employee;
  int _pageIndex, _navIndex;
  Option option;

  final int _iconColor = 0xff3949AB;

  @override
  void initState(){
    super.initState();
  }

  MainScreenState({Key key, @required this.employee}) : this._pageIndex = 1, this._navIndex = 1;

  Widget _buildDefaultTile(IconData iconData, String text, Function routing){
    return new Center(
      child: new ListTile(
        leading: new Padding(padding: EdgeInsets.only(left: 0,), child: new Icon(iconData, size: 80, color: new Color(this._iconColor).withOpacity(0.9),),),
        title: new Wrap(
          children: <Widget>[new Text(text, style: new TextStyle(fontSize: 40), textAlign: TextAlign.center,)],
        ),
        onTap: routing,
      ),
    );
  }

  Widget manyOptionsScreen() {
    return new Center(
      child: ListView(
        shrinkWrap: true,
        children: <Widget>[
          ContainerTemplate.buildFixedContainer(
            this._buildDefaultTile(
              Icons.person,
              "Check Clients",
              () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => MainClientScreen(isClient: true, employee: this.employee,)));
              },
            ),
            [30, 15, 30, 0], 25,
            15, 15, 0.15, 30,
            120, 120,
          ),
          ContainerTemplate.buildFixedContainer(
            this._buildDefaultTile(
              Icons.work,
              "Check Workers",
                  () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => MainEmployeeScreen(employee: this.employee,)));
              },
            ),
            [30, 30, 30, 0],  25,
            15, 15, 0.15, 30,
            120, 120,
          ),
          ContainerTemplate.buildFixedContainer(
            this._buildDefaultTile(
                Icons.receipt,
                "Check Logs",
                    () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => MainLogScreen()));
                }
            ),
            [30, 30, 30, 0],  25,
            15, 15, 0.15, 30,
            120, 120,
          ),
        ],
      ),
    );
  }

  Widget returnScreen() {
    switch(this._pageIndex) {
      case 0:
        return this.manyOptionsScreen();
      case 1:
        return new Center(child: new Text("* Insertar algo aqui *\n* Me quede sin ideas, tal vez un dashboard? *\n:(", textAlign: TextAlign.center,),);
      case 2:
        return ProfileScreen(employee: this.employee,);
      default:
        throw new NullThrownError();
    }
  }

  Widget buildNavBar(){
    return new Scaffold(
      bottomNavigationBar: new BottomAppBar(
        shape: CircularNotchedRectangle(),
        child: new BottomNavigationBar(
          //backgroundColor: new Color(0xFF3949AB),
          onTap: (index) { setState(() {
            if(index == 0 && !this.employee.getPowers()) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => MainClientScreen(isClient: true, employee: this.employee,)));
            }
            else {
              this._navIndex = index;
              this._pageIndex = this._navIndex;
            }
          }); },
          currentIndex: this._navIndex,
          items: [
            BottomNavigationBarItem(
              icon: new Icon(Icons.menu),
              title: new Text('Menu'),
            ),
            BottomNavigationBarItem(
              icon: new Icon(Icons.home, size: 15,),
              title: new Text('Home'),
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.person),
                title: Text('Profile')
            )
          ],
        ),
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: () {
          setState(() {
            this._navIndex = 1;
            this._pageIndex = 1;
          });
        },
        shape: CircleBorder(),
        backgroundColor: new Color(0xFFFFFFFF),
        child: new Icon(
          Icons.home,
          color: new Color(0xFF00FFAA),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: this.returnScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return this.buildNavBar();
  }
}