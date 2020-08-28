// Models
import 'package:signature_forgery_detection/models/employee.dart';

// Database
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class QueryEmployee {
  final employees = FirebaseFirestore.instance.collection("example-employees");

  Future updateEmployeeField(Employee employee, int option, List<String> newValues) async {
    FirebaseAuth _auth = FirebaseAuth.instance;
    int code = 0;
    if(_auth.currentUser != null) {
      try {
        switch(option) {
          case 0:
            await employees.doc(employee.getUID()).update({
              'department': newValues[0]
            });
            employee.updateByString("dept", newValues[0]);
            break;
          case 1:
            await employees.doc(employee.getUID()).update({
              'position': newValues[0]
            });
            employee.updateByString("position", newValues[0]);
            break;
          case 2:
            await employees.doc(employee.getUID()).update({
              'init': newValues[0]
            });
            employee.updateByString("init", newValues[0]);
            break;
          case 3:
            await employees.doc(employee.getUID()).update({
              'end': newValues[0]
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