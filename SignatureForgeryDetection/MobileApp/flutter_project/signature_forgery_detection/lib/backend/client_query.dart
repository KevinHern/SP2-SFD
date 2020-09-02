// Models
import 'package:signature_forgery_detection/models/client.dart';

// Database
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class QueryClient {
  final clients = FirebaseFirestore.instance.collection("clients");

  Future updateClientField(Client client, int option, var newValues) async {
    FirebaseAuth _auth = FirebaseAuth.instance;
    int code = 0;
    if(_auth.currentUser != null) {
      try {
        switch(option) {
          case 0:
            await clients.doc(client.getUID()).update({
              'email': newValues[0]
            });
            client.updateByString("email", newValues[0]);
            break;
          case 1:
            await clients.doc(client.getUID()).update({
              'phone': newValues[0]
            });
            client.updateByString("phone", newValues[0]);
            break;
          case 2:
            await clients.doc(client.getUID()).update({
              'birthday': newValues[0]
            });
            client.updateByString("birthday", newValues[0]);
            break;
          case 3:
            await clients.doc(client.getUID()).update({
              'name': newValues[0],
              'lastName': newValues[1]
            });
            client.updateByString("name", newValues[0]);
            client.updateByString("lname", newValues[1]);
            break;

          default:
            throw new NullThrownError();
        }
        code = 1;
      }
      catch(error) {
        print(error.toString());
        code = 2;
      }
    }
    else {
      code = 3;
    }
    return code;
  }
}