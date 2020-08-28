// Models
import 'package:signature_forgery_detection/models/log.dart';

// Database
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class QueryLog {
  final logs = FirebaseFirestore.instance.collection("example-logs");

  Future applyActionOnLog(Log log, int option) async {
    FirebaseAuth _auth = FirebaseAuth.instance;
    int code = 0;
    if(_auth.currentUser != null) {
      try {
        switch(option) {  // Approve Action
          case 0:
            break;
          case 1:         // Deny Action
            break;
          default:
            throw new NullThrownError();
        }
        code = 1;
      }
      catch(error) {
        code = 2;
      }
    }
    else {
      code = 3;
    }
    return code;
  }
}