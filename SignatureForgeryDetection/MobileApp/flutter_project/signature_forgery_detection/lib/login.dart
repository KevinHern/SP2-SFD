// Basic Imports
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

// Models
import 'package:signature_forgery_detection/models/employee.dart';

// Routes
import 'main_screen.dart';

// Backend
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:signature_forgery_detection/templates/dialog_template.dart';

class LoginScreen extends StatefulWidget {
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {

  final TextEditingController _emailController = new TextEditingController();
  final TextEditingController _passwordController = new TextEditingController();
  bool _hidePassword = true;
  final _formkey = GlobalKey<FormState>();

  Widget _buildEmailInput(){
    return new TextFormField(
      keyboardType: TextInputType.emailAddress,
      autofocus: false,
      decoration: InputDecoration(
        prefixIcon: new Icon(Icons.email),
        hintText: 'Email',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
      controller: this._emailController,
    );
  }

  Widget _buildPasswordInput(){
    return new TextFormField(
      keyboardType: TextInputType.emailAddress,
      autofocus: false,
      decoration: InputDecoration(
        prefixIcon: new IconButton(
          icon: new Icon(this._hidePassword? Icons.visibility_off : Icons.visibility ),
          onPressed: () {
            setState(() {
              this._hidePassword = !this._hidePassword;
            });
          },
        ),
        hintText: 'Password',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
      controller: this._passwordController,
      obscureText: this._hidePassword,
    );
  }

  Future buildUser(User user) async {
    Employee employee;
    final CollectionReference employees = FirebaseFirestore.instance.collection('employees');
    await employees.doc(user.uid).get().then((
        snapshot) {
      if(snapshot.exists) {
        employee = new Employee(
            snapshot.get("name"),
            snapshot.get("lname"),
            snapshot.get("email"),
            snapshot.get("phone"),
            snapshot.get("birthday"),
            snapshot.get("department"),
            snapshot.get("position"),
            snapshot.get("init"),
            snapshot.get("end"));
        employee.setPowers(snapshot.get("powers"));
        employee.setUser(user);
        employee.setUID(user.uid);
      }
    });
    return employee;
  }

  Future signIn() async {
    User fuser;
    try {
      DialogTemplate.initLoader(context, "Loading...");
      if(RegExp(".+@[a-zA-Z]+.[a-zA-Z]+").hasMatch(_emailController.text)) {
        //print("Email: " + _emailController.text + "\tPassword: " + _passwordController.text);
        await Firebase.initializeApp();
        fuser = (await FirebaseAuth.instance.signInWithEmailAndPassword(email: _emailController.text, password: _passwordController.text)).user;

        DialogTemplate.terminateLoader();
      }
      else {
        DialogTemplate.terminateLoader();
        DialogTemplate.showMessage(context, "Escriba una dirección de correo válido.");
        fuser = null;
      }

    } catch (error) {
      DialogTemplate.terminateLoader();
      fuser = null;
      print(error.toString());
      DialogTemplate.showMessage(context, "El usuario no existe o la contraseña es incorrecta.");
    }

    return fuser;
  }

  Widget _buildLoginButton(){
    return new Padding(padding: EdgeInsets.only(left: 30, right: 30, top: 20, bottom: 0),
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        //padding: new EdgeInsets.only(left: 20, right: 20),
        onPressed: () async {
          if(this._formkey.currentState.validate()) {
            User user = await this.signIn();
            if (user != null) {
              try {
                Employee employee = await this.buildUser(user);
                DialogTemplate.terminateLoader();
                Navigator.push(context, MaterialPageRoute(builder: (context) => Screen(employee: employee,)));
              }
              catch(error) {
                DialogTemplate.terminateLoader();
                print(error.toString());
                DialogTemplate.showMessage(context, "An error ocurred while retreiving the data.");
              }
            }
            else {
              DialogTemplate.terminateLoader();
            }
          }
          else {
            DialogTemplate.showMessage(context, "Enter a valid email address");
          }
        },
        color: new Color(0xFF0D39D6),
        textColor: Colors.white,
        child: Text("Login",
            style: TextStyle(fontSize: 18)),
      ),
    );
  }

  Widget _buildLoginForm(){
    return new Center(
      child: new Form(
        key: this._formkey,
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.only(left: 24.0, right: 24.0),
          children: <Widget>[
            SizedBox(height: 48.0),
            this._buildEmailInput(),
            SizedBox(height: 8.0),
            this._buildPasswordInput(),
            SizedBox(height: 24.0),
            this._buildLoginButton(),
            //forgotLabel
          ],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) currentFocus.unfocus();
        },
        child: this._buildLoginForm(),
      ),
    );
  }
}