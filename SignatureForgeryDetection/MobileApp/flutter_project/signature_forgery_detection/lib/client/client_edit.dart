// Basic Imports
import 'package:flutter/material.dart';

// Models
import 'package:signature_forgery_detection/models/client.dart';

// Templates
import 'package:signature_forgery_detection/templates/container_template.dart';
import 'package:signature_forgery_detection/templates/form_template.dart';
import 'package:signature_forgery_detection/templates/dialog_template.dart';
import 'package:signature_forgery_detection/templates/navbar_template.dart';
import 'package:signature_forgery_detection/templates/fade_template.dart';

// Database
import 'package:signature_forgery_detection/backend/client_query.dart';
import 'package:signature_forgery_detection/backend/log_query.dart';

class ClientEditScreen extends StatelessWidget {
  final Client client;
  final int option;
  final String issuer;
  ClientEditScreen({Key key, @required this.client, @required this.option, @required this.issuer});

  @override
  Widget build(BuildContext context) {
    //print("Option at ProfileEditScreen: "+ this.option.toString());
    return ProfileEdit(client: this.client, option: this.option, issuer: this.issuer,);
  }
}

class ProfileEdit extends StatefulWidget {
  final Client client;
  final int option;
  final String issuer;
  ProfileEdit({Key key, @required this.client, @required this.option, @required this.issuer});

  ProfileEditState createState() => ProfileEditState(client: this.client, option: this.option, issuer: this.issuer);
}

class ProfileEditState extends State<ProfileEdit> with SingleTickerProviderStateMixin {
  final Client client;
  final int option;
  final int _iconLabelColor = 0xFF002FD3;
  final int _borderColor = 0xff856fdd;
  final int _borderoFocusColor = 0xff5436cf;
  final String issuer;
  FadeAnimation _fadeAnimation;

  ProfileEditState({Key key, @required this.client, @required this.option, @required this.issuer});

  final _formkey = GlobalKey<FormState>();
  TextEditingController _fieldController1;
  TextEditingController _fieldController2;
  String _title, _oldValue;
  var newValues = [];

  @override
  void initState() {
    super.initState();
    this._fadeAnimation = new FadeAnimation(this);
    switch(this.option) {
      case 0:
        _oldValue = this.client.getParameterByString("email");
        _fieldController1 = new TextEditingController(text: _oldValue);
        _title = "Update E-mail";
        break;
      case 1:
        _oldValue = this.client.getParameterByString("phone");
        _fieldController1 = new TextEditingController(text: _oldValue);
        _title = "Update Phone Number";
        break;
      case 2:
        _oldValue = this.client.getParameterByString("birthday");
        _fieldController1 = new TextEditingController(text: _oldValue);
        _title = "Update Birthday";
        break;
      case 3:
        //_oldValue = this.client.getParameterByString("name") + " " + this.client.getParameterByString("lname");
        _fieldController1 = new TextEditingController(text: this.client.getParameterByString("name"));
        _fieldController2 = new TextEditingController(text: this.client.getParameterByString("lname"));
        _title = "Update Name";
        break;
      case 4:
        _fieldController1 = new TextEditingController();
        _title = "Deletion Request";
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
            FormTemplate.buildNumberInput(
                this._fieldController1, "Phone Number", Icons.call,
                this._iconLabelColor, this._borderColor, this._borderoFocusColor,
                true
            );
        break;
      case 2:
        widgetToShow =
            FormTemplate.buildDateInput(
                this._fieldController1, "Birthday", Icons.cake,
                this._iconLabelColor, this._borderColor, this._borderoFocusColor,
                "hello", context
            );
        break;
      case 3:
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
      case 4:
        widgetToShow =
            FormTemplate.buildMultiTextInput(
                this._fieldController1, "Reason", Icons.cake,
                this._iconLabelColor, this._borderColor, this._borderoFocusColor,
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
      case 2:
      case 4:
        newValues.add(_fieldController1.text);
        break;
      case 3:
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
          int code = (this.option == 4)? 0 : await (new QueryClient()).updateClientField(this.client, this.option, this.newValues);
          DialogTemplate.terminateLoader();
          setState((){});

          String clientName = this.client.getParameterByString("name") + " " + this.client.getParameterByString("lname");
          String description = (this.option == 4)? " requesting deletion on client " : " updated (CLIENT) " + clientName + "'s information.";
          String reason = (this.option == 4)? this._fieldController1.text : "Updated the" + this._title.replaceFirst("Update", "") + " field.";
          int logCode = await (new QueryLog()).pushLog(
              (this.option == 4)? 1 : 0, description,
              this.issuer,
              (this.option == 4) ? clientName : "",
              this.client.getUID(),
              (this.option == 4)? 3 : 0, reason, (this.option == 4)? 1 : 0
          );
          DialogTemplate.terminateLoader();

          if(logCode == 1)
            if (this.option == 4) DialogTemplate.showFormMessage(context, "Request sent successfully");
            else DialogTemplate.showFormMessage(context, "Update successful");
          else
          if (this.option == 4) DialogTemplate.showFormMessage(context, "Request sent but failed to make a log");
          else DialogTemplate.showFormMessage(context, "Update successful but failed to register a log.");
        }
        else {
          DialogTemplate.showFormMessage(context, "Please, fill the form.");
        }
      },
      new Text((this.option == 4)? "Send" : "Update", style: new TextStyle(fontSize: 18),)
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
      child: NavBarTemplate.buildAppBar(
        context,
        this._title,
        new SingleChildScrollView(
          child: new Form(
            key: _formkey,
            child: this._fadeAnimation.fadeNow(
              ContainerTemplate.buildContainer(
                new Column(
                  children: <Widget>[
                    new Padding(padding: new EdgeInsets.only(right: 5, left: 5, top:5), child: this._buildWidgetToShow()),
                    this._buildSubmitBtn(),
                  ],
                ),
                [30, 0, 30, 15], 10,
                15, 15, 0.15, 30
              ),
            ),
          ),
        ),
      ),
    );

  }
}