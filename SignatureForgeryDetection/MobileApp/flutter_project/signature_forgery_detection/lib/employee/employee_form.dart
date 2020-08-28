// Basic Import
import 'package:flutter/material.dart';

// Templates
import 'package:signature_forgery_detection/templates/container_template.dart';
import 'package:signature_forgery_detection/templates/form_template.dart';

class RegisterEmployee extends StatefulWidget {
  RegisterEmployeeState createState() => RegisterEmployeeState();
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

  final int _iconLabelColor = 0xff6F74DD;
  final int _borderColor = 0xff856fdd;
  final int _borderoFocusColor = 0xff5436cf;


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
        onPressed: () {},
        color: new Color(0xFF002FD3),
        textColor: Colors.white,
        child: Text("Done",
            style: TextStyle(fontSize: 18)),
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
                  ContainerTemplate.buildContainer(new Padding(padding: EdgeInsets.only(left: 10, top: 5, bottom: 5), child: FormTemplate.buildDateInput(this._birthday, "Birthday", Icons.cake, this._iconLabelColor, this._borderColor, this._borderoFocusColor, "bd"),), [15, 15, 15, 15], 10, 5, 5, 0.15, 10),
                  ContainerTemplate.buildContainer(new Padding(padding: EdgeInsets.only(left: 10, top: 5, bottom: 5), child: FormTemplate.buildSingleTextInput(this._department, "Department", Icons.share, this._iconLabelColor, this._borderColor, this._borderoFocusColor, true, false),), [15, 15, 15, 15], 10, 5, 5, 0.15, 10),
                  ContainerTemplate.buildContainer(new Padding(padding: EdgeInsets.only(left: 10, top: 5, bottom: 5), child: FormTemplate.buildSingleTextInput(this._position, "Position", Icons.bookmark, this._iconLabelColor, this._borderColor, this._borderoFocusColor, true, false),), [15, 15, 15, 15], 10, 5, 5, 0.15, 10),
                  ContainerTemplate.buildContainer(new Padding(padding: EdgeInsets.only(left: 10, top: 5, bottom: 5), child: FormTemplate.buildSingleTextInput(this._scheduleInit, "Schedule", Icons.schedule, this._iconLabelColor, this._borderColor, this._borderoFocusColor, true, false),), [15, 15, 15, 15], 10, 5, 5, 0.15, 10),
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