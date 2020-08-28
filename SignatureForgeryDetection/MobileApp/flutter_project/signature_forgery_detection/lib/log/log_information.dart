// Basic Imports
import 'package:flutter/material.dart';

// Models
import 'package:signature_forgery_detection/models/log.dart';

// Templates
import 'package:signature_forgery_detection/templates/container_template.dart';
import 'package:signature_forgery_detection/templates/button_template.dart';
import 'package:signature_forgery_detection/templates/dialog_template.dart';

// Backend
import 'package:signature_forgery_detection/backend/log_query.dart';

class LogInfoScreen extends StatelessWidget {
  final Log log;

  LogInfoScreen({Key key, @required this.log});

  @override
  Widget build(BuildContext context) {
    return LogInfo(log: this.log);
  }
}

class LogInfo extends StatefulWidget {
  final Log log;

  LogInfo({Key key, @required this.log});

  LogInfoState createState() => LogInfoState(log: this.log);
}

class LogInfoState extends State<LogInfo> {
  final Log log;
  final String _title = "Information";
  final double borderRadius = 15;

  LogInfoState({Key key, @required this.log});

  @override
  void initState(){
    super.initState();
  }

  Widget _buildTitle(){
    return new Container(
      decoration: new BoxDecoration(
        color: new Color(0xFF9CD5FF),
        borderRadius: new BorderRadius.only(
            topLeft: new Radius.circular(this.borderRadius),
            bottomLeft: new Radius.circular(this.borderRadius),
            bottomRight: new Radius.circular(this.borderRadius),
            topRight: new Radius.circular(this.borderRadius),
        ),
      ),
      child: new Text(
        _title,
        style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
      ),
      alignment: Alignment.center,
    );
  }

  Widget _buildBody(){
    return ContainerTemplate.buildContainer(
      new Padding(
        padding: new EdgeInsets.all(10),
        child: new Container(
          constraints: new BoxConstraints(
            minHeight: 200
          ),
          child: new Text(this.log.getFieldByString("description"), style: new TextStyle(fontSize: 18),),
        ),
      ),
      [0,0,0,0], 20,
      10, 10, 0.15, 30,
    );
  }

  Future _applyAction(String text, int action) async{
    DialogTemplate.initLoader(context, text);
    int code = await (new QueryLog()).applyActionOnLog(this.log, action);
    DialogTemplate.terminateLoader();
    setState((){});
    DialogTemplate.showStatusUpdate(context, code);
    return code;
  }

  Widget _buildButtons(bool showApproveOptions){
    Widget buttonGroup = null;
    if(showApproveOptions) {
      buttonGroup = new Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          ButtonTemplate.buildBasicButton(
            () async {
              int code = await this._applyAction("Approving action...", 0);
              DialogTemplate.showStatusUpdate(context, code);
            },
            0xFF18BD28,
            "Approve",
            0xFFFFFFFF,
          ),
          ButtonTemplate.buildBasicButton(
            () async {
              int code = await this._applyAction("Denying action...", 1);
              DialogTemplate.showStatusUpdate(context, code);
            },
            0xFFC30000,
            "Deny",
            0xFFFFFFFF,
          ),
        ],
      );
    }
    else {
      buttonGroup = ButtonTemplate.buildBasicButton(
        () => Navigator.of(context).pop(),
        0xFF006ED4,
        "Ok",
        0xFFFFFFFF,
      );
    }

    return buttonGroup;
  }

  Widget _buildLogInfo(){
    return new ListView(
      padding: new EdgeInsets.only(top: 30, left: 30, right: 30, bottom: 30),
      children: <Widget>[
        this._buildTitle(),
        new Padding(padding: new EdgeInsets.only(top: 20, bottom: 20), child: this._buildBody(),),
        this._buildButtons(this.log.getFieldByString("type") == LogType.REPORT),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
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
        title: Text('Information', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700)),
      ),
      body: this._buildLogInfo(),//
    );
  }
}