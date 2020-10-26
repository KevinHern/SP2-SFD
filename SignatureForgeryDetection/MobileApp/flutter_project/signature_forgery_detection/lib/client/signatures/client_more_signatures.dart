// Basic Imports
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';

// Models
import 'package:signature_forgery_detection/models/client.dart';

// Templates
import 'package:signature_forgery_detection/templates/container_template.dart';
import 'package:signature_forgery_detection/templates/dialog_template.dart';
import 'package:signature_forgery_detection/templates/image_handler.dart';
import 'package:signature_forgery_detection/templates/navbar_template.dart';


// Backend
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:signature_forgery_detection/backend/aihttp.dart';
import 'package:signature_forgery_detection/backend/log_query.dart';

class ClientMoreSignaturesScreen extends StatelessWidget{
  final Client client;
  final String issuer;

  ClientMoreSignaturesScreen({Key key, @required this.client, @required this.issuer});

  @override
  Widget build(BuildContext context) {
    return NavBarTemplate.buildAppBar(context,
      'Client Signatures',
      new ClientMoreSignatures(client: this.client, issuer: this.issuer),
    );
  }
}

class ClientMoreSignatures extends StatefulWidget {
  final Client client;
  final String issuer;

  ClientMoreSignatures({Key key, @required this.client, @required this.issuer});

  ClientMoreSignaturesState createState() => ClientMoreSignaturesState(client: this.client, issuer: this.issuer);
}

class ClientMoreSignaturesState extends State<ClientMoreSignatures> {
  final Client client;
  final String issuer;
  final Color _iconColor = new Color(0xff6F74DD).withOpacity(0.60);

  ClientMoreSignaturesState(
      {Key key, @required this.client, @required this.issuer});

  List<File> signatures = [];
  var shows = [];

  Widget _buildRegisterSignatureButton() {
    final double font_size = 15;
    return new Padding(padding: EdgeInsets.only(left: 30, right: 30),
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            RaisedButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              //padding: new EdgeInsets.only(left: 20, right: 20),
              onPressed: () async {
                if (this.signatures.length > 10)
                  DialogTemplate.showMessage(
                      context, "No more than 10 signatures allowed");
                else {
                  File signature = await ImageHandler.getImage(0);
                  if (signature != null) this.signatures.add(signature);
                  setState(() {});
                }
              },
              color: new Color(0xFF002FD3),
              textColor: Colors.white,
              child: Text("Signature\nfrom Camera",
                  style: TextStyle(fontSize: font_size),
                  textAlign: TextAlign.center),
            ),
            RaisedButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              //padding: new EdgeInsets.only(left: 20, right: 20),
              onPressed: () async {
                if (this.signatures.length > 10)
                  DialogTemplate.showMessage(
                      context, "No more than 10 signatures allowed");
                else {
                  FilePickerResult result = await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ['jpg', 'png', 'jpeg']
                  );

                  if(result != null) {
                    this.signatures.add(File(result.files.single.path));
                  }
                }
                setState(() {});
              },
              color: new Color(0xFF002FD3),
              textColor: Colors.white,
              child: Text("Signature\nfrom Gallery",
                  style: TextStyle(fontSize: font_size),
                  textAlign: TextAlign.center),
            ),
          ],
        )
    );
  }

  Widget _buildSignatureList() {
    // Generating thumbnail and cross button
    List<Widget> signatureWidgets = [];
    for (int i = 0; i < this.signatures.length; i++) {
      Widget thumbnail = new Stack(
        children: <Widget>[
          new Container(
            padding: new EdgeInsets.all(20),
            child: Image.file(this.signatures[i]),
          ),
          new Positioned(
            top: 0,
            right: 0,
            child: new Padding(
              padding: EdgeInsets.only(right: 8),
              child: new FloatingActionButton(
                elevation: 10,
                hoverElevation: 10,
                backgroundColor: Colors.red,
                child: new IconButton(
                  icon: new Icon(
                    Icons.delete_forever, color: new Color(0xFFFFFFFF),),
                  onPressed: () {
                    this.signatures.removeAt(i);
                    setState(() {});
                  },
                ),
                mini: true,
              ),
            ),
          ),
        ],
      );
      signatureWidgets.add(thumbnail);
    }

    // ----- Return the blocks of thumbnails
    return new Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: signatureWidgets,
    );
  }

  Widget _buildSendButton() {
    return new Padding(
      padding: EdgeInsets.only(left: 30, right: 30, bottom: 20),
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        //padding: new EdgeInsets.only(left: 20, right: 20),
        onPressed: () async {
          // Getting IMG server link
          String aiserver_link = "";
          DialogTemplate.initLoader(context, "Please, wait for a moment...");
          CollectionReference coll = FirebaseFirestore.instance.collection('miscellaneous');
          await coll.doc("imgserver").get().then((
              snapshot) {
            if(snapshot.exists) {
              aiserver_link = snapshot.get("server");
            }
          });

          coll = FirebaseFirestore.instance.collection('clients');

          int signindex = 0;
          await coll.doc(this.client.getUID()).get().then((snapshot){
            if(snapshot.exists) {
              signindex = snapshot.get("sigindex");
            }
          });

          // Uploading each signature
          for(int i = 0; i < this.signatures.length; i++){
            String filename = "signature" + (signindex).toString() + "." + this.signatures[i].path.split('/').last.split('.').last;

            while (true){
              bool success = await AIHTTPRequest.storeRequest(aiserver_link, this.client.getUID(), filename, this.signatures[i], true);
              if (success) break;
            }
            signindex += 1;
          }

          await coll.doc(this.client.getUID()).update({
            'sigindex': signindex
          });

          String clientName = this.client.getParameterByString("name") + " " + this.client.getParameterByString("lname");
          String description = "registered (CLIENT) " + clientName + ((this.signatures.length == 1)?  "'s new signature." : "'s multiple signatures.");

          int logCode = await (new QueryLog()).pushLog(
              0, description,
              this.issuer,
              '' ,
              this.client.getUID(),
              0, 'new signature registration.', 0
          );

          DialogTemplate.terminateLoader();
          DialogTemplate.showMessage(context, "Upload successful");

        },
        color: new Color(0xFF002FD3),
        textColor: Colors.white,
        child: Text("Done",
            style: TextStyle(fontSize: 18)),
      ),
    );
  }

  Widget _buildClearButton(){
    return new Padding(
      padding: EdgeInsets.only(left: 30, right: 30, bottom: 5),
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        //padding: new EdgeInsets.only(left: 20, right: 20),
        onPressed: () {
          this.signatures = [];
          setState(() {
          });
        },
        color: new Color(0xFF002FD3),
        textColor: Colors.white,
        child: Text("Clear Signatures",
            style: TextStyle(fontSize: 18)),
      ),
    );
  }

  Widget _buildAddSigns() {
    return new ListView(
      padding: new EdgeInsets.only(top: 10, bottom: 40),
      children: <Widget>[
        this._buildRegisterSignatureButton(),
        this._buildSignatureList(),
        this._buildClearButton(),
        this._buildSendButton()
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ContainerTemplate.buildContainer(
      this._buildAddSigns(),
      [30, 10, 30, 20],
      20,
      15,
      15,
      0.15,
      30,
    );
  }
}