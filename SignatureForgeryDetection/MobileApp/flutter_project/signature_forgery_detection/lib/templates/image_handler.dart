import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';

class ImageHandler{
  static Future getImage(int option) async {
    File _image;
    if(option == 0) {
      _image = await ImagePicker.pickImage(
          source: ImageSource.camera, imageQuality: 50
      );

    }
    else {
      _image = await ImagePicker.pickImage(
          source: ImageSource.gallery, imageQuality: 50
      );
    }

    /*
    if(_image != null) {

      File croppedImage = await ImageCropper.cropImage(
        sourcePath: _image.path,
        maxWidth: 300,
        maxHeight: 300,
      );
      if (croppedImage != null) {
        setState(() {
          this._signature = _image;
        });
      }
    }
    */

    return _image;
  }
}