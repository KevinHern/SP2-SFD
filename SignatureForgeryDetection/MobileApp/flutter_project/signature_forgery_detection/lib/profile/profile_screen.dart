// Basic Imports
import 'package:flutter/material.dart';
import 'dart:io';

// Models
import 'package:signature_forgery_detection/models/employee.dart';
import 'package:signature_forgery_detection/templates/navbar_template.dart';
import 'profile_edit.dart';

// Templates
import 'package:signature_forgery_detection/templates/container_template.dart';
import 'package:signature_forgery_detection/templates/image_handler.dart';
import 'package:signature_forgery_detection/templates/dialog_template.dart';

// Backend
import 'package:firebase_storage/firebase_storage.dart';
import 'package:signature_forgery_detection/backend/log_query.dart';

class ProfileScreen extends StatefulWidget {
  final Employee employee;
  ProfileScreen({Key key, @required this.employee}) : super(key: key);

  @override
  ProfileScreenState createState() => ProfileScreenState(employee: this.employee);
}

class ProfileScreenState extends State<ProfileScreen> {
  final Color _iconColor = new Color(0xFF002FD3).withOpacity(0.60);
  final Employee employee;
  final List<Widget> _settingsBtns = [];
  List<Widget> _employeeInfo = [];
  final List<IconData> _icons =[Icons.email, Icons.lock,
                        Icons.phone, Icons.share, Icons.schedule];

  ProfileScreenState({Key key, @required this.employee});

  @override
  void initState() {
    super.initState();
    for(int i = 0; i < this.employee.getTotalRealParameters(); i++) {
      // Add EDIT functionality
      this._settingsBtns.add(
          new IconButton(
            icon: new Icon(Icons.edit, color: _iconColor,),
            onPressed: () async {
                await Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileEditScreen(employee: this.employee, option: i))).then((value) {setState(() {});});
            },
          )
      );
    }
  }

  Widget _profilePicture(){
    return new Center(
      child: new Stack(
        children: <Widget>[
          CircleAvatar(
            radius: 100,
            foregroundColor: new Color(0xFF3949AB),
            child: new CircleAvatar(
              radius: 90,
              backgroundImage: NetworkImage(this.employee.getProfilePicURL()),
              //child: new Image.network('https://www.woolha.com/media/2020/03/eevee.png'),
            ),
          ),
          new Positioned(
            bottom: 0,
            right: 10,
            child: NavBarTemplate.buildFAB(
                Icons.camera,
                () async {
                  File profilePic = await ImageHandler.getImage(0);
                  StorageReference storageReference = FirebaseStorage.instance.ref();
                  String filename = "profile." + profilePic.path.split('/').last.split('.').last;
                  DialogTemplate.initLoader(context, "Uploading profile picture...");
                  StorageUploadTask uploadTask = storageReference.child("employees/" + this.employee.getUID() + "/" + filename).putFile(profilePic);
                  await uploadTask.onComplete;
                  int logCode = await (new QueryLog()).pushLog(
                      0, " updated his or her information.",
                      this.employee.getParameterByString("name") + " " + this.employee.getParameterByString("lname"),
                      '',
                      this.employee.getUID(),
                      0, "Updated the profile picture field.", 0
                  );
                  DialogTemplate.terminateLoader();
                  String url = await FirebaseStorage.instance.ref().child("employees/" + this.employee.getUID() + "/profile.jpg").getDownloadURL();
                  this.employee.setProfilePicURL(url);
                  DialogTemplate.showMessage(context, "Profile picture updated successfully");



                  setState(() {});
                },
                "Profile_FAB"
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileInfo(){
    return new ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      separatorBuilder: (context, index) => Padding(
        padding: EdgeInsets.only(left: 66, right: 20),
        child: Divider(
          color: new Color(0x000000).withOpacity(0.15),
          thickness: 1,
        ),
      ),
      itemCount: this._employeeInfo.length,
      padding: EdgeInsets.all(5.0),
      itemBuilder: (context, index) {
        return this._employeeInfo[index];
      },
    );
  }

  Widget _profile(){
    return new ListView(
      padding: EdgeInsets.only(top: 50),
      children: <Widget>[
        new Padding(padding: EdgeInsets.only(bottom: 10), child: this._profilePicture(),),
        new Text(
          this.employee.getParameterByString("name") + " " + this.employee.getParameterByString("lname"),
          style: new TextStyle(
            fontSize: 20,
          ),
          textAlign: TextAlign.center,
        ),
        new Text(
          this.employee.getParameterByString("position"),
          style: new TextStyle(
              fontSize: 16,
              color: new Color(0x000000).withOpacity(0.50)
          ),
          textAlign: TextAlign.center,
        ),
        ContainerTemplate.buildContainer(
          this._profileInfo(),
          [30, 9, 30, 100],
          20,
          15,
          15,
          0.15,
          30,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    this._employeeInfo = [];
    this._employeeInfo.add(
      new ListTile(
        leading: new Icon(this._icons[0], color: this._iconColor,),
        title: new Text("Email"),
        subtitle: new Text(this.employee.getParameterByString("email")),
        trailing: this._settingsBtns[0],
      ),
    );

    // Password
    this._employeeInfo.add(
      new ListTile(
        leading: new Icon(this._icons[1], color: this._iconColor,),
        title: new Text("Password"),
        subtitle: new Text("******"),
        trailing: this._settingsBtns[1],
      ),
    );

    // Phone
    this._employeeInfo.add(
      new ListTile(
        leading: new Icon(this._icons[2], color: this._iconColor,),
        title: new Text("Phone Number"),
        subtitle: new Text(this.employee.getParameterByString("phone")),
        trailing: this._settingsBtns[3],
      ),
    );

    // Birthday
    this._employeeInfo.add(
      new ListTile(
        leading: new Icon(Icons.cake, color: this._iconColor,),
        title: new Text("Birthday"),
        subtitle: new Text(this.employee.getParameterByString("birthday")),
        trailing: this._settingsBtns[4],
      ),
    );

    // Department
    this._employeeInfo.add(
      new ListTile(
        leading: new Icon(this._icons[3], color: this._iconColor,),
        title: new Text("Department"),
        subtitle: new Text(this.employee.getParameterByString("dept")),
      ),
    );

    // Schedule
    this._employeeInfo.add(
      new ListTile(
        leading: new Icon(this._icons[4], color: this._iconColor,),
        title: new Text("Schedule"),
        subtitle: new Text(this.employee.getParameterByString("init") + " to " + this.employee.getParameterByString("end")),
      ),
    );
    return this._profile();
  }
}