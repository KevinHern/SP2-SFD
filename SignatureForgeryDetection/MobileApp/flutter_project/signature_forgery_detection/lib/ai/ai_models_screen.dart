// Basic Imports
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:signature_forgery_detection/models/airesponse.dart';
import 'package:signature_forgery_detection/models/employee.dart';

// Templates
import 'package:signature_forgery_detection/templates/dialog_template.dart';
import 'package:signature_forgery_detection/templates/navbar_template.dart';

// Backend
import 'package:signature_forgery_detection/backend/aihttp.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AIMainScreen extends StatelessWidget {
  final Employee employee;
  final bool isClient;
  AIMainScreen({Key key, @required this.employee, @required this.isClient});

  @override Widget build(BuildContext context) {
    return NavBarTemplate.buildAppBar(context,
      'AI Client Models',
      new AIModel(isClient: this.isClient, employee: this.employee,),
    );
  }
}

class AIModel extends StatefulWidget {
  bool isClient;
  Employee employee;

  AIModel({Key key, @required this.isClient, @required this.employee});
  AIModelState createState() => AIModelState(isClient: this.isClient, employee: this.employee);
}

class AIModelState extends State<AIModel>{
  bool isClient, showSiamese, showConvolutional, showSignerSignature;
  Employee employee;

  final Color _iconColor = new Color(0xFF002FD3).withOpacity(0.60);

  AIModelState({Key key, @required this.isClient, @required this.employee});

  @override
  initState(){
    super.initState();

    this.showSiamese = false;
    this.showConvolutional = false;
    this.showSignerSignature = false;
  }

  AIResponse ai_conv, ai_ss, ai_sms;

  Widget _buildTrainButton(int model){
    return new Padding(padding: EdgeInsets.only(left: 10, right: 10),
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        //padding: new EdgeInsets.only(left: 20, right: 20),
        onPressed: () async {
          // Execute HTTP request
          // All good
          String aiserver_link = "";
          final CollectionReference misc = FirebaseFirestore.instance.collection('miscellaneous');
          await misc.doc("aiserver").get().then((
              snapshot) {
            if(snapshot.exists) {
              aiserver_link = snapshot.get("server");
            }
          });

          if(aiserver_link.isNotEmpty){
            DialogTemplate.initLoader(context, "Please, wait for a moment...");
            if (model == 1) this.ai_conv = await AIHTTPRequest.trainRequest(aiserver_link, model, this.isClient, "");
            else if (model == 21) this.ai_ss = await AIHTTPRequest.trainRequest(aiserver_link, model, this.isClient, "");
            else this.ai_sms = await AIHTTPRequest.trainRequest(aiserver_link, model, this.isClient, "");
            DialogTemplate.terminateLoader();
          }
        },
        color: new Color(0xFF002FD3),
        textColor: Colors.white,
        child: Text("Train Model",
            style: TextStyle(fontSize: 18)),
      ),
    );
  }

  Widget _buildFetchButton(int model, bool shouldSHow) {
    return new Padding(padding: EdgeInsets.only(left: 10, right: 10),
      child: new Visibility(
        visible: shouldSHow,
        child: RaisedButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          //padding: new EdgeInsets.only(left: 20, right: 20),
          onPressed: () async {
            // Execute HTTP request
            // All good
            String aiserver_link = "";
            final CollectionReference misc = FirebaseFirestore.instance.collection('miscellaneous');
            await misc.doc("aiserver").get().then((
                snapshot) {
              if(snapshot.exists) {
                aiserver_link = snapshot.get("server");
              }
            });

            if(aiserver_link.isNotEmpty){
              DialogTemplate.initLoader(context, "Please, wait for a moment...");
              if (model == 1) this.ai_conv = await AIHTTPRequest.modelRequest(aiserver_link, model, "", this.isClient);
              else if (model == 21) this.ai_ss = await AIHTTPRequest.modelRequest(aiserver_link, model, "", this.isClient);
              else this.ai_sms = await AIHTTPRequest.modelRequest(aiserver_link, model, "", this.isClient);
              DialogTemplate.terminateLoader();

              if(model == 1 && this.ai_conv != null) this.showConvolutional = true;
              else if(model == 21 && this.ai_ss != null) this.showSignerSignature = true;
              else if(model == 3 && this.ai_sms != null) this.showSiamese = true;
              else {
                DialogTemplate.showMessage(context, "The model you requested does not exist.");
              }
            }
            setState(() {});
          },
          color: new Color(0xFF002FD3),
          textColor: Colors.white,
          child: Text("Fetch Data",
              style: TextStyle(fontSize: 18)),
        ),
      ),
    );
  }

  Widget _buildCollapsibleTile(IconData icon, String text, int model, bool shouldSHow){
    return ExpansionTile(
      leading: new Icon(icon, color: this._iconColor),
      title: Text(
        text,
        style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold
        ),
      ),
      children: <Widget>[
        this._buildFetchButton(model, !shouldSHow),
        new Divider(color: new Color(0x000000).withOpacity(0.15), thickness: 1,),
        new Visibility(
          visible: shouldSHow,
          child: new Column(
            children: <Widget>[
              new ListTile(
                leading: new Icon(Icons.access_time, color: this._iconColor,),
                title: new Text("Last Date Trained"),
                subtitle: (model == 1)? ((this.ai_conv == null)? new Text("") : new Text(this.ai_conv.getModelLastDate())) :
                (model == 21)? ((this.ai_ss == null)? new Text("") : new Text(this.ai_ss.getModelLastDate())) :
                ((this.ai_sms == null)? new Text("") : new Text(this.ai_sms.getModelLastDate())),
              ),
              new ListTile(
                leading: new Icon(Icons.group, color: this._iconColor),
                title: new Text("People used to train " + (this.isClient? "(clients)" : "(employees)") +  ":"),
                subtitle: (model == 1)? ((this.ai_conv == null)? new Text("") : new Text(this.ai_conv.getModelSigners())) :
                (model == 21)? ((this.ai_ss == null)? new Text("") : new Text(this.ai_ss.getModelSigners())) :
                ((this.ai_sms == null)? new Text("") : new Text(this.ai_sms.getModelSigners())),
              ),
              new Divider(color: new Color(0x000000).withOpacity(0.15), thickness: 1,),
              this._buildTrainButton(model),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new ListView(
      children: <Widget>[
        this._buildCollapsibleTile(Icons.pages, "Convolutional Model", 1, this.showConvolutional),
        this._buildCollapsibleTile(Icons.contacts, "Signer-Signature Model", 21, this.showSignerSignature),
        this._buildCollapsibleTile(Icons.settings_overscan, "Siamese Model", 3, this.showSiamese),
        //new Text((isClient)? "Client!" : "Employee!")
      ],
    );
  }
}