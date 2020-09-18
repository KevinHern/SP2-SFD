// Basic
import 'package:flutter/material.dart';
import 'dart:io';

// Models
import 'package:signature_forgery_detection/models/employee.dart';

// Templates
import 'package:signature_forgery_detection/templates/container_template.dart';
import 'package:signature_forgery_detection/templates/image_handler.dart';

class EmployeeVerifyScreen extends StatelessWidget{
  final Employee employee;
  final String issuer;
  EmployeeVerifyScreen({Key key, @required this.employee, @required this.issuer});

  @override
  Widget build(BuildContext context) {
    return EmployeeVerify(employee: this.employee, issuer: this.issuer,);
  }
}

class EmployeeVerify extends StatefulWidget{
  final Employee employee;
  final String issuer;
  EmployeeVerify({Key key, @required this.employee, @required this.issuer});

  EmployeeVerifyState createState() => EmployeeVerifyState(employee: this.employee, issuer: this.issuer);
}

class EmployeeVerifyState extends State<EmployeeVerify>{
  final Employee employee;
  final String issuer;
  EmployeeVerifyState({Key key, @required this.employee, @required this.issuer});
  bool _siameseNetwork = false;
  bool _convolutionalClassification = false;
  bool _signer_signatureClassification = false;
  final _formkey = GlobalKey<FormState>();

  final int _iconLabelColor = 0xff6F74DD;
  final int _borderColor = 0xff856fdd;
  final int _borderoFocusColor = 0xff5436cf;

  File _signature;
  var icons = [Icons.scanner, Icons.all_out, Icons.assignment];

  Widget powerSwitch(String text, int boolOption){
    return new Padding(
      padding: EdgeInsets.only(left: 8.0, bottom: 5.0, top: 5.0, right: 8.0),
      child: new ListTile(
        leading: new Icon(icons[boolOption], color: Color(this._iconLabelColor).withOpacity(0.60),),
        title: new Text(text, style: new TextStyle(
          color: new Color(this._iconLabelColor),
        ),
        ),
        trailing: Switch(
          value: (boolOption == 0)? this._siameseNetwork : (boolOption == 1)? this._convolutionalClassification : this._signer_signatureClassification,
          onChanged: (value){
            if(boolOption == 0) this._siameseNetwork = value;
            else if(boolOption == 1) this._convolutionalClassification = value;
            else this._signer_signatureClassification = value;
            setState(() {

            });
          },
          activeTrackColor: new Color(this._borderoFocusColor),
          activeColor: new Color(this._borderColor),
        ),
      ),
    );
  }

  Widget _buildSignatureSelection(){
    return new Padding(padding: EdgeInsets.only(left: 5, right: 5),
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            RaisedButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              //padding: new EdgeInsets.only(left: 20, right: 20),
              onPressed: () async {
                this._signature = await ImageHandler.getImage(0);
                setState(() {});
              },
              color: new Color(0xFF002FD3),
              textColor: Colors.white,
              child: Text("Take\nPicture",
                style: TextStyle(fontSize: 18), textAlign: TextAlign.center,),
            ),
            RaisedButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              //padding: new EdgeInsets.only(left: 20, right: 20),
              onPressed: () async {
                this._signature = await ImageHandler.getImage(1);
                setState(() {});
              },
              color: new Color(0xFF002FD3),
              textColor: Colors.white,
              child: Text("From\nGallery",
                  style: TextStyle(fontSize: 18), textAlign: TextAlign.center),
            ),
          ],
        )
    );
  }

  Widget _buildVerifyButton(){
    return new Padding(padding: EdgeInsets.only(left: 30, right: 30, bottom: 20),
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        //padding: new EdgeInsets.only(left: 20, right: 20),
        onPressed: () {
          // Send image
        },
        color: new Color(0xFF002FD3),
        textColor: Colors.white,
        child: Text("Verify",
            style: TextStyle(fontSize: 18)),
      ),
    );
  }

  Widget _buildAiForm(){
    return new Form(
      child: new ListView(
        //physics: const NeverScrollableScrollPhysics(),
        children: <Widget>[
          ContainerTemplate.buildContainer(
              new Column(
                children: <Widget>[
                  ContainerTemplate.buildContainer(new Padding(padding: EdgeInsets.only(left: 10, top: 5, bottom: 5), child: this.powerSwitch("Siamese Network", 0),), [15, 15, 15, 15], 10, 5, 5, 0.15, 10),
                  ContainerTemplate.buildContainer(new Padding(padding: EdgeInsets.only(left: 10, top: 5, bottom: 5), child: this.powerSwitch("Convolution Classification", 1),), [15, 15, 15, 15], 10, 5, 5, 0.15, 10),
                  ContainerTemplate.buildContainer(new Padding(padding: EdgeInsets.only(left: 10, top: 5, bottom: 5), child: this.powerSwitch("Signer Signature Classification", 2),), [15, 15, 15, 15], 10, 5, 5, 0.15, 10),
                  //ContainerTemplate.buildContainer(new Padding(padding: EdgeInsets.only(left: 10, top: 5, bottom: 5), child: FormTemplate.buildSingleTextInput(this._scheduleInit, "Schedule", Icons.schedule, this._iconLabelColor, this._borderColor, this._borderoFocusColor, true, false),), [15, 15, 15, 15], 10, 5, 5, 0.15, 10),
                  this._buildSignatureSelection(),
                  new Container(
                    padding: new EdgeInsets.all(30),
                    child: (_signature == null)? null : Image.file(this._signature),
                  ),
                  this._buildVerifyButton()
                ],
              ),
              [20, 20, 20, 40], 15,
              10, 10, 0.15, 30
          ),
        ],
      ),
      key: this._formkey,
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
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
        title: Text('Verify Signature', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700)),
      ),
      body: this._buildAiForm(),
    );
  }
}

