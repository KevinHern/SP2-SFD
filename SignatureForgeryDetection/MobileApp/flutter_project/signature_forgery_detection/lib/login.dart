// Basic Imports
import 'package:flutter/material.dart';

// Models
import 'package:signature_forgery_detection/models/employee.dart';

// Routes
import 'main_screen.dart';

// Backend
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {

  final TextEditingController _emailController = new TextEditingController();
  final TextEditingController _passwordController = new TextEditingController();
  bool _hidePassword = true;

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

  Widget _buildLoginButton(){
    return new Padding(padding: EdgeInsets.only(left: 30, right: 30, top: 20, bottom: 0),
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        //padding: new EdgeInsets.only(left: 20, right: 20),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => Screen()));
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