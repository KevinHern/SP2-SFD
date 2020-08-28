// Models
import 'package:signature_forgery_detection/models/employee.dart';

// Database
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class QueryProfile {
  final employees = FirebaseFirestore.instance.collection("example-employees");

  Future updateProfileField(Employee employee, int option, List<String> newValues) async {
    FirebaseAuth _auth = FirebaseAuth.instance;
    int code = 0;
    if(_auth.currentUser != null) {
      try {
        switch(option) {
          case 0:
            await employee.user.updateEmail(newValues[0]);
            await employees.doc(employee.getUID()).update({
              'email': newValues[0]
            });
            employee.updateByString("email", newValues[0]);
            break;
          case 1:
            await employee.user.updatePassword(newValues[0]);
            break;
          case 2:
            await employees.doc(employee.getUID()).update({
              'name': newValues[0],
              'lastName': newValues[1]
            });
            employee.updateByString("name", newValues[0]);
            employee.updateByString("lname", newValues[1]);
            break;
          case 3:
            await employees.doc(employee.getUID()).update({
              'phone': newValues[0]
            });
            employee.updateByString("phone", newValues[0]);
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