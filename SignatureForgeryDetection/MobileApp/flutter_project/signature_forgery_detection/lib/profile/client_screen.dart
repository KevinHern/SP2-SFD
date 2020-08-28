// Basic Imports
import 'package:flutter/material.dart';

// Templates
import 'package:signature_forgery_detection/templates/container_template.dart';

// Models
//import 'package:signature_forgery_detection/models/';

class ClientProfile extends StatefulWidget {

  ClientProfileState createState() => ClientProfileState();
}

class ClientProfileState extends State<ClientProfile> {
  final _clientInfo = [];


  Widget _buildVerifyButton(){
    return RaisedButton(
      child: new Container(
        child: new Text("Verify a Signature", style: new TextStyle(color: new Color(0xFFFFFF).withOpacity(0.90)),),
        color: new Color(0x002FD3),
        width: 180,
        height: 36,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(30)),
          border: Border.all(
              width: 1,
              color: Colors.black,
              style: BorderStyle.solid
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              spreadRadius: 5,
              blurRadius: 10,
              offset: Offset(5, 5), // changes position of shadow
            ),
          ],
        ),
      ),
      onPressed: () {},
    );
  }

  Widget _profileInfo(){
    return new ListView.builder(
      itemCount: 5,
      padding: EdgeInsets.all(5.0),
      itemBuilder: (context, index) {
        return this._clientInfo[index];
      },
    );
  }

  Widget _profile(){
    return new ListView(
      children: <Widget>[
        new Text("Names"),
        new Text("Last Names"),
        ContainerTemplate.buildContainer(
          this._profileInfo(),
          [30, 9, 30, 120],
          20,
          15,
          15,
          0.15,
          30,
        ),
        this._buildVerifyButton()
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return _profile();
  }
}