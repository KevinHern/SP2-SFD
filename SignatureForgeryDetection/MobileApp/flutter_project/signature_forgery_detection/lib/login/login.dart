// Basic Imports
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

// Models
import 'package:signature_forgery_detection/models/employee.dart';

// Routes
import '../main_screen.dart';

// Backend
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:signature_forgery_detection/templates/dialog_template.dart';
import 'package:firebase_storage/firebase_storage.dart';

class LoginScreen extends StatefulWidget {
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {

  final TextEditingController _emailController = new TextEditingController();
  final TextEditingController _passwordController = new TextEditingController();
  bool _hidePassword = true;
  final _formkey = GlobalKey<FormState>();
  final Color primaryColor = new Color(0xFF3949AB);
  bool isInLogin = true;

  Widget _buildEmailInput(){
    return new Container(
      decoration: new BoxDecoration(
          borderRadius: BorderRadius.circular(32.0),
          color: new Color(0xFFFFFFFF).withOpacity(0.75)
      ),
      child: new TextFormField(
        keyboardType: TextInputType.emailAddress,
        autofocus: false,
        decoration: InputDecoration(
          prefixIcon: new Icon(Icons.email),
          hintText: 'Email',
          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
        ),
        controller: this._emailController,
      ),
    );
  }

  Widget _buildPasswordInput(){
    return new Container(
      //color: Colors.white,
      decoration: new BoxDecoration(
        borderRadius: BorderRadius.circular(32.0),
        color: new Color(0xFFFFFFFF).withOpacity(0.75)
      ),
      child: new TextFormField(
        keyboardType: TextInputType.emailAddress,
        autofocus: false,
        decoration: InputDecoration(
          fillColor: Colors.white,
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
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(32.0),

          ),
        ),
        controller: this._passwordController,
        obscureText: this._hidePassword,
      ),
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
    if (employee != null){
      try{
        String url = await FirebaseStorage.instance.ref().child("employees/" + employee.getUID() + "/profile.jpg").getDownloadURL();
        employee.setProfilePicURL(url);
      }
      catch(error){
        employee.setProfilePicURL('https://www.woolha.com/media/2020/03/eevee.png');
      }
    }
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

        if(fuser.emailVerified) DialogTemplate.terminateLoader();
        else {
          DialogTemplate.terminateLoader();
          DialogTemplate.showMessage(context, "Email has not been verified");
          fuser = null;
        }
      }
      else {
        DialogTemplate.terminateLoader();
        DialogTemplate.showMessage(context, "Please, write a valid Email address.");
        fuser = null;
      }

    } catch (error) {
      DialogTemplate.terminateLoader();
      fuser = null;
      print(error.toString());
      DialogTemplate.showMessage(context, "The user does not exist or the password is incorrect");
    }

    return fuser;
  }

  Widget _buildLoginButton(){
    return new Padding(padding: EdgeInsets.only(left: 30, right: 30),
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
                bool isActive = await FirebaseFirestore.instance.runTransaction<bool>((transaction) async {
                  final CollectionReference misc = FirebaseFirestore.instance.collection('miscellaneous');
                  final doc = misc.doc("active");
                  DocumentSnapshot snapshot = await transaction.get(doc);
                  return snapshot.get("isActive");

                });
                DialogTemplate.terminateLoader();
                if(isActive || employee.getPowers()) Navigator.push(context, MaterialPageRoute(builder: (context) => Screen(employee: employee, isActive: isActive,)));
                else {
                  DialogTemplate.showMessage(context, "Services are unavailable");
                  employee = null;
                }
                this._emailController.text = "";
                this._passwordController.text = "";
              }
              catch(error) {
                DialogTemplate.terminateLoader();
                print(error.toString());
                DialogTemplate.showMessage(context, "An error ocurred while retreiving the data.");
              }
            }
            else {
              print("Algo ocurrió");
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

  Widget _buildChangeButton(){
    return new Padding(padding: EdgeInsets.only(left: 30, right: 30),
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        //padding: new EdgeInsets.only(left: 20, right: 20),
        onPressed: () {
          this.isInLogin = !this.isInLogin;
          this._emailController.text = "";
          this._passwordController.text = "";
          setState(() {});
        },
        color: new Color(0xFFF00000),
        textColor: Colors.white,
        child: Text(this.isInLogin ? "Forgot Password?" : "Login Now!",
            style: TextStyle(fontSize: 18)),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      alignment: Alignment.center,
      height: 100,
      width: 150,
      child: Column(
        children: <Widget>[
          Text(
            "SP2",
            style: TextStyle(
                fontSize: 50.0,
                fontWeight: FontWeight.bold,
                color: this.primaryColor),
          ),
          Text(
            "Signature Forgery Detection",
            style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: this.primaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm(){
    return new Column(
      children: <Widget>[
        SizedBox(height: 8.0),
        this._buildPasswordInput(),
        SizedBox(height: 24.0),
        this._buildLoginButton(),
      ],
    );
  }

  Widget _buildRecoverForm(){
    return new Column(
      children: <Widget>[
        SizedBox(height: 24.0),
        new Padding(padding: EdgeInsets.only(left: 30, right: 30),
          child: RaisedButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            //padding: new EdgeInsets.only(left: 20, right: 20),
            onPressed: () async {
              if(this._formkey.currentState.validate()) {
                DialogTemplate.initLoader(context, "Sending...");
                await Firebase.initializeApp();
                try{
                  await FirebaseAuth.instance.sendPasswordResetEmail(email: this._emailController.text);
                  DialogTemplate.terminateLoader();
                  DialogTemplate.showMessage(context, "An email has been sent. Follow the instructions to recover your password.");
                }
                catch(error){
                  DialogTemplate.terminateLoader();
                  DialogTemplate.showMessage(context, "Enter a valid email or user does not exist.");

                }
              }
              else {
                DialogTemplate.terminateLoader();
                DialogTemplate.showMessage(context, "Enter a valid email address.");
              }
            },
            color: new Color(0xFF0D39D6),
            textColor: Colors.white,
            child: Text("Recover my Password",
                style: TextStyle(fontSize: 18)),
          ),
        ),
      ],
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
        child: new Container(
          decoration: new BoxDecoration(
            gradient: new LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [Colors.white, new Color(0xff7ddeff)]
            ),
          ),
          child: new Center(
            child: new Form(
              key: this._formkey,
              child: ListView(
                shrinkWrap: true,
                padding: EdgeInsets.only(left: 24.0, right: 24.0),
                children: <Widget>[
                  this._buildHeader(),
                  SizedBox(height: 48.0),
                  this._buildEmailInput(),
                  this.isInLogin? this._buildLoginForm() : this._buildRecoverForm(),
                  new Padding(padding: new EdgeInsets.only(top: 5, bottom: 5, left: 20, right: 20), child: new Divider(thickness: 2, color: Colors.blueAccent,),),
                  this._buildChangeButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}