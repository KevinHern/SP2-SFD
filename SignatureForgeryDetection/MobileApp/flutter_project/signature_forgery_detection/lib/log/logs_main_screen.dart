// Basic Imports
import 'package:flutter/material.dart';
import 'package:signature_forgery_detection/backend/log_query.dart';

// Routes
import 'package:signature_forgery_detection/log/log_information.dart';
import 'package:signature_forgery_detection/models/log.dart';

// Templates
import 'package:signature_forgery_detection/templates/container_template.dart';
import 'package:signature_forgery_detection/templates/button_template.dart';
import 'package:signature_forgery_detection/templates/dialog_template.dart';
import 'package:signature_forgery_detection/templates/navbar_template.dart';

// Bakckend
import 'package:cloud_firestore/cloud_firestore.dart';

class LogScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return NavBarTemplate.buildAppBar(
      context,
      'Records',
      new MainLogScreen(),
    );
  }
}

class MainLogScreen extends StatefulWidget {
  MainLogScreen({Key key}) : super(key: key);

  @override
  MainLogScreenState createState() => MainLogScreenState();
}

class MainLogScreenState extends State<MainLogScreen> {
  String registerText = "", searchText = "";
  TextEditingController _filterText =
  new TextEditingController(text: "${DateTime.parse(new DateTime.now().toString()).day}/${DateTime.parse(new DateTime.now().toString()).month}/${DateTime.parse(new DateTime.now().toString()).year}");
  var visibleLogs = [];
  var _logIcons = [];

  @override
  void initState(){
    super.initState();
    double size = 40.0;

    _logIcons.add(
        new Icon(Icons.info, size: size, color: Colors.blue)
    );
    _logIcons.add(
        new Icon(Icons.report, size: size, color: Colors.red)
    );
    _logIcons.add(
        new Icon(Icons.check_circle, size: size, color: Colors.green)
    );

    this.visibleLogs = [true, true, true, true, true, true];

  }

  MainLogScreenState();

  Widget _buildSearchBar(){
    return new Container(
        padding: EdgeInsets.only(left: 8.0, right: 8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(30)),
          border: Border.all(
              width: 1,
              color: Colors.black,
              style: BorderStyle.solid
          ),
        ),
        child: new ListTile(
          leading: Icon(Icons.search, color: new Color(0x00000000).withOpacity(0.60), size: 35,),
          title: new Text("Date: " + this._filterText.text),
          trailing: new Icon(Icons.arrow_drop_down),
          onTap: () async {
            DateTime date = await showDatePicker(
              context: context,
              firstDate: DateTime(DateTime.now().year-2),
              lastDate: DateTime(DateTime.now().year+1),
              initialDate: DateTime.now(),
            );
            this._filterText.text = "${DateTime.parse(date.toString()).day}/${DateTime.parse(date.toString()).month}/${DateTime.parse(date.toString()).year}";
            setState(() {});
          },
        ),
    );
  }

  Widget _buildDivider(){
    return new Divider(
      color: new Color(0xFFC7C7C7),
      thickness: 1,
    );
  }

  Widget _buildLogTile(DocumentSnapshot snapshot){
    Log log = new Log(
        int.parse(snapshot.id),
        snapshot.get("type"),
        snapshot.get("description"),
        snapshot.get("who"),      // Employee's Name + Last Name
        snapshot.get("victim"),   // Client's Name + Last Name
        snapshot.get("victimid"), // Victim's ID for deletion purposes
        snapshot.get("action"),
        snapshot.get("reason"),
        snapshot.get("status")
    );
    log.setHide(true);
    log.setDate(snapshot.get("date"));
    String overviewTxt = (log.getFieldByString("who") as String) + " " + (log.getFieldByString("description")  as String) + " " + (log.getFieldByString("victim") as String);
    
    return new Visibility(
      visible: log.getHide(),
      child: ContainerTemplate.buildContainer(
        new Column(
          children: <Widget>[
            new ListTile(
              leading: new Padding(padding: EdgeInsets.only(left: 0,), child: this._logIcons[log.logType],),
              title: new Wrap(
                children: <Widget>[new Text(overviewTxt, style: new TextStyle(fontSize: 20), textAlign: TextAlign.left,)],
              ),
            ),
            new Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                ButtonTemplate.buildBasicButton(  // Info Button
                  () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => LogInfoScreen(log: log)));
                  },
                  0xFF002FD3,
                  "View",
                  0xFFFFFFFF
                ),
                ButtonTemplate.buildBasicButton(  // Close Button
                  () async {
                    DialogTemplate.initLoader(context, "Processing...");
                    await (new QueryLog()).hideLog(log);
                    DialogTemplate.terminateLoader();
                    log.setHide(true);
                    setState(() {});
                  },
                  0xFFe30224,
                  "Close",
                  0xFFFFFFFF
                ),
              ],
            ),
          ],
        ),
        [10,10,10,10],
        15,
        5, 5, 0.15, 30,
      ),
    );
  }

  final ScrollController listScrollController = new ScrollController();

  Widget _buildDisplayLogs() {
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
      child: new StreamBuilder(
        stream: FirebaseFirestore.instance.collection("logs").where('date', isEqualTo: _filterText.text).where('hide', isEqualTo: false).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue)));
          } else {
            if (snapshot.data.documents.length > 0) {
              return ListView.builder(
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, index) {
                  return _buildLogTile(snapshot.data.documents[index]);
                },
              );
            }
            else {
              return new AlertDialog(
                title: new Text("Notice"),
                content: new Text("No active logs were found."),
              );
            }
          }
        },
      ),
    );
  }

  Widget _buildShowResults(){
    return new ListView(
      padding: new EdgeInsets.only(left: 30, right: 30, top: 50, bottom: 40),
      children: <Widget>[
        this._buildSearchBar(),
        this._buildDivider(),
        this._buildDisplayLogs()
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return this._buildShowResults();
  }
}