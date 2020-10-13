// Basic Imports
import 'package:flutter/material.dart';

// Models
import 'package:signature_forgery_detection/models/employee.dart';

// Templates
import 'package:signature_forgery_detection/templates/container_template.dart';
import 'package:signature_forgery_detection/templates/fade_template.dart';
import 'package:signature_forgery_detection/templates/form_template.dart';
import 'package:signature_forgery_detection/templates/dialog_template.dart';
import 'package:signature_forgery_detection/templates/navbar_template.dart';
import 'package:signature_forgery_detection/templates/navbar_template.dart';

// Backend
import 'package:signature_forgery_detection/backend/profile_query.dart';
import 'package:signature_forgery_detection/backend/log_query.dart';

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

class ProfileEditState extends State<ProfileEdit> with SingleTickerProviderStateMixin {
  final Employee employee;
  final int option;
  FadeAnimation _fadeAnimation;
  final int _iconLabelColor = 0xFF002FD3;
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
    this._fadeAnimation = new FadeAnimation(this);
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
      case 4:
        _fieldController1 = new TextEditingController(text: this.employee.getParameterByString("birthday"));
        _title = "Birthday";
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
      case 4:
        widgetToShow =
            FormTemplate.buildDateInput(
                this._fieldController1, "Birthday", Icons.cake,
                this._iconLabelColor, this._borderColor, this._borderoFocusColor,
                "hola", context
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
      case 4:
        newValues.add(_fieldController1.text);
        break;
      case 2:
        newValues.add(_fieldController1.text);
        newValues.add(_fieldController2.text);
        break;
    }
  }

  Widget _buildSubmitBtn() {
    return ContainerTemplate.buildBasicButton(
          () async {
        if(_formkey.currentState.validate()){
          getNewValue();

          DialogTemplate.initLoader(context, "Updating...");
          int code = await (new QueryProfile()).updateProfileField(this.employee, this.option, this.newValues);


          int logCode = await (new QueryLog()).pushLog(
              0, " updated his or her information.",
              this.employee.getParameterByString("name") + " " + this.employee.getParameterByString("lname"),
              '',
              this.employee.getUID(),
              0, "Updated the " + this._title + " field.", 0
          );
          DialogTemplate.terminateLoader();

          if(logCode == 1) DialogTemplate.showStatusUpdate(context, code);
          else DialogTemplate.showMessage(context, "Update successful but failed to register a log.");

        }
        else {
          DialogTemplate.showFormMessage(context, "Please, fill the form.");
        }
      },
      Text('Update Info',
          style: TextStyle(fontSize: 18)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return NavBarTemplate.buildAppBar(
      context,
      'Update ' + this._title,
      new SingleChildScrollView(
        child: new Form(
          key: _formkey,
          child: this._fadeAnimation.fadeNow(
            ContainerTemplate.buildContainer(
              new Column(
                children: <Widget>[
                  new Padding(padding: EdgeInsets.only(left: 5, right: 5, top: 5), child: this._buildWidgetToShow(),),
                  this._buildSubmitBtn(),
                ],
              ),
              [30, 15, 30, 15], 10,
              15, 15, 0.15, 30,
            ),
          ),
        ),
      ),
    );
  }
}