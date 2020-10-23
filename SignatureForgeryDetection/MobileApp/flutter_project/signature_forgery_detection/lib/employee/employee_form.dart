// Basic Import
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'dart:io';

// Templates
import 'package:signature_forgery_detection/templates/container_template.dart';
import 'package:signature_forgery_detection/templates/form_template.dart';
import 'package:signature_forgery_detection/templates/dialog_template.dart';
import 'package:firebase_storage/firebase_storage.dart';

// Backend
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:signature_forgery_detection/backend/log_query.dart';
import 'package:signature_forgery_detection/templates/image_handler.dart';

class RegisterEmployee extends StatefulWidget {
  final String issuer;
  RegisterEmployee({Key key, @required this.issuer});
  RegisterEmployeeState createState() => RegisterEmployeeState(issuer: this.issuer);
}

class RegisterEmployeeState extends State<RegisterEmployee> {
  final _formkey = GlobalKey<FormState>();
  final TextEditingController _nameController = new TextEditingController();
  final TextEditingController _lastnameController = new TextEditingController();
  final TextEditingController _emailController = new TextEditingController();
  final TextEditingController _phone = new TextEditingController();
  final TextEditingController _birthday = new TextEditingController();
  final TextEditingController _department = new TextEditingController();
  final TextEditingController _position = new TextEditingController();
  final TextEditingController _scheduleInit = new TextEditingController();
  final TextEditingController _scheduleEnd = new TextEditingController();
  bool _hasPowers = false;

  final int _iconLabelColor = 0xFF002FD3;
  final int _borderColor = 0xff856fdd;
  final int _borderoFocusColor = 0xff5436cf;

  final String issuer;
  RegisterEmployeeState({Key key, @required this.issuer});

  List<File> signatures = [];

  Widget __buildRegisterSignatureButton(){
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

  Widget __buildRegisterButton(){
    return new Padding(padding: EdgeInsets.only(left: 30, right: 30),
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        //padding: new EdgeInsets.only(left: 20, right: 20),
        onPressed: () async {
          DialogTemplate.initLoader(context, "Espera un momento...");
          User user = FirebaseAuth.instance.currentUser;
          if(user != null && _formkey.currentState.validate()) {
            try{
              UserCredential newEmployee = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: _emailController.text, password: _emailController.text);
              newEmployee.user.sendEmailVerification();
              final employees = FirebaseFirestore.instance.collection("employees");
              var filterArray = [];
              for (int i = 1; i < _nameController.text.length; i++) {
                filterArray.add(_nameController.text.substring(0, i));
              }
              await employees.doc(newEmployee.user.uid).set({
                'email': _emailController.text,
                'name': _nameController.text,
                'lname': _lastnameController.text,
                'phone': _phone.text,
                'birthday': _birthday.text,
                'department': _department.text,
                'position': _position.text,
                'init': _scheduleInit.text,
                'end': _scheduleEnd.text,
                'powers': this._hasPowers,
              });

              /*
              StorageReference storageReference = FirebaseStorage.instance
                  .ref();
              //.child('chats/${Path.basename(_image.path)}}');
              for(int i = 0; i < this.signatures.length; i++){
                String filename = "gsignature" + (i+1).toString() + "." + this.signatures[i].path.split('/').last.split('.').last;
                StorageUploadTask uploadTask = storageReference.child("employees/" + newEmployee.user.uid + "/" + filename).putFile(this.signatures[i]);
                await uploadTask.onComplete;
              }
              */

              int logCode = await (new QueryLog()).pushLog(
                  0, " registered new employee: ",
                  this.issuer,
                  this._nameController.text + " " + this._lastnameController.text,
                  newEmployee.user.uid,
                  0, "New employee has been hired", 0
              );
              DialogTemplate.terminateLoader();
              if(logCode == 1) DialogTemplate.showMessage(context, "New employee created successfully. Sent an email verification.");
              else DialogTemplate.showMessage(context, "Insertion successful but failed to register a log.");
            }
            catch(error){
              DialogTemplate.terminateLoader();
              DialogTemplate.showMessage(context, "Insertion error. User already exists");
            }
          }
          else if(user == null){
            DialogTemplate.terminateLoader();
            DialogTemplate.showMessage(context, "A fatal error has occurred, restart the application.");
          }
          else {
            DialogTemplate.terminateLoader();
            DialogTemplate.showMessage(context, "Input the data correctly");
          }
        },
        color: new Color(0xFF002FD3),
        textColor: Colors.white,
        child: Text("Done",
            style: TextStyle(fontSize: 18)),
      ),
    );
  }
  Widget _buildClearButton(){
    return ContainerTemplate.buildBasicButton(
      () {
        this._emailController.text = "";
        this._nameController.text = "";
        this._lastnameController.text = "";
        this._phone.text = "";
        this._birthday.text = "";
        this._department.text = "";
        this._position.text = "";
        this._scheduleInit.text = "";
        this._scheduleEnd.text = "";
        this._hasPowers = false;
        this.signatures = [];
        setState(() {});
      },
      new Text("Clear Form", style: new TextStyle(fontSize: 18),),
    );
  }

  Widget powerSwitch(){
    return new Padding(
      padding: EdgeInsets.only(left: 8.0, bottom: 5.0, top: 5.0, right: 8.0),
      child: new ListTile(
        leading: new Icon(Icons.fingerprint, color: Color(this._iconLabelColor).withOpacity(0.60),),
        title: new Text("Priviledged Employee", style: new TextStyle(
          color: new Color(this._iconLabelColor),
        ),
        ),
        trailing: Switch(
          value: _hasPowers,
          onChanged: (value){
            this._hasPowers = value;
            setState(() {

            });
          },
          activeTrackColor: new Color(this._borderoFocusColor),
          activeColor: new Color(this._borderColor),
        ),
      ),
    );
  }

  Widget _buildForm(){
    return new Form(
      child: new ListView(
        //physics: const NeverScrollableScrollPhysics(),
        children: <Widget>[
          ContainerTemplate.buildContainer(
              new Column(
                children: <Widget>[
                  ContainerTemplate.buildContainer(new Padding(padding: EdgeInsets.only(left: 10, top: 5, bottom: 5), child: FormTemplate.buildEmailInput(this._emailController, this._iconLabelColor, this._borderColor, this._borderoFocusColor),), [15, 15, 15, 15], 10, 5, 5, 0.15, 10),
                  ContainerTemplate.buildContainer(new Padding(padding: EdgeInsets.only(left: 10, top: 5, bottom: 5), child: FormTemplate.buildMultiTextInput(this._nameController, "Name(s)", Icons.person, this._iconLabelColor, this._borderColor, this._borderoFocusColor),), [15, 15, 15, 15], 10, 5, 5, 0.15, 10),
                  ContainerTemplate.buildContainer(new Padding(padding: EdgeInsets.only(left: 10, top: 5, bottom: 5), child: FormTemplate.buildMultiTextInput(this._lastnameController, "Last Name(s)", Icons.person, this._iconLabelColor, this._borderColor, this._borderoFocusColor),), [15, 15, 15, 15], 10, 5, 5, 0.15, 10),
                  ContainerTemplate.buildContainer(new Padding(padding: EdgeInsets.only(left: 10, top: 5, bottom: 5), child: FormTemplate.buildNumberInput(this._phone, "Phone Number", Icons.person, this._iconLabelColor, this._borderColor, this._borderoFocusColor, true),), [15, 15, 15, 15], 10, 5, 5, 0.15, 10),
                  ContainerTemplate.buildContainer(new Padding(padding: EdgeInsets.only(left: 10, top: 5, bottom: 5), child: FormTemplate.buildDateInput(this._birthday, "Birthday", Icons.cake, this._iconLabelColor, this._borderColor, this._borderoFocusColor, "bd", context),), [15, 15, 15, 15], 10, 5, 5, 0.15, 10),
                  ContainerTemplate.buildContainer(new Padding(padding: EdgeInsets.only(left: 10, top: 5, bottom: 5), child: FormTemplate.buildSingleTextInput(this._department, "Department", Icons.share, this._iconLabelColor, this._borderColor, this._borderoFocusColor, false, true),), [15, 15, 15, 15], 10, 5, 5, 0.15, 10),
                  ContainerTemplate.buildContainer(new Padding(padding: EdgeInsets.only(left: 10, top: 5, bottom: 5), child: FormTemplate.buildSingleTextInput(this._position, "Position", Icons.bookmark, this._iconLabelColor, this._borderColor, this._borderoFocusColor, false, true),), [15, 15, 15, 15], 10, 5, 5, 0.15, 10),
                  ContainerTemplate.buildContainer(new Padding(padding: EdgeInsets.only(left: 10, top: 5, bottom: 5), child: FormTemplate.buildTimeInput(this._scheduleInit, "Schedule (Begin)", Icons.schedule, this._iconLabelColor, this._borderColor, this._borderoFocusColor, "sc1", context),), [15, 15, 15, 15], 10, 5, 5, 0.15, 10),
                  ContainerTemplate.buildContainer(new Padding(padding: EdgeInsets.only(left: 10, top: 5, bottom: 5), child: FormTemplate.buildTimeInput(this._scheduleEnd, "Schedule (End)", Icons.schedule, this._iconLabelColor, this._borderColor, this._borderoFocusColor, "sc2", context),), [15, 15, 15, 15], 10, 5, 5, 0.15, 10),
                  ContainerTemplate.buildContainer(new Padding(padding: EdgeInsets.only(left: 10, top: 5, bottom: 5), child: this.powerSwitch(),), [15, 15, 15, 15], 10, 5, 5, 0.15, 10),
                  //ContainerTemplate.buildContainer(new Padding(padding: EdgeInsets.only(left: 10, top: 5, bottom: 5), child: FormTemplate.buildSingleTextInput(this._scheduleInit, "Schedule", Icons.schedule, this._iconLabelColor, this._borderColor, this._borderoFocusColor, true, false),), [15, 15, 15, 15], 10, 5, 5, 0.15, 10),
                  //this.__buildRegisterSignatureButton(),
                  //this._buildSignatureList(),
                  this.__buildRegisterButton(),
                  this._buildClearButton(),
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
    return new GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) currentFocus.unfocus();
      },
      child: this._buildForm(),
    );
  }
}