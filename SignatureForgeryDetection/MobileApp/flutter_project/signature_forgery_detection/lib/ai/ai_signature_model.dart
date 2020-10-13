// Basic Imports
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:signature_forgery_detection/models/airesponse.dart';
import 'package:signature_forgery_detection/models/client.dart';
import 'package:signature_forgery_detection/models/employee.dart';


// Templates
import 'package:signature_forgery_detection/templates/dialog_template.dart';
import 'package:signature_forgery_detection/templates/form_template.dart';
import 'package:signature_forgery_detection/templates/navbar_template.dart';

// Backend
import 'package:signature_forgery_detection/backend/aihttp.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AIMainClientScreen extends StatelessWidget {
  final Client client;
  final String issuer;
  AIMainClientScreen({Key key, @required this.issuer, @required this.client});

  @override Widget build(BuildContext context) {
    return NavBarTemplate.buildAppBar(context,
      'Client Signatures',
      new AIModelClient(issuer: this.issuer, client: this.client),
    );
  }
}

class AIModelClient extends StatefulWidget {
  final String issuer;
  final Client client;

  AIModelClient({Key key, @required this.issuer, @required this.client});
  AIModelClientState createState() => AIModelClientState(issuer: this.issuer, client: this.client);
}

class AIModelClientState extends State<AIModelClient>{
  bool showModel;
  final String issuer;
  final Client client;
  TextEditingController _textEditingController = new TextEditingController();
  final int _iconLabelColor = 0xff6F74DD;
  final int _borderColor = 0xff856fdd;
  final int _borderoFocusColor = 0xff5436cf;
  final Color _iconColor = new Color(0xff6F74DD).withOpacity(0.60);

  AIModelClientState({Key key, @required this.issuer, @required this.client});

  @override
  initState(){
    super.initState();

    this.showModel = false;
  }

  AIResponse ai_signature;

  Widget _buildTrainButton(){
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
            this.ai_signature = await AIHTTPRequest.trainRequest(aiserver_link, 22, true, this.client.getUID());
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

  Widget _buildFetchButton() {
    return new Padding(padding: EdgeInsets.only(left: 10, right: 10),
      child: new Visibility(
        visible: !this.showModel,
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
              this.ai_signature = await AIHTTPRequest.modelRequest(aiserver_link, 22, this.client.getUID(), true);
              DialogTemplate.terminateLoader();

              if(this.ai_signature != null) this.showModel = true;
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

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new ListView(
      children: <Widget>[
        this._buildFetchButton(),
        new Visibility(
          visible: this.showModel,
          child: new Column(
            children: <Widget>[
              new Divider(color: new Color(0x000000).withOpacity(0.15), thickness: 1,),
              new ListTile(
                leading: new Icon(Icons.access_time, color: this._iconColor,),
                title: new Text("Last Date Trained"),
                subtitle: (this.ai_signature == null)? new Text("") : new Text(this.ai_signature.getModelLastDate()),
              ),
            ],
          ),
        ),
        new Divider(color: new Color(0x000000).withOpacity(0.15), thickness: 1,),
        /* FormTemplate.buildMultiTextInput(
          this._textEditingController, "Reason", Icons.report,
          this._iconLabelColor, this._borderColor, this._borderoFocusColor,
        ),*/
        this._buildTrainButton(),
        //new Text((isClient)? "Client!" : "Employee!")
      ],
    );
  }
}