// Basic Imports
import 'package:flutter/material.dart';

// Routes
import 'package:signature_forgery_detection/employee/employee_edit.dart';
import 'package:signature_forgery_detection/models/employee.dart';

// Templates
import 'package:signature_forgery_detection/templates/container_template.dart';

class EmployeeInfoScreen extends StatelessWidget {
  final String uid;
  EmployeeInfoScreen({Key key, @required this.uid});

  @override
  Widget build(BuildContext context) {
    return EmployeeInfo(uid: this.uid,);
  }
}

class EmployeeInfo extends StatefulWidget {
  final String uid;
  EmployeeInfo({Key key, @required this.uid});

  EmployeeInfoState createState() => EmployeeInfoState(uid: this.uid);
}

class EmployeeInfoState extends State<EmployeeInfo> {
  final String uid;
  var dummyDate = new DateTime.now();
  //"${DateTime.parse(new DateTime.now().toString()).day}-${DateTime.parse(new DateTime.now().toString()).month}-${DateTime.parse(new DateTime.now().toString()).year}";

  Employee employee = new Employee("Test Testing Lolol", "Dummy Dummy Dummmmmmmmmmm", "dummy.dummy.io@test.com", "01003040", "Testing IT", "Dummy dummy", "08:00", "15:00");
  EmployeeInfoState({Key key, @required this.uid});

  final Color _iconColor = new Color(0xff6F74DD).withOpacity(0.60);
  final List<Widget> _settingsBtns = [];
  final List<Widget> _employeeInfo = [];
  final List<IconData> _icons =[Icons.email,
    Icons.phone, Icons.share, Icons.bookmark, Icons.schedule];

  @override
  void initState() {
    super.initState();
    for(int i = 0; i < 4; i++) {
      // Add EDIT functionality
      this._settingsBtns.add(
          new IconButton(
            icon: new Icon(Icons.edit, color: new Color(0x6F74DD).withOpacity(0.60),),
            onPressed: () {
              setState(() {
                Navigator.push(context, MaterialPageRoute(builder: (context) => EmployeeEditScreen(employee: this.employee, option: i)));
              });
            },
          )
      );
    }

    // Widgets

    // Add INFO list Tile
    // Email
    this._employeeInfo.add(
      new ListTile(
        leading: new Icon(this._icons[0], color: this._iconColor,),
        title: new Text(this.employee.getParameterByString("email"))
      ),
    );

    // Phone
    this._employeeInfo.add(
      new ListTile(
        leading: new Icon(this._icons[1], color: this._iconColor,),
        title: new Text(this.employee.getParameterByString("phone")),
      ),
    );

    // Department
    this._employeeInfo.add(
      new ListTile(
        leading: new Icon(this._icons[2], color: this._iconColor,),
        title: new Text(this.employee.getParameterByString("dept")),
        trailing: this._settingsBtns[0],
      ),
    );

    // Position
    this._employeeInfo.add(
      new ListTile(
        leading: new Icon(this._icons[3], color: this._iconColor,),
        title: new Text(this.employee.getParameterByString("position")),
        trailing: this._settingsBtns[1],
      ),
    );

    // Init Schedule
    this._employeeInfo.add(
      new ListTile(
        leading: new Icon(this._icons[4], color: this._iconColor,),
        title: new Text(this.employee.getParameterByString("init")),
        trailing: this._settingsBtns[2],
      ),
    );

    // End Schedule
    this._employeeInfo.add(
      new ListTile(
        leading: new Icon(this._icons[4], color: this._iconColor,),
        title: new Text(this.employee.getParameterByString("end")),
        trailing: this._settingsBtns[3],
      ),
    );

  }

  // Alerts
  void _showResult(BuildContext context, bool legit) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new ListTile(
            leading: legit? new Icon(Icons.check_circle, size: 45, color: Colors.green,) : new Icon(Icons.warning, size: 40, color: Colors.red,),
            title: new Text("Notice", style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 25),),
          ),
          content: legit?
          new Text("The system has determined that the signature has a high probability of being legit.")
              : new Text("Signature has been verified and seems to be forged."),
          actions: <Widget>[
            FlatButton(
              child: Text("Ok"),
              onPressed: () {
                //Put your code here which you want to execute on Yes button click.
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
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

  Widget _buildVerifyButton() {
    return new Padding(padding: EdgeInsets.only(left: 30, right: 30),
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        //padding: new EdgeInsets.only(left: 20, right: 20),
        onPressed: () {
          // Open camera, send picture and show result
          this._showResult(context, false);
        },
        color: new Color(0xFF002FD3),
        textColor: Colors.white,
        child: Text("Verify Signature",
            style: TextStyle(fontSize: 18)),
      ),
    );
  }

  Widget _profile(){
    return new ListView(
      padding: EdgeInsets.only(top: 20, bottom: 30),
      children: <Widget>[
        new Text(
          this.employee.getParameterByString("name"),
          style: new TextStyle(
            fontSize: 20,
          ),
          textAlign: TextAlign.center,
        ),
        new Text(
          this.employee.getParameterByString("lname"),
          style: new TextStyle(
              fontSize: 16,
              color: new Color(0x000000).withOpacity(0.50)
          ),
          textAlign: TextAlign.center,
        ),
        new Stack(
          children: <Widget>[
            ContainerTemplate.buildContainer(
              this._profileInfo(),
              [30, 10, 30, 20],
              20,
              15,
              15,
              0.15,
              30,
            ),
            new Positioned(
              top: 0,
              right: 0,
              child: new Padding(
                padding: EdgeInsets.only(right: 8),
                child: new FloatingActionButton(
                  onPressed: () {

                  },
                  elevation: 10,
                  hoverElevation: 10,
                  backgroundColor: Colors.red,
                  child: new Icon(Icons.delete_forever),
                  mini: true,
                ),
              ),
            ),
          ],
        ),
        this._buildVerifyButton(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        leading: new IconButton (
          color: Colors.black,
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.arrow_back, color: Colors.black),
        ),
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: new BoxDecoration(
            gradient: new LinearGradient(
                colors: [
                  const Color(0x003949AB),
                  const Color(0xFF3949AB),
                ],
                begin: const FractionalOffset(0.0, 0.0),
                end: const FractionalOffset(1.0, 0.0),
                stops: [0.0, 1.0],
                tileMode: TileMode.clamp),
          ),
        ),
        title: Text('Informacion de la Cuenta', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700)),
      ),
      body: this._profile(),//this._screens[this._pageIndex],
    );
  }
}