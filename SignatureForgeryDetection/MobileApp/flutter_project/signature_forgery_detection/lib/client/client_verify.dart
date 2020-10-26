// Basic
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';

// Models
import 'package:signature_forgery_detection/models/client.dart';
import 'package:signature_forgery_detection/models/airesponse.dart';

// Templates
import 'package:signature_forgery_detection/templates/container_template.dart';
import 'package:signature_forgery_detection/templates/image_handler.dart';
import 'package:signature_forgery_detection/templates/dialog_template.dart';

// Backend
import 'package:signature_forgery_detection/backend/aihttp.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:signature_forgery_detection/backend/log_query.dart';

class ClientVerifyScreen extends StatefulWidget{
  final Client client;
  final String issuer;
  ClientVerifyScreen({Key key, @required this.client, @required this.issuer});

  ClientVerifyState createState() => ClientVerifyState(client: this.client, issuer: this.issuer);
}

class ClientVerifyState extends State<ClientVerifyScreen>{
  final Client client;
  final String issuer;
  ClientVerifyState({Key key, @required this.client, @required this.issuer});
  bool _siameseNetwork = false;
  bool _convolutionalClassification = false;
  bool _signer_signatureClassification = false;
  final _formkey = GlobalKey<FormState>();

  final int _iconLabelColor = 0xFF002FD3;
  final int _borderColor = 0xff856fdd;
  final int _borderoFocusColor = 0xff5436cf;

  File _signature;
  File _pivot;
  var icons = [Icons.scanner, Icons.all_out, Icons.assignment];
  var _models = [];

  Widget powerSwitch(String text, int boolOption){
    return new Padding(
      padding: EdgeInsets.only(left: 8.0, bottom: 5.0, top: 5.0, right: 8.0),
      child: new ListTile(
        leading: new Icon(icons[boolOption], color: Color(this._iconLabelColor).withOpacity(0.60),),
        title: new Text(text, style: new TextStyle(
          color: new Color(this._iconLabelColor),
        ),
        ),
        trailing: Switch(
          value: (boolOption == 0)? this._siameseNetwork : (boolOption == 1)? this._convolutionalClassification : this._signer_signatureClassification,
          onChanged: (value){
            if(boolOption == 0){
              this._siameseNetwork = value;
              if(value) _models.add(3);
              else {
                _models.remove(3);
                this._pivot = null;
              }
            }
            else if(boolOption == 1) {
              this._convolutionalClassification = value;
              if(value) _models.add(1);
              else _models.remove(1);
            }
            else {
              this._signer_signatureClassification = value;
              if(value) _models.add(2);
              else _models.remove(2);
            }
            setState(() {

            });
          },
          activeTrackColor: new Color(this._borderoFocusColor),
          activeColor: new Color(this._borderColor),
        ),
      ),
    );
  }

  Widget _buildSignatureSelection(bool isPivot){
    return new Padding(padding: EdgeInsets.only(left: 5, right: 5),
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          RaisedButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            //padding: new EdgeInsets.only(left: 20, right: 20),
            onPressed: () async {
              if(isPivot) this._pivot = await ImageHandler.getImage(0);
              else this._signature = await ImageHandler.getImage(0);
              setState(() {});
            },
            color: new Color(0xFF002FD3),
            textColor: Colors.white,
            child: Text("Take\nPicture",
                style: TextStyle(fontSize: 18), textAlign: TextAlign.center,),
          ),
          RaisedButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            //padding: new EdgeInsets.only(left: 20, right: 20),
            onPressed: () async {
              FilePickerResult result = await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                allowedExtensions: ['jpg', 'png', 'jpeg']
              );

              if(result != null) {
                if(isPivot) this._pivot = File(result.files.single.path);
                else this._signature = File(result.files.single.path);
              }

              setState(() {});
            },
            color: new Color(0xFF002FD3),
            textColor: Colors.white,
            child: Text("From\nGallery",
                style: TextStyle(fontSize: 18), textAlign: TextAlign.center),
          ),
        ],
      )
    );
  }

  // Alerts
  void _showResult(BuildContext context, String text) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new ListTile(
            leading: new Icon(Icons.info, size: 45, color: Colors.blue,),
            title: new Text("Notice", style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 25),),
          ),
          content: new Text(text),
          actions: <Widget>[
            FlatButton(
              child: Text("Ok"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildVerifyButton(){
    return new Padding(padding: EdgeInsets.only(left: 30, right: 30, bottom: 20),
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        //padding: new EdgeInsets.only(left: 20, right: 20),
        onPressed: () async {
          if(this._signature == null){
            DialogTemplate.showMessage(context, "Please, select a signature to verify");
          }
          else if(!this._convolutionalClassification && !this._signer_signatureClassification && !this._siameseNetwork){
            DialogTemplate.showMessage(context, "Please, select a model to verify a signature");
          }
          else {
            // All good
            String aiserver_link = "";
            final CollectionReference misc = FirebaseFirestore.instance.collection('miscellaneous');
            await misc.doc("aiserver").get().then((
                snapshot) {
              if(snapshot.exists) {
                aiserver_link = snapshot.get("server");
              }
            });

            DialogTemplate.initLoader(context, "Please, wait for a moment...");
            AIResponse response = await AIHTTPRequest.predictRequest(aiserver_link, this.client.getUID(), this._models, this._signature, true);
            String clientName = this.client.getParameterByString("name") + " " + this.client.getParameterByString("lname");
            int logCode = await (new QueryLog()).pushLog(
                0, " requested a signature verification request on (CLIENT)" + clientName,
                this.issuer,
                clientName ,
                this.client.getUID(),
                0, "Issued a signature verification request.", 0
            );
            DialogTemplate.terminateLoader();

            // Conv model results
            String cm_results = "";
            String ss_results = "";
            String sm_results = "";
            if(response.getModelFlag("conv")) {
              cm_results = "\n\nThe Convolutional Model estimates that the signature is " + response.getConvPred()[0]
                  + ".\nThe signer was classified " + response.getConvPred()[1] + "ly.";
              if(response.getConvPred()[1] == 'correct') cm_results += "\nThe Model is " + response.getModelProbability('conv') + "% confident about its veredict.";
            }
            if(response.getModelFlag("ss")) {
              ss_results = "\n\nThe Signer-Signature Model classified the signer " + response.getSSPred()[0] + "ly."
                  + " It estimates that the signature is " + response.getSSPred()[1] + ".";
              if(response.getSSPred()[0] == 'correct') ss_results += "\nThe Model is " + response.getModelProbability('ss') + "% confident about its veredict.";
            }
            if(response.getModelFlag("siamese")) {
              sm_results = response.getSiameseSuccess()? "\n\nThe Siamese Model estimates that the signature is " + response.getSiamesePred() + "." :
              " \n\nAn error occurred with the Siamese Model, the client does not have any registered signatures." ;
            }

            String total_text = "Results:" + cm_results + ss_results + sm_results;

            // Show results
            this._showResult(context, total_text);
          }
        },
        color: new Color(0xFF002FD3),
        textColor: Colors.white,
        child: Text("Verify",
            style: TextStyle(fontSize: 18)),
      ),
    );
  }

  Widget _buildAiForm(){
    return new Form(
      child: new ListView(
        //physics: const NeverScrollableScrollPhysics(),
        children: <Widget>[
          ContainerTemplate.buildContainer(
              new Column(
                children: <Widget>[
                  ContainerTemplate.buildContainer(new Padding(padding: EdgeInsets.only(left: 10, top: 5, bottom: 5), child: this.powerSwitch("Convolution Classification Model", 1),), [15, 15, 15, 15], 10, 5, 5, 0.15, 10),
                  ContainerTemplate.buildContainer(new Padding(padding: EdgeInsets.only(left: 10, top: 5, bottom: 5), child: this.powerSwitch("Signer Signature Classification Model", 2),), [15, 15, 15, 15], 10, 5, 5, 0.15, 10),
                  //ContainerTemplate.buildContainer(new Padding(padding: EdgeInsets.only(left: 10, top: 5, bottom: 5), child: this.powerSwitch("Siamese Network Model", 0),), [15, 15, 15, 15], 10, 5, 5, 0.15, 10),
                  new Padding(
                    padding: EdgeInsets.only(bottom: 10, top: 5),
                    child: new Text("Select Signature", style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 28), textAlign: TextAlign.center,),
                  ),
                  this._buildSignatureSelection(false),
                  new Container(
                    padding: new EdgeInsets.all(30),
                    child: (_signature == null)? null : Image.file(this._signature),
                  ),
                  /*
                  Visibility(
                    visible: this._siameseNetwork,
                    child: new Column(
                      children: <Widget>[
                        new Padding(
                          padding: EdgeInsets.only(bottom: 10, top: 5),
                          child: new Text("Select Pivot Signature", style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 28), textAlign: TextAlign.center,),
                        ),
                        this._buildSignatureSelection(true),
                        new Container(
                          padding: new EdgeInsets.all(30),
                          child: (this._pivot == null)? null : Image.file(this._pivot),
                        ),
                      ],
                    ),
                  ),
                   */
                  this._buildVerifyButton(),
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
    return this._buildAiForm();
  }
}

