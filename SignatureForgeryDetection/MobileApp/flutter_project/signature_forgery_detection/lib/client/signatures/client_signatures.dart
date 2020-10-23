// Basic Imports
import 'package:flutter/material.dart';
import 'dart:io';

// Models
import 'package:signature_forgery_detection/models/client.dart';
import 'package:signature_forgery_detection/templates/container_template.dart';

// Templates
import 'package:signature_forgery_detection/templates/dialog_template.dart';
import 'package:signature_forgery_detection/templates/image_handler.dart';
import 'package:signature_forgery_detection/templates/navbar_template.dart';

// Routes
import 'client_edit_signature.dart';

// Backend
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:signature_forgery_detection/backend/aihttp.dart';

class ClientSignatureScreen extends StatelessWidget{
  final Client client;
  final String issuer;
  var signames;

  ClientSignatureScreen({Key key, @required this.client, @required this.issuer, @required this.signames});

  @override
  Widget build(BuildContext context) {
    return NavBarTemplate.buildAppBar(context,
      'Client Signatures',
      new ClientSignature(client: this.client, issuer: this.issuer, signames: this.signames),
    );
  }
}

class ClientSignature extends StatefulWidget {
  final Client client;
  final String issuer;
  var signames;

  ClientSignature({Key key, @required this.client, @required this.issuer, @required this.signames});

  ClientSignatureState createState() => ClientSignatureState(client: this.client, issuer: this.issuer, signames: this.signames);
}

class ClientSignatureState extends State<ClientSignature> {
  final Client client;
  final String issuer;
  var signames;
  final Color _iconColor = new Color(0xff6F74DD).withOpacity(0.60);

  ClientSignatureState({Key key, @required this.client, @required this.issuer, @required this.signames});

  List<File> signatures = [];
  var shows = [];

  @override
  initState(){
    super.initState();
    for(int i = 0; i < signames.length; i++) {
      signatures.add(null);
      shows.add(false);
    }
  }

  Widget _buildRegisterSignatureButton(){
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
                if(this.signatures.length > 4) DialogTemplate.showMessage(context, "No more than 5 signatures allowed");
                else{
                  File signature = await ImageHandler.getImage(0);
                  if(signature != null) this.signatures.add(signature);
                  setState(() {});
                }
              },
              color: new Color(0xFF002FD3),
              textColor: Colors.white,
              child: Text("Signature\nfrom Camera",
                  style: TextStyle(fontSize: font_size), textAlign: TextAlign.center),
            ),
            RaisedButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              //padding: new EdgeInsets.only(left: 20, right: 20),
              onPressed: () async {
                if(this.signatures.length > 4) DialogTemplate.showMessage(context, "No more than 5 signatures allowed");
                else{
                  File signature = await ImageHandler.getImage(1);
                  if(signature != null) this.signatures.add(signature);
                  setState(() {});
                }
              },
              color: new Color(0xFF002FD3),
              textColor: Colors.white,
              child: Text("Signature\nfrom Gallery",
                  style: TextStyle(fontSize: font_size), textAlign: TextAlign.center),
            ),
          ],
        )
    );
  }

  Widget _buildSignatureList(){
    // Generating thumbnail and cross button
    List<Widget> signatureWidgets = [];
    for(int i = 0; i < this.signatures.length; i++) {
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
                  icon: new Icon(Icons.delete_forever, color: new Color(0xFFFFFFFF),),
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

  Widget _buildSendButton(){
    return new Padding(padding: EdgeInsets.only(left: 30, right: 30, bottom: 20),
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        //padding: new EdgeInsets.only(left: 20, right: 20),
        onPressed: () async {

        },
        color: new Color(0xFF002FD3),
        textColor: Colors.white,
        child: Text("Done",
            style: TextStyle(fontSize: 18)),
      ),
    );
  }

  Widget _buildAddSigns(){
    return new ListView(
      padding: new EdgeInsets.only(left: 30, right: 30, top: 50, bottom: 40),
      children: <Widget>[
        this._buildRegisterSignatureButton(),
        this._buildSignatureList(),
        this._buildSendButton()
      ],
    );
  }

  Widget _buildFetchButton(int index){
    return new Padding(padding: EdgeInsets.only(left: 10, right: 10),
      child: new Visibility(
        visible: !shows[index],
        child: RaisedButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          //padding: new EdgeInsets.only(left: 20, right: 20),
          onPressed: () async {
            // Execute HTTP request
            // All good
            String imgserver_link = "";
            final CollectionReference misc = FirebaseFirestore.instance.collection('miscellaneous');
            await misc.doc("imgserver").get().then((
                snapshot) {
              if(snapshot.exists) {
                imgserver_link = snapshot.get("server");
              }
            });

            if(imgserver_link.isNotEmpty){
              DialogTemplate.initLoader(context, "Please, wait for a moment...");
              this.signatures[index] = await AIHTTPRequest.imageRequest(imgserver_link, this.client.getUID(), true, this.signames[index], index);
              print((this.signatures[index] == null)? "Error in image fetching" : "All good!");
              DialogTemplate.terminateLoader();

              if(this.signatures[index] != null) this.shows[index] = true;
              else {
                DialogTemplate.showMessage(context, "An error has ocurred while fetching the image.");
              }
            }
            setState(() {});
          },
          color: new Color(0xFF002FD3),
          textColor: Colors.white,
          child: Text("Fetch Image",
              style: TextStyle(fontSize: 18)),
        ),
      ),
    );
  }

  Widget _buildSignCollapsible(int index){
    return new ExpansionTile(
      leading: new Icon(Icons.image, color: this._iconColor,),
      title: Text(
        this.signames[index],
        style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold
        ),
      ),
      children: <Widget>[
        this._buildFetchButton(index),
        new Divider(color: new Color(0x000000).withOpacity(0.15), thickness: 1,),
        new Visibility(
          visible: true,
          child: new Column(
            children: <Widget>[
              (this.signatures[index] == null)? new Container() : new Container(padding: new EdgeInsets.all(20), child: Image.file(this.signatures[index]), ),
              ContainerTemplate.buildBasicButton(
                () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => SignatureEditScreen(client: this.client, option: 0, issuer: this.issuer, signature: this.signatures[index], signatures: this.signatures,))).then((value) => {});
                },
                Text("Delete", style: TextStyle(fontSize: 18)),
              ),
              // Delete button here
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return new ListView.builder(
      //physics: const NeverScrollableScrollPhysics(),
      itemCount: this.signames.length,
      itemBuilder: (context, index) {
        return this._buildSignCollapsible(index);
      },
    );
  }
}