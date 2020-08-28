// Basic Imports
import 'package:flutter/material.dart';

// Templates
import 'package:signature_forgery_detection/templates/container_template.dart';

// Routes
import 'package:signature_forgery_detection/employee/employee_information.dart';

class SearchPeople extends StatefulWidget{

  SearchPeopleState createState() => SearchPeopleState();
}

class SearchPeopleState extends State<SearchPeople> {

  final TextEditingController _searchBarControler = new TextEditingController();
  final int _iconColor = 0xff3949AB;

  Widget _buildFilter() {
    return null;//FormTemplate.buildDropDown(items, displaying);
  }

  Widget _buildSearchBar(){
    return new Container(
        padding: EdgeInsets.only(left: 8.0, right: 8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          border: Border.all(
              width: 1,
              color: Colors.black,
              style: BorderStyle.solid
          ),
        ),
        child: new Padding(
          padding: EdgeInsets.only(left: 10, right: 5),
          child: new TextFormField(
            decoration: InputDecoration(
              icon: Icon(Icons.search, color: new Color(0x00000000).withOpacity(0.60), size: 35,),
              labelText: "Type here...",
              fillColor: Colors.white,
              labelStyle: new TextStyle(
                color: Colors.grey,
              ),
              enabledBorder:  OutlineInputBorder(
                borderSide: BorderSide(color: Color(0x00000000), width: 0.0),
                borderRadius: new BorderRadius.circular(15.0),
              ),
              focusedBorder:OutlineInputBorder(
                borderSide:  BorderSide(color: Color(0x00000000), width: 2.0),
                borderRadius: BorderRadius.circular(0.0),
              ),
            ),
            controller: this._searchBarControler,
          ),
        )
    );
  }

  Widget _buildSearchButton(){
    return new Padding(padding: EdgeInsets.only(left: 30, right: 30, top: 20, bottom: 10),
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        //padding: new EdgeInsets.only(left: 20, right: 20),
        onPressed: () {},
        color: new Color(0xFF002FD3),
        textColor: Colors.white,
        child: Text("Search",
            style: TextStyle(fontSize: 18)),
      ),
    );
  }

  Widget _buildDivider(){
    return new Divider(
      color: new Color(0xFFC7C7C7),
      thickness: 1,
    );
  }

  Widget _buildPersonTile(String name, String uid){
    return ContainerTemplate.buildContainer(
      new ListTile(
        leading: new Padding(padding: EdgeInsets.only(left: 0,), child: new Icon(Icons.person_pin, size: 40, color: new Color(this._iconColor).withOpacity(0.9),),),
        title: new Wrap(
          children: <Widget>[new Text(name, style: new TextStyle(fontSize: 20), textAlign: TextAlign.left,)],
        ),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => EmployeeInfoScreen(uid: uid)));
        },
      ),
      [10,10,10,10],
      15,
      5, 5, 0.15, 30,
    );
  }

  Widget _buildDisplayPeople() {
    return new Container(
      decoration: new BoxDecoration(
        border: Border.all(
            width: 1,
            color: Color(0xFFd9b0ff).withOpacity(0.5),
            style: BorderStyle.solid
        ),
        borderRadius: BorderRadius.all(Radius.circular(15)),
      ),
      width: double.infinity,
      height: 500,
      // REPLACE THIS LISTVIEW WITH LISTVIEW BUILDER WHEN IMPLEMENTING BACKEND
      child: new ListView(
        children: <Widget>[
          this._buildPersonTile("Dummy Dummy Bolonguis Tulilis", "1"),
          this._buildPersonTile("Tulio Jose Triviño Zúñiga", "2"),
        ],
      ),
    );
  }

  Widget _buildShowResults(){
    return new ListView(
      padding: new EdgeInsets.only(left: 30, right: 30, top: 50, bottom: 40),
      children: <Widget>[
        this._buildSearchBar(),
        this._buildSearchButton(),
        this._buildDivider(),
        this._buildDisplayPeople()
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) currentFocus.unfocus();
      },
      child: this._buildShowResults(),
    );
  }
}