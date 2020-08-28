// Basic Imports
import 'package:flutter/material.dart';

// Models
import 'package:signature_forgery_detection/models/employee.dart';

// Templates
import 'package:signature_forgery_detection/templates/container_template.dart';
import 'package:signature_forgery_detection/templates/form_template.dart';
import 'package:signature_forgery_detection/templates/dialog_template.dart';

// Database
import 'package:signature_forgery_detection/backend/profile_query.dart';

class ProfileEditScreen extends StatelessWidget {
  final Employee employee;
  final int option;
  ProfileEditScreen({Key key, @required this.employee, @required this.option});

  @override
  Widget build(BuildContext context) {
    print("Option at ProfileEditScreen: "+ this.option.toString());
    return ProfileEdit(employee: this.employee, option: this.option,);
  }
}

class ProfileEdit extends StatefulWidget {
  final Employee employee;
  final int option;
  ProfileEdit({Key key, @required this.employee, @required this.option});

  ProfileEditState createState() => ProfileEditState(employee: this.employee, option: this.option);
}

class ProfileEditState extends State<ProfileEdit> {
  final Employee employee;
  final int option;
  final int _iconLabelColor = 0xff6F74DD;
  final int _borderColor = 0xff856fdd;
  final int _borderoFocusColor = 0xff5436cf;

  ProfileEditState({Key key, @required this.employee, @required this.option});

  final _formkey = GlobalKey<FormState>();
  TextEditingController _fieldController1;
  TextEditingController _fieldController2;
  String _title;
  var newValues = [];

  @override
  void initState() {
    super.initState();
    switch(this.option) {
      case 0:
        _fieldController1 = new TextEditingController(text: this.employee.getParameterByString("email"));
        _title = "E-mail";
        break;
      case 1:
        _fieldController1 = new TextEditingController();
        _title = "Password";
        break;
      case 2:
        _fieldController1 = new TextEditingController(text: this.employee.getParameterByString("name"));
        _fieldController2 = new TextEditingController(text: this.employee.getParameterByString("lname"));
        _title = "Name";
        break;
      case 3:
        _fieldController1 = new TextEditingController(text: this.employee.getParameterByString("phone"));
        _title = "Phone Number";
        break;
      default:
        throw new NullThrownError();
    }
  }

  Widget _buildWidgetToShow() {
    Widget widgetToShow;
    switch(this.option) {
      case 0:
        widgetToShow = FormTemplate.buildEmailInput(this._fieldController1, this._iconLabelColor, this._borderColor, this._borderoFocusColor);
        break;
      case 1:
        widgetToShow =
            FormTemplate.buildSingleTextInput(
              this._fieldController1, "Password", Icons.lock,
              this._iconLabelColor, this._borderColor, this._borderoFocusColor,
              true, false
            );
        break;
      case 2:
        widgetToShow = new Column(
          children: <Widget>[
            FormTemplate.buildSingleTextInput(
              _fieldController1, "Name(s)", Icons.person,
                this._iconLabelColor, this._borderColor, this._borderoFocusColor,
              false, true
            ),
            FormTemplate.buildSingleTextInput(
                _fieldController2, "Last Name(s)", Icons.person,
                this._iconLabelColor, this._borderColor, this._borderoFocusColor,
                false, true
            ),
          ],
        );
        break;
      case 3:
        widgetToShow =
            FormTemplate.buildNumberInput(
                this._fieldController1, "Phone Number", Icons.lock,
                this._iconLabelColor, this._borderColor, this._borderoFocusColor,
                true
            );
        break;
      default:
        throw new NullThrownError();
    }
    return widgetToShow;
  }

  void getNewValue() {
    newValues = [];
    switch(this.option) {
      case 0:
      case 1:
      case 3:
        newValues.add(_fieldController1.text);
        break;
      case 2:
        newValues.add(_fieldController1.text);
        newValues.add(_fieldController2.text);
        break;
    }
  }

  Widget _buildSubmitBtn() {
    return new Padding(
      padding: const EdgeInsets.only(left: 16.0, top: 0, bottom: 0, right: 16.0),
      child: SizedBox(
        width: double.infinity,
        child: new RaisedButton(
          child: new Text("Update Info"),
          textColor: new Color(0xFFFFFFFF),
          color: new Color(0xFF0634AA),
          splashColor: new Color(0xFF001f6e),
          onPressed: () async {
            if(_formkey.currentState.validate()){
              getNewValue();

              DialogTemplate.initLoader(context, "Updating...");
              int code = await (new QueryProfile()).updateProfileField(this.employee, this.option, this.newValues);
              DialogTemplate.terminateLoader();
              setState((){});

              DialogTemplate.showStatusUpdate(context, code);
            }
            else {
              DialogTemplate.showFormMessage(context, "Please, fill the form.");
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: new Scaffold(
        appBar: new AppBar(
          elevation: 0.0,
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
          title: Text('Update' + this._title, style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700)),
          leading: new IconButton (
            color: Colors.black,
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(Icons.arrow_back, color: Colors.black),
          ),
        ),
        body: new SingleChildScrollView(
          child: new Form(
            key: _formkey,
            child: new Column(
              children: <Widget>[
                ContainerTemplate.buildContainer(
                    new Padding(padding: new EdgeInsets.only(right: 5, left: 10, bottom: 5, top: 5), child: this._buildWidgetToShow(),),
                    [30, 15, 30, 15], 10,
                    15, 15, 0.15, 30),
                this._buildSubmitBtn(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}