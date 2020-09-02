// Models
import 'package:signature_forgery_detection/models/log.dart';



// Database
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class QueryLog {
  final logs = FirebaseFirestore.instance.collection("logs");
  final clients = FirebaseFirestore.instance.collection("clients");
  final employees = FirebaseFirestore.instance.collection("employees");
  final sequentials = FirebaseFirestore.instance.collection("sequentials");
  final registrationDate = "${DateTime.parse(new DateTime.now().toString()).day}/${DateTime.parse(new DateTime.now().toString()).month}/${DateTime.parse(new DateTime.now().toString()).year}";

  Future getNewLogID() async {
    // Return and set the updated "likes" count from the transaction
    int newClientId = await FirebaseFirestore.instance
        .runTransaction<int>((transaction) async {
      final doc = sequentials.doc("logseq");
      DocumentSnapshot snapshot = await transaction.get(doc);

      if (!snapshot.exists) {
        return -1;
      }
      else {
        transaction.update(doc, {
          'nextID': snapshot.get("nextID") + 1
        });
        return snapshot.get("nextID");
      }
    });

    return newClientId;
  }

  Future hideLog(Log log) async {
    FirebaseAuth _auth = FirebaseAuth.instance;
    int code = 0;
    if(_auth.currentUser != null) {
      try {
        code = await FirebaseFirestore.instance
            .runTransaction<int>((transaction) async {
          final doc = logs.doc(log.getFieldByString("id").toString());
          DocumentSnapshot snapshot = await transaction.get(doc);

          if (!snapshot.exists) {
            return -1;
          }
          else {
            transaction.update(doc, {
              'hide': true
            });
            return 1;
          }
        });
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

  Future applyActionOnLog(Log log) async {
    FirebaseAuth _auth = FirebaseAuth.instance;
    int code = 0;
    if(_auth.currentUser != null) {
      try {
        switch(log.getFieldByString("action")) {  // Approve Action
          /*
            ACTION:
            0 == CREATION
            1 == EDIT
            2 == VERIFICATION
            3 == DELETION CLIENT
            4 == DELETION EMPLOYEE
            5 == UPDATE CLIENT
            6 == UPDATE EMPLOYEE
            7 == UPDATE PROFILE
          */
          /*
            STATUS:
            0 == SHOW
            1 == PENDING
            2 == APPROVED
            3 == DENIED
           */
          case 0:
          case 1:
          case 2:
          case 5:
          case 6:
          case 7:
            await logs.doc(log.getFieldByString("id").toString()).set({
              'type': log.getFieldByString("type") as int,
              'description': log.getFieldByString("description") as String,
              'who': log.getFieldByString("who") as String,
              'victim': log.getFieldByString("victim") as String,
              'victimid': log.getFieldByString("victimid") as String,
              'reason': log.getFieldByString("reason") as String,
              'action': log.getFieldByString("action") as int,
              'status': 0,
              'date': this.registrationDate,
              'hide': false
            });
            break;
          case 3:
          case 4:
            await logs.doc(log.getFieldByString("id").toString()).set({
              'type': log.getFieldByString("type") as int,
              'description': log.getFieldByString("description") as String,
              'who': log.getFieldByString("who") as String,
              'victim': log.getFieldByString("victim") as String,
              'victimid': log.getFieldByString("victimid") as String,
              'reason': log.getFieldByString("reason") as String,
              'action': log.getFieldByString("action") as int,
              'status': 1,
              'date': this.registrationDate,
              'hide': false
            });
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

  Future doLogAction(Log log, int adminAction) async {
    FirebaseAuth _auth = FirebaseAuth.instance;
    int code = 0;
    if(_auth.currentUser != null) {
      try {
        switch(log.getFieldByString("action")) {  // Approve Action
        /*
            ACTION:
            0 == CREATION
            1 == EDIT
            2 == VERIFICATION
            3 == DELETION CLIENT
            4 == DELETION EMPLOYEE
          */
        /*
            STATUS:
            0 == SHOW
            1 == PENDING
            2 == APPROVED
            3 == DENIED

            ADMIN ACTION:
            0 == DENY
            1 == APPROVE
           */
          case 3:
            code = await FirebaseFirestore.instance.runTransaction<int>((transaction) async {
              final logDoc = logs.doc(log.getFieldByString("id").toString());
              final clientDoc = clients.doc(log.getFieldByString("victimid"));

              if(adminAction == 0) {
                transaction.update(logDoc, {
                  'type': 2,
                  'status': 3
                });
                log.updateFieldByString("type", 2);
                log.updateFieldByString("status", 3);
                return 1;
              }
              else if(adminAction == 1) {
                transaction.delete(clientDoc);
                transaction.update(logDoc, {
                  'type': 2,
                  'status': 2
                });
                log.updateFieldByString("type", 2);
                log.updateFieldByString("status", 2);
                return 1;
              }
              else {
                return -1;
              }
            });
            break;
          case 4:
            code = await FirebaseFirestore.instance.runTransaction<int>((transaction) async {
              final logDoc = logs.doc(log.getFieldByString("id").toString());
              final employeeDoc = employees.doc(log.getFieldByString("victimid"));

              if(adminAction == 0) {
                transaction.update(logDoc, {
                  'type': 2,
                  'status': 3
                });
                return 1;
              }
              else if(adminAction == 1) {
                transaction.delete(employeeDoc);
                transaction.update(logDoc, {
                  'type': 2,
                  'status': 2
                });
                return 1;
              }
              else {
                return -1;
              }
            });
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

  Future pushLog(int logType, String description, String who, String victim, String victimid, int action, String reason, int status) async {
    Log log = new Log(
        await (new QueryLog()).getNewLogID(),
        logType, description,
        who,
        victim,
        victimid,
        action, reason, status
    );

    return await (new QueryLog()).applyActionOnLog(log);
  }
}