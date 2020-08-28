// Basic Imports
import 'package:flutter/material.dart';

// Routes
import 'package:signature_forgery_detection/log/log_information.dart';
import 'package:signature_forgery_detection/models/log.dart';

// Templates
import 'package:signature_forgery_detection/templates/container_template.dart';
import 'package:signature_forgery_detection/templates/button_template.dart';

class MainLogScreen extends StatefulWidget {
  MainLogScreen({Key key}) : super(key: key);

  @override
  MainLogScreenState createState() => MainLogScreenState();
}

class MainLogScreenState extends State<MainLogScreen> {
  String registerText = "", searchText = "";
  final int _iconColor = 0xff3949AB;
  String _filterText;
  var visibleLogs = [];
  var _logIcons = [];
  var _logs = [];

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

    this._logs.add(new Log("log0", LogType.INFO, "overview", "description", LogStatus.SHOW));
    this._logs.add(new Log("log0", LogType.REPORT, "overview", "description", LogStatus.PENDING));
    this._logs.add(new Log("log0", LogType.CHECK, "overview", "description", LogStatus.SHOW));
    this._logs.add(new Log("log0", LogType.INFO, "overview", "description", LogStatus.SHOW));
    this._logs.add(new Log("log0", LogType.REPORT, "overview", "description", LogStatus.APPROVED));
    this._logs.add(new Log("log0", LogType.CHECK, "overview", "description", LogStatus.SHOW));
  }

  MainLogScreenState() : this._filterText = "Show today logs";

  Widget _buildFilter() {
    return null;//FormTemplate.buildDropDown(items, displaying);
  }

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
          title: new Text(this._filterText),
          trailing: new Icon(Icons.arrow_drop_down),
          onTap: () {

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

  Widget _buildLogTile(int index, Log log){
    return new Visibility(
      visible: this.visibleLogs[index],
      child: ContainerTemplate.buildContainer(
        new Column(
          children: <Widget>[
            new ListTile(
              leading: new Padding(padding: EdgeInsets.only(left: 0,), child: this._logIcons[log.getLogTypeAsInt()],),
              title: new Wrap(
                children: <Widget>[new Text(log.getFieldByString("overview"), style: new TextStyle(fontSize: 20), textAlign: TextAlign.left,)],
              ),
            ),
            new Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                ButtonTemplate.buildBasicButton(  // Close Button
                  () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => LogInfoScreen(log: log)));
                  },
                  0xFF002FD3,
                  "View",
                  0xFFFFFFFF
                ),
                ButtonTemplate.buildBasicButton(  // Close Button
                  () {
                    setState(() {
                      this.visibleLogs[index] = false;
                    });
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
      child: new ListView.builder(
        itemCount: this._logs.length,
        itemBuilder: (context, index) {
          return this._buildLogTile(index, this._logs[index]);
        }
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

  Widget buildNavBar(){
    return new Scaffold(
      appBar: new AppBar(
        leading: new IconButton (
          color: Colors.black,
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.arrow_back, color: Colors.black),
        ),
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: new BoxDecoration(
            gradient: new LinearGradient(
                colors: [
                  const Color(0x003949AB),
                  const Color(0xFF3949AB),
                ],
                begin: const FractionalOffset(0.0, 0.0),
                end: const FractionalOffset(1.0, 0.0),
                stops: [0.0, 1.0],
                tileMode: TileMode.clamp),
          ),
        ),
        title: Text('Records', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700)),
      ),
      body: this._buildShowResults(),//this._screens[this._pageIndex],
    );
  }

  @override
  Widget build(BuildContext context) {
    return this.buildNavBar();
  }
}