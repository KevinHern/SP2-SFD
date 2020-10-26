// Basic
import 'package:flutter/material.dart';
import 'package:signature_forgery_detection/models/client.dart';
import 'dart:io';

// Templates
import 'package:signature_forgery_detection/templates/navbar_template.dart';
import 'package:signature_forgery_detection/templates/form_template.dart';
import 'package:signature_forgery_detection/templates/fade_template.dart';
import 'package:signature_forgery_detection/templates/container_template.dart';
import 'package:signature_forgery_detection/templates/dialog_template.dart';

// Backend
import 'package:signature_forgery_detection/backend/aihttp.dart';
import 'package:signature_forgery_detection/backend/log_query.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignatureEditScreen extends StatelessWidget {
  final String issuer;
  final Client client;
  final File signature;
  final List<File> signatures;
  final int option;
  SignatureEditScreen({Key key, @required this.issuer, @required this.client, @required this.signature, @required this.signatures, @required this.option});

  @override
  Widget build(BuildContext context) {
    return SignatureEdit(issuer: this.issuer, client: this.client, signature: this.signature, signatures: this.signatures, option: this.option);
  }
}

class SignatureEdit extends StatefulWidget {
  final String issuer;
  final Client client;
  final File signature;
  final List<File> signatures;
  final int option;
  SignatureEdit({Key key, @required this.issuer, @required this.client, @required this.signature, @required this.signatures, @required this.option});

  SignatureEditState createState() => SignatureEditState(issuer: this.issuer, client: this.client, signature: this.signature, signatures: this.signatures, option: this.option);
}

class SignatureEditState extends State<SignatureEdit> with SingleTickerProviderStateMixin {
  final String issuer;
  final Client client;
  final File signature;
  final List<File> signatures;
  final int option;
  SignatureEditState({Key key, @required this.issuer, @required this.client, @required this.signature, @required this.signatures, @required this.option});

  FadeAnimation _fadeAnimation;
  final int _iconLabelColor = 0xFF002FD3;
  final int _borderColor = 0xff856fdd;
  final int _borderoFocusColor = 0xff5436cf;
  TextEditingController _fieldController;
  final _formkey = GlobalKey<FormState>();
  var newValues = [];

  @override
  void initState() {
    super.initState();
    this._fadeAnimation = new FadeAnimation(this);
    switch(this.option) {
      case 0:
        // Delete signature
        _fieldController = new TextEditingController();
        break;
      default:
        throw new NullThrownError();
    }
  }

  Widget _buildWidgetToShow() {
    Widget widgetToShow;
    switch(this.option) {
      case 0:
        widgetToShow =
            FormTemplate.buildMultiTextInput(
              this._fieldController, "Reason", Icons.report,
              this._iconLabelColor, this._borderColor, this._borderoFocusColor,
            );
        break;
      default:
        throw new NullThrownError();
    }
    return widgetToShow;
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
        this.signature.path.split('/').last,
        new SingleChildScrollView(
          child: new Form(
            key: _formkey,
            child: this._fadeAnimation.fadeNow(
              ContainerTemplate.buildContainer(
                  new Column(
                    children: <Widget>[
                      new Padding(padding: new EdgeInsets.only(right: 5, left: 5, top:5), child: this._buildWidgetToShow()),
                      ContainerTemplate.buildBasicButton(
                        () async {
                          // All good
                          String imgserver_link = "";
                          final CollectionReference misc = FirebaseFirestore.instance.collection('miscellaneous');
                          await misc.doc("imgserver").get().then((
                              snapshot) {
                            if(snapshot.exists) {
                              imgserver_link = snapshot.get("server");
                            }
                          });

                          DialogTemplate.initLoader(context, "Please, wait for a moment...");
                          String signame = this.signature.path.split('/').last;
                          bool response = await AIHTTPRequest.deleteImageRequest(imgserver_link, this.client.getUID(), true, signame);
                          if (response) {
                            String clientName = this.client.getParameterByString("name") + " " + this.client.getParameterByString("lname");
                            int logCode = await (new QueryLog()).pushLog(
                                0, " deleted (CLIENT) " + clientName + "'s signature: " + signame,
                                this.issuer,
                                '' ,
                                this.client.getUID(),
                                0, _fieldController.text, 0
                            );
                            DialogTemplate.terminateLoader();
                            DialogTemplate.showSpecialMessage(context, "Successfully deleted the signature.");
                            //this.signatures.remove(this.signature);

                          }
                          else {
                            DialogTemplate.terminateLoader();
                            DialogTemplate.showMessage(context, "An error has occurred while deleting the signature.");
                          }
                        },
                        Text("Delete", style: TextStyle(fontSize: 18)),
                      ),
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