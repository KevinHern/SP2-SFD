// Basic
import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

// Models
import 'package:signature_forgery_detection/models/airesponse.dart';

// Backend
import 'package:http/http.dart';

class AIHTTPRequest{

  static Future storeRequest(String link, String signer, String signame, File signature, bool sclient) async {
    // Making POST request
    String url = link + "/storeimg";
    Map<String, String> headers = {"Content-type": "application/json"};

    // Making JSON Body
    String json = '{"signer": "' + signer + '"';
    json += ', "img": ' + signature.readAsBytesSync().toString();
    json += ', "imgname": "' + signame + '"';
    json += ', "sclient": ' + sclient.toString();
    json += ', "typesig": ' + 1.toString();
    json += '}';

    // Do request
    Response response = await post(url, headers: headers, body: json);

    // Check Status
    if(response.statusCode == 200){
      Map<String, dynamic> recvJson = JsonDecoder().convert(response.body);

      return (recvJson["code"] == 1);
    }
    else {
      return false;
    }
  }

  static Future predictRequest(String link, String signer, var models, File suspectSign, bool sclient) async {
    bool conv_model = false;
    bool ss_model = false;
    bool sm_model = false;

    // Check what models are going to be used
    for(int i = 0; i < models.length; i++){
      if(models[i] == 1) conv_model = true;
      else if(models[i] == 2) ss_model = true;
      else if(models[i] == 3) sm_model = true;
      else continue;
    }

    // Making POST request
    String url = link + "/predict";
    Map<String, String> headers = {"Content-type": "application/json"};
    String strModels = "" + models[0].toString();
    for(int i = 1; i < models.length ; i++){
      strModels += ", " + models[i].toString();
    }

    // Making JSON Body
    String json = '{"models": [' + strModels + ']';
    json += ', "img": ' + suspectSign.readAsBytesSync().toString();
    json += ', "imgext": "' + suspectSign.path.split('/').last.split('.').last + '"';
    json += ', "signer": ' + signer.toString();
    json += ', "sclient": ' + sclient.toString();
    json += '}';

    // Do request
    Response response = await post(url, headers: headers, body: json);

    // Check Status
    if(response.statusCode == 200){
      Map<String, dynamic> recvJson = JsonDecoder().convert(response.body);
      // [code, conv results, ss results, sm results]
      AIResponse ais = new AIResponse();

      // Constructing response for Convolutional Model
      if(conv_model) {
        ais.setModelFlag("conv", conv_model);
        ais.setConvPred(recvJson['conv_model']['prediction'], recvJson['conv_model']['signerp']);
        if(recvJson['conv_model']['signerp'] == 'correct') ais.setModelProbability('conv', recvJson['conv_model']['confidence']);
      }

      // Constructing response for Signer-Signature Model
      if(ss_model){
        ais.setModelFlag("ss", ss_model);
        ais.setSSPred(recvJson['ss_model']['prediction'], recvJson['ss_model']['signerp']);
        if(recvJson['ss_model']['signerp'] == 'correct') ais.setModelProbability('ss', recvJson['ss_model']['confidence']);
      }

      // Constructing response for Siamese Model
      if(sm_model){
        ais.setModelFlag("siamese", sm_model);
        ais.setSiameseSuccess(recvJson['siamese_model']['success']);
        if(ais.getSiameseSuccess()) {
          ais.setSiamesePred(recvJson['siamese_model']['prediction']);
          ais.setModelProbability('siamese', recvJson['siamese_model']['confidence']);
        }

      }
      return ais;
    }
    else {
      return null;
    }
  }

  static Future trainRequest(String link, int model, bool isClient, String signer) async {
    // Making POST request
    String url = link + "/train";
    Map<String, String> headers = {"Content-type": "application/json"};

    // Making JSON Body
    String json = '{"typem": ' + model.toString() ;
    json += ', "sclient": ' + isClient.toString();
    if(model == 22) json += ', "signer": "' +  signer + '"';
    json += '}';

    // Do request
    Response response = await post(url, headers: headers, body: json);

    // Check Status
    if(response.statusCode == 200){
      return 1;
    }
    else {
      return 0;
    }
  }

  static Future modelRequest(String link, int model, String signer, bool isClient) async {
    // Making POST request
    String url = link + "/info";
    Map<String, String> headers = {"Content-type": "application/json"};


    // Making JSON Body
    String json = '{"typem": ' + model.toString();
    json += ', "sclient": ' + isClient.toString();
    if(model == 22) json += ', "signer": "' + signer + '"';
    json += '}';

    // Do request
    Response response = await post(url, headers: headers, body: json);

    // Check Status
    if(response.statusCode == 200){
      Map<String, dynamic> recvJson = JsonDecoder().convert(response.body);
      // [code, conv results, ss results, sm results]
      AIResponse ais = new AIResponse();

      if(recvJson["exists"]){
        if(model == 1) {
          ais.setModelInfo(model, recvJson['lastdate'], recvJson['signers']);
          ais.setModelFlag("conv", true);
        }
        else if(model == 21) {
          ais.setModelInfo(model, recvJson['lastdate'], recvJson['signers']);
          ais.setModelFlag("ss", true);
        }
        else if(model == 22) {
          ais.setModelInfo(model, recvJson['lastdate'], []);
          ais.setModelFlag("ss", true);
        }
        else if(model == 3){
          ais.setModelInfo(model, recvJson['lastdate'], recvJson['signers']);
          ais.setModelFlag("siamese", true);
        }
        return ais;
      }
      else {
        return null;
      }
    }
    else {
      return null;
    }
  }

  static Future imagesRequest(String link, String signer, bool isClient) async {
    // Making POST request
    String url = link + "/signames";
    Map<String, String> headers = {"Content-type": "application/json"};

    // Making JSON Body
    String json = '{"signer": "' + signer + '"';
    json += ', "sclient": ' + isClient.toString();
    json += ', "typesig": ' + 1.toString();
    json += '}';

    // Do request
    Response response = await post(url, headers: headers, body: json);

    // Check Status
    if(response.statusCode == 200){
      Map<String, dynamic> recvJson = JsonDecoder().convert(response.body);
      // [code, conv results, ss results, sm results]
      AIResponse ais = new AIResponse();

      if(recvJson["exists"]){
        return recvJson['filenames'];
      }
      else {
        return null;
      }
    }
    else {
      return null;
    }
  }

  static Future imageRequest(String link, String signer, bool isClient, String signame, int index) async {
    // Making POST request
    String url = link + "/retreiveimg";
    Map<String, String> headers = {"Content-type": "application/json"};

    // Making JSON Body
    String json = '{"signer": "' + signer + '"';
    json += ', "sclient": ' + isClient.toString();
    json += ', "typesig": ' + 1.toString();
    json += ', "imgname": "' + signame + '"';
    json += '}';

    // Do request
    Response response = await post(url, headers: headers, body: json);

    // Check Status
    if(response.statusCode == 200){
      Map<String, dynamic> recvJson = JsonDecoder().convert(response.body);
      // [code, conv results, ss results, sm results]
      AIResponse ais = new AIResponse();

      if(recvJson["exists"]){
        final Directory directory = await getApplicationDocumentsDirectory();
        new Directory('${directory.path}/temp/').create();
        List<int> byteList = recvJson['img'].cast<int>();
        File('${directory.path}/temp/' + signame).writeAsBytesSync(byteList);
        return new File('${directory.path}/temp/' + signame);
      }
      else return null;
    }
    else return null;
  }

  static Future deleteImageRequest(String link, String signer, bool isClient, String signame) async {
    // Making POST request
    String url = link + "/deleteimg";
    Map<String, String> headers = {"Content-type": "application/json"};

    // Making JSON Body
    String json = '{"signer": "' + signer + '"';
    json += ', "sclient": ' + isClient.toString();
    json += ', "typesig": ' + 1.toString();
    json += ', "imgname": "' + signame + '"';
    json += '}';

    print(json);

    // Do request
    Response response = await post(url, headers: headers, body: json);

    // Check Status
    if(response.statusCode == 200){
      Map<String, dynamic> recvJson = JsonDecoder().convert(response.body);
      // [code, conv results, ss results, sm results]
      print(recvJson);
      return (recvJson["code"] == 1)? true : false;
    }
    else return false;
  }
}