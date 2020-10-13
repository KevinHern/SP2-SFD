// Basic Imports
import 'package:flutter/material.dart';

// Models
import 'package:signature_forgery_detection/models/log.dart';

// Templates
import 'package:signature_forgery_detection/templates/container_template.dart';
import 'package:signature_forgery_detection/templates/button_template.dart';
import 'package:signature_forgery_detection/templates/dialog_template.dart';
import 'package:signature_forgery_detection/templates/navbar_template.dart';

// Backend
import 'package:signature_forgery_detection/backend/log_query.dart';

class LogInfoScreen extends StatelessWidget {
  final Log log;

  LogInfoScreen({Key key, @required this.log});

  @override
  Widget build(BuildContext context) {
    return NavBarTemplate.buildAppBar(
      context,
      'Record Details',
      LogInfo(log: this.log),
    );
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
          child: new Text(
            "Issue Date: " + this.log.getDate()
            + "\n\nDescription: " + (this.log.getFieldByString("who") as String) + " " + (this.log.getFieldByString("description") as String) + " " + (this.log.getFieldByString("victim") as String)
            + "\n\nReason: " + (this.log.getFieldByString("reason") as String),
            style: new TextStyle(fontSize: 18),
          ),
        ),
      ),
      [0,0,0,0], 20,
      10, 10, 0.15, 30,
    );
  }

  Future _applyAction(String text, int action) async{
    DialogTemplate.initLoader(context, text);
    int code = await (new QueryLog()).doLogAction(this.log, action);
    DialogTemplate.terminateLoader();
    setState((){});
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
              int code = await this._applyAction("Approving action...", 1);
              if(code == 1) {
                DialogTemplate.showLogConfirmationMessage(context, "You have approved the request");
              }
              else {
                DialogTemplate.showMessage(context, "An error has occurred, try again");
              }
            },
            0xFF18BD28,
            "Approve",
            0xFFFFFFFF,
          ),
          ButtonTemplate.buildBasicButton(
            () async {
              int code = await this._applyAction("Denying action...", 0);
              if(code == 1) {
                DialogTemplate.showLogConfirmationMessage(context, "You have denied the request.");
              }
              else {
                DialogTemplate.showMessage(context, "An error has occurred, try again");
              }
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
        this._buildButtons(this.log.getFieldByString("type") == 1 && this.log.getFieldByString("status") == 1),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return this._buildLogInfo();
  }
}