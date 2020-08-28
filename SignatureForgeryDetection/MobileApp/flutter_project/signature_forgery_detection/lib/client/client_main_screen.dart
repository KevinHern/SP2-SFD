// Basic Imports
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:signature_forgery_detection/models/employee.dart';

// Routes
import 'package:signature_forgery_detection/client/client_form.dart';
import 'package:signature_forgery_detection/client/client_search.dart';

// Templates
import 'package:signature_forgery_detection/templates/container_template.dart';

class MainClientScreen extends StatefulWidget {
  final bool isClient;
  MainClientScreen({Key key, @required this.isClient}) : super(key: key);

  @override
  MainClientScreenState createState() => MainClientScreenState(isClient: this.isClient);
}

class MainClientScreenState extends State<MainClientScreen> {
  int _pageIndex, _navIndex;
  final bool isClient;
  String registerText = "", searchText = "";
  final int _iconColor = 0xff3949AB;

  @override
  void initState(){
    super.initState();
  }

  MainClientScreenState({@required this.isClient}) : this._pageIndex = 1, this._navIndex = 1, registerText = (isClient)? "Register Client" : "Register Employee",
        searchText = (isClient)? "Search Client" : "Search Employee";

  Widget _buildDefaultTile(IconData iconData, String text, int pindex){
    return new Center(
      child: new ListTile(
        leading: new Padding(padding: EdgeInsets.only(left: 0,), child: new Icon(iconData, size: 80, color: new Color(this._iconColor).withOpacity(0.9),),),
        title: new Wrap(
          children: <Widget>[new Text(text, style: new TextStyle(fontSize: 40), textAlign: TextAlign.center,)],
        ),
        onTap: () {
          setState(() {
            this._pageIndex = pindex;
            this._navIndex = pindex;
          });
        },
      ),
    );
  }

  Widget defaultScreen() {
    return new Center(
      child: ListView(
        shrinkWrap: true,
        children: <Widget>[
          ContainerTemplate.buildFixedContainer(
            this._buildDefaultTile(Icons.person_add, registerText, 0),
            [30, 0, 30, 30], 25,
            15, 15, 0.15, 30,
            120, 120,
          ),
          ContainerTemplate.buildFixedContainer(
            this._buildDefaultTile(Icons.search, searchText, 2),
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
        return new RegisterClient();
      case 1:
        return defaultScreen();
      case 2:
        return new SearchPeople();
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
            this._navIndex = index;
            this._pageIndex = this._navIndex;
          }); },
          currentIndex: this._navIndex,
          items: [
            BottomNavigationBarItem(
              icon: new Icon(Icons.person_add),
              title: new Text('Register Client'),
            ),
            BottomNavigationBarItem(
              icon: new Icon(Icons.home, size: 15,),
              title: new Text('Home'),
            ),
            BottomNavigationBarItem(
              icon: new Icon(Icons.search),
              title: new Text('Search'),
            ),
          ],
        ),
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: () => Navigator.of(context).pop(),
        shape: CircleBorder(),
        backgroundColor: new Color(0xFFFFFFFF),
        child: new Icon(
          Icons.home,
          color: new Color(0xFF00FFAA),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: this.returnScreen(),//this._screens[this._pageIndex],
    );
  }

  @override
  Widget build(BuildContext context) {
    return this.buildNavBar();
  }
}