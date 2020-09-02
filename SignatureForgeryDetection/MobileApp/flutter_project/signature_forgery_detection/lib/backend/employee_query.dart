// Models
import 'package:signature_forgery_detection/models/employee.dart';

// Database
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class QueryEmployee {
  final employees = FirebaseFirestore.instance.collection("employees");

  Future updateEmployeeField(Employee employee, int option, var newValues) async {
    FirebaseAuth _auth = FirebaseAuth.instance;
    int code = 0;
    if(_auth.currentUser != null) {
      try {
        code = await FirebaseFirestore.instance
            .runTransaction<int>((transaction) async {
          final doc = this.employees.doc(employee.getUID());
          DocumentSnapshot snapshot = await transaction.get(doc);

          if (!snapshot.exists) {
            return -1;
          }
          else {
            switch(option) {
              case 0:
                transaction.update(doc, {
                  'department': newValues[0]
                });
                employee.updateByString("dept", newValues[0]);
                break;
              case 1:
                transaction.update(doc, {
                  'position': newValues[0]
                });
                employee.updateByString("position", newValues[0]);
                break;
              case 2:
                transaction.update(doc, {
                  'init': newValues[0],
                  'end': newValues[1]
                });
                employee.updateByString("init", newValues[0]);
                employee.updateByString("end", newValues[1]);
                break;
              case 3:
                bool powers = employee.getPowers();
                transaction.update(doc, {
                  'reason': newValues[0],
                  'powers': !powers
                });
                employee.setPowers(!powers);
                break;
              default:
                throw new NullThrownError();
            }
            return 1;
          }
        });
      }
      catch(error) {
        code = 2;
        print("Profile Update Error: " + error.toString());
      }
    }
    else {
      code = 3;
    }
    return code;
  }

  Future updatePowers(Employee employee, bool newPower) async {
    FirebaseAuth _auth = FirebaseAuth.instance;
    int code = 0;
    if(_auth.currentUser != null) {
      try {
        code = await FirebaseFirestore.instance
            .runTransaction<int>((transaction) async {
          final doc = this.employees.doc(employee.getUID());
          DocumentSnapshot snapshot = await transaction.get(doc);

          if (!snapshot.exists) {
            return -1;
          }
          else {
            transaction.update(doc, {
              'powers': newPower
            });
            employee.setPowers(newPower);
            return 1;
          }
        });
      }
      catch(error) {
        code = 2;
        print("Profile Update Error: " + error.toString());
      }
    }
    else {
      code = 3;
    }
    return code;
  }
}