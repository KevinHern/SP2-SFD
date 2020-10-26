// Basic Imports
import 'package:flutter/material.dart';

// Models
import 'package:signature_forgery_detection/models/employee.dart';

// Templates
import 'package:signature_forgery_detection/templates/container_template.dart';
import 'package:signature_forgery_detection/templates/stream_template.dart';

// Routes
import 'package:signature_forgery_detection/employee/employee_information.dart';

// Backend
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class SearchPeople extends StatefulWidget{
  final String issuer;
  SearchPeople({Key key, @required this.issuer});
  SearchPeopleState createState() => SearchPeopleState(issuer: this.issuer);
}

class SearchPeopleState extends State<SearchPeople> {
  final String issuer;
  final TextEditingController _searchBarControler = new TextEditingController();
  final int _iconColor = 0xff3949AB;
  List<String> _options = ['name', 'lname', 'email'];
  String _selectedOption;

  SearchPeopleState({Key key, @required this.issuer});

  @override
  void initState(){
    super.initState();
    this._selectedOption = _options[0];
  }

  String mapOption(String option){
    switch(option){
      case 'name':
        return 'Name';
      case 'lname':
        return 'Last Name';
      case 'email':
        return 'Email';
      default:
        return '';
    }
  }

  Widget _buildFilter() {
    return new Container(
        padding: EdgeInsets.only(left: 20.0, right: 20.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(25)),
          border: Border.all(
              width: 1,
              color: Colors.black,
              style: BorderStyle.solid
          ),
        ),
        child: new Padding(
          padding: EdgeInsets.only(left: 25, right: 25),
          child: new Center(
            child: new DropdownButton(
              hint: Text(''), // Not necessary for Option 1
              value: _selectedOption,
              onChanged: (newValue) {
                setState(() {
                  _selectedOption = newValue;
                  print(_selectedOption);
                });
              },
              items: _options.map((option) {
                return DropdownMenuItem(
                  child: new Text(this.mapOption(option)),
                  value: option,
                );
              }).toList(),
            ),
          ),
        )
    );
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
            onEditingComplete: (){
              setState(() {

              });
            },
          ),
        )
    );
  }

  Widget _buildSearchButton(){
    return ContainerTemplate.buildBasicButton(
      () {
        ;
      },
      Text("Search",
        style: TextStyle(fontSize: 18),
      ),
    );
  }

  Widget _buildDivider(){
    return new Divider(
      color: new Color(0xFFC7C7C7),
      thickness: 1,
    );
  }

  Widget _buildPersonTile(DocumentSnapshot snapshot) {
    Employee employee = new Employee(
      snapshot.get("name"), snapshot.get("lname"),
      snapshot.get("email"),
      snapshot.get("phone"), snapshot.get("birthday"),
      snapshot.get("department"), snapshot.get("position"),
      snapshot.get("init"), snapshot.get("end"),
    );
    employee.setPowers(snapshot.get("powers"));
    employee.setUID(snapshot.id);

    return ContainerTemplate.buildContainer(
      new ListTile(
        leading: new Padding(padding: EdgeInsets.only(left: 0,), child: new Icon(Icons.person_pin, size: 40, color: new Color(this._iconColor).withOpacity(0.9),),),
        title: new Wrap(
          children: <Widget>[new Text(employee.getParameterByString("name") + " " + employee.getParameterByString("lname"), style: new TextStyle(fontSize: 20), textAlign: TextAlign.left,)],
        ),
        onTap: () async {
          try{
            String url = await FirebaseStorage.instance.ref().child("employees/" + employee.getUID() + "/profile.jpg").getDownloadURL();
            employee.setProfilePicURL(url);
          }
          catch(error){
            employee.setProfilePicURL('https://www.woolha.com/media/2020/03/eevee.png');
          }
          Navigator.push(context, MaterialPageRoute(builder: (context) => EmployeeInfoScreen(employee: employee, issuer: this.issuer,)));
        },
      ),
      [10,10,10,10],
      15,
      5, 5, 0.15, 30,
    );
  }

  Widget _buildDisplayPeople() {
    List<String> searchWords = [];
    for(int i = 0; i < _searchBarControler.text.length; i++){
      searchWords.add(_searchBarControler.text.substring(0, 0 + i + 1));
    }
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
      child: (new StreamTemplate()).buildStreamWithContext(
          false,
          "No matches where found",
          (_searchBarControler.text.isNotEmpty)?
              //FirebaseFirestore.instance.collection("employees").where('name', isGreaterThanOrEqualTo: _searchBarControler.text).snapshots() : FirebaseFirestore.instance.collection("employees").snapshots(),
              FirebaseFirestore.instance.collection("employees").orderBy(_selectedOption, descending: false).where(_selectedOption, isGreaterThanOrEqualTo: _searchBarControler.text).snapshots() :
              FirebaseFirestore.instance.collection("employees").orderBy(_selectedOption, descending: false).snapshots(),
              (context, doc) => _buildPersonTile(doc)
      ),
    );
  }

  Widget _buildShowResults(){
    return new ListView(
      padding: new EdgeInsets.only(left: 30, right: 30, top: 50, bottom: 100),
      children: <Widget>[
        new Padding(padding: EdgeInsets.only(left: 50, right: 50, bottom: 10), child: this._buildFilter(),),
        this._buildSearchBar(),
        //this._buildSearchButton(),
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