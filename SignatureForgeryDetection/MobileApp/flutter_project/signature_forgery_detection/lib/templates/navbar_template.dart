// Basic Imports
import 'package:flutter/material.dart';

// Models
import 'package:signature_forgery_detection/models/navbar.dart';

class NavBarTemplate {
  static final _FABcolor = new Color(0xFF00227B);
  static final _bottomNavBarColor = new Color(0xFF3949AB);

  static buildFAB(IconData icon, Function onTapFunction, String heroTag){
    return new FloatingActionButton(
      onPressed: onTapFunction,
      shape: CircleBorder(),
      backgroundColor: _FABcolor,
      heroTag: heroTag,
      child: new Icon(
        icon,
        color: new Color(0xFFFFFFFF).withOpacity(0.8),
      ),
    );
  }

  static buildTripletItems(List<IconData> icons, List<String> labels){
    return [
      BottomNavigationBarItem(
        icon: new Icon(icons[0]),
        title: new Text(labels[0]),
      ),
      BottomNavigationBarItem(
        icon: new Icon(Icons.home, size: 5,),
        title: new Padding(padding: EdgeInsets.only(top: 20), child: new Text('Home'),),
      ),
      BottomNavigationBarItem(
          icon: Icon(icons[1]),
          title: Text(labels[1])
      ),
    ];
  }

  static buildBottomNavBar(NavBar navBar, List<BottomNavigationBarItem> bitems, Function onTapFunction, Widget FAB, Widget returnScreen){
    return new Scaffold(
      extendBody: true, //Transparent Notch
      bottomNavigationBar: new BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 6,
        clipBehavior: Clip.antiAlias,
        child: new BottomNavigationBar(
          backgroundColor: _bottomNavBarColor,
          unselectedItemColor: new Color(0xFFFFFFFF).withOpacity(0.6),
          selectedItemColor: Colors.white,
          items: bitems,
          onTap: (index) {
            onTapFunction(index);
          },
          currentIndex: navBar.getNavIndex(),
        ),
      ),
      floatingActionButton: FAB,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: returnScreen,
    );
  }

  static Widget buildAppBar(BuildContext context, String tittle, Widget bodyWidget){
    return new Scaffold(
      appBar: new AppBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: new BoxDecoration(
            gradient: new LinearGradient(
                colors: [
                  const Color(0x003949AB),
                  const Color(0xFF002FD3),
                ],
                begin: const FractionalOffset(0.0, 0.0),
                end: const FractionalOffset(1.0, 0.0),
                stops: [0.0, 1.0],
                tileMode: TileMode.clamp),
          ),
        ),
        title: Text(tittle, style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700)),
        leading: new IconButton (
          color: Colors.black,
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.arrow_back, color: Colors.black),
        ),
      ),
      body: new Center(
        child: bodyWidget,
      ),
    );
  }
}