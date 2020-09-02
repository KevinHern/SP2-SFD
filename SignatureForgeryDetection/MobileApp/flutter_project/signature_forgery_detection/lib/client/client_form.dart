// Basic Import
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

// Templates
import 'package:signature_forgery_detection/templates/container_template.dart';
import 'package:signature_forgery_detection/templates/dialog_template.dart';
import 'package:signature_forgery_detection/templates/form_template.dart';

// Backend
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:signature_forgery_detection/backend/log_query.dart';

class RegisterClient extends StatefulWidget {
  final String issuer;
  RegisterClient({Key key, @required this.issuer});
  RegisterClientState createState() => RegisterClientState(issuer: this.issuer);
}

class RegisterClientState extends State<RegisterClient> {
  final _formkey = GlobalKey<FormState>();
  final TextEditingController _nameController = new TextEditingController();
  final TextEditingController _lastnameController = new TextEditingController();
  final TextEditingController _emailController = new TextEditingController();
  final TextEditingController _phone = new TextEditingController();
  final TextEditingController _birthday = new TextEditingController(text: "1/1/2000");
  final registrationDate = "${DateTime.parse(new DateTime.now().toString()).day}/${DateTime.parse(new DateTime.now().toString()).month}/${DateTime.parse(new DateTime.now().toString()).year}";

  final int _iconLabelColor = 0xff6F74DD;
  final int _borderColor = 0xff856fdd;
  final int _borderoFocusColor = 0xff5436cf;

  final String issuer;
  RegisterClientState({Key key, @required this.issuer});

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
            final clients = FirebaseFirestore.instance.collection("clients");
            // Return and set the updated "likes" count from the transaction
            int newClientId = await FirebaseFirestore.instance
                .runTransaction<int>((transaction) async {
              final doc = FirebaseFirestore.instance.collection("sequentials").doc("clientseq");
              DocumentSnapshot snapshot = await transaction.get(doc);

              if (!snapshot.exists) {
                return -1;
              }
              else {
                transaction.update(doc, {
                  'nextID': snapshot.get("nextID") + 1
                });
                return snapshot.get("nextID");
              }
            });

            if(newClientId != -1) {
              await clients.doc(newClientId.toString()).set({
                'email': _emailController.text,
                'name': _nameController.text,
                'lname': _lastnameController.text,
                'phone': _phone.text,
                'birthday': _birthday.text,
                'registration': registrationDate,
              });

              int logCode = await (new QueryLog()).pushLog(
                  0, " registered new client: ",
                  this.issuer,
                  this._nameController.text + " " + this._lastnameController.text,
                  newClientId.toString(),
                  0, "New client wishes to use our services.", 0
              );
              DialogTemplate.terminateLoader();
              if(logCode == 1) DialogTemplate.showMessage(context, "Insertion successful.");
              else DialogTemplate.showMessage(context, "Insertion successful but failed to register a log.");

            }
            else {
              DialogTemplate.terminateLoader();
              DialogTemplate.showMessage(context, "An error has occurred while inserting. Try again.");
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