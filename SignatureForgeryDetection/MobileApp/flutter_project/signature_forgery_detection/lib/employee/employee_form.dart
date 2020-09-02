// Basic Import
import 'package:flutter/material.dart';

// Templates
import 'package:signature_forgery_detection/templates/container_template.dart';
import 'package:signature_forgery_detection/templates/form_template.dart';
import 'package:signature_forgery_detection/templates/dialog_template.dart';

// Backend
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:signature_forgery_detection/backend/log_query.dart';

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

  final int _iconLabelColor = 0xff6F74DD;
  final int _borderColor = 0xff856fdd;
  final int _borderoFocusColor = 0xff5436cf;

  final String issuer;
  RegisterEmployeeState({Key key, @required this.issuer});


  Widget __buildRegisterSignatureButton(){
    return new Padding(padding: EdgeInsets.only(left: 30, right: 30),
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        //padding: new EdgeInsets.only(left: 20, right: 20),
        onPressed: () {},
        color: new Color(0xFF002FD3),
        textColor: Colors.white,
        child: Text("Register Signature",
            style: TextStyle(fontSize: 18)),
      ),
    );
  }

  Widget __buildRegisterButton(){
    return new Padding(padding: EdgeInsets.only(left: 30, right: 30, bottom: 20),
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

              int logCode = await (new QueryLog()).pushLog(
                  0, " registered new employee: ",
                  this.issuer,
                  this._nameController.text + " " + this._lastnameController.text,
                  newEmployee.user.uid,
                  0, "New employee has been hired", 0
              );
              DialogTemplate.terminateLoader();
              if(logCode == 1) DialogTemplate.showMessage(context, "Insertion successful.");
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
                  this.__buildRegisterSignatureButton(),
                  new Container(height: 400),
                  this.__buildRegisterButton()
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