// Basic Imports
import 'package:flutter/material.dart';

// Routes
import 'package:signature_forgery_detection/client/client_edit.dart';
import 'package:signature_forgery_detection/client/client_verify.dart';
import 'package:signature_forgery_detection/ai/ai_signature_model.dart';
import 'package:signature_forgery_detection/client/signatures/client_signatures.dart';
import 'package:signature_forgery_detection/client/signatures/client_more_signatures.dart';

// Models
import 'package:signature_forgery_detection/models/client.dart';
import 'package:signature_forgery_detection/models/navbar.dart';

// Templates
import 'package:signature_forgery_detection/templates/container_template.dart';
import 'package:signature_forgery_detection/templates/dialog_template.dart';
import 'package:signature_forgery_detection/templates/fade_template.dart';
import 'package:signature_forgery_detection/templates/navbar_template.dart';

// Backend
import 'package:signature_forgery_detection/backend/aihttp.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ClientInfoScreen extends StatelessWidget {
  final Client client;
  final String issuer;
  final bool issuerPowers;
  ClientInfoScreen({Key key, @required this.client, @required this.issuer, @required this.issuerPowers});

  @override
  Widget build(BuildContext context) {
    return ClientInfo(client: this.client, issuer: this.issuer, issuerPowers: this.issuerPowers,);
  }
}

class ClientInfo extends StatefulWidget {
  final Client client;
  final String issuer;
  final bool issuerPowers;
  ClientInfo({Key key, @required this.client, @required this.issuer, @required this.issuerPowers});

  ClientInfoState createState() => ClientInfoState(client: this.client, issuer: this.issuer, issuerPowers: this.issuerPowers);
}

class ClientInfoState extends State<ClientInfo> with SingleTickerProviderStateMixin {
  final Client client;
  final String issuer;
  final bool issuerPowers;
  NavBar navBar;
  FadeAnimation _fadeAnimation;

  ClientInfoState({Key key, @required this.client, @required this.issuer, @required this.issuerPowers});

  final Color _iconColor = new Color(0xFF002FD3).withOpacity(0.60);
  final List<Widget> _settingsBtns = [];
  List<Widget> _clientInfo = [];

  @override
  void initState() {
    super.initState();
    this.navBar = new NavBar(1, 1);
    this._fadeAnimation = new FadeAnimation(this);
    for(int i = 0; i < this.client.getTotalRealParameters(); i++) {
      // Add EDIT functionality
      this._settingsBtns.add(
          new IconButton(
            icon: new Icon(Icons.edit, color: this._iconColor,),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ClientEditScreen(client: this.client, option: i, issuer: this.issuer))).then((value) => setState(() {}));
            },
          )
      );
    }

    this._settingsBtns.add(
        new IconButton(
          icon: new Icon(Icons.delete_forever, color: new Color(0xFFFFFFFF),),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => ClientEditScreen(client: this.client, option: this.client.getTotalRealParameters(), issuer: this.issuer))).then((value) => setState(() {}));
          },
        )
    );
  }

  Widget _profileInfo(){
    return new ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      separatorBuilder: (context, index) => Padding(
        padding: EdgeInsets.only(left: 20, right: 20),
        child: Divider(
          color: new Color(0x000000).withOpacity(0.15),
          thickness: 1,
        ),
      ),
      itemCount: this._clientInfo.length,
      padding: EdgeInsets.all(5.0),
      itemBuilder: (context, index) {
        return this._clientInfo[index];
      },
    );
  }

  Widget _profile(){
    // Add INFO list Tile
    // Email
    this._clientInfo = [];
    this._clientInfo.add(
      new ListTile(
        leading: new Icon(Icons.email, color: this._iconColor,),
        title: new Text("Email"),
        subtitle: new FittedBox(
          fit: BoxFit.fitWidth,
          child: new Text(this.client.getParameterByString("email")),
        ),
        trailing: this._settingsBtns[0],
      ),
    );

    // Phone
    this._clientInfo.add(
      new ListTile(
        leading: new Icon(Icons.phone, color: this._iconColor,),
        title: new Text("Phone Number"),
        subtitle: new Text(this.client.getParameterByString("phone")),
        trailing: this._settingsBtns[1],
      ),
    );

    // Birthday
    this._clientInfo.add(
      new ListTile(
        leading: new Icon(Icons.cake, color: this._iconColor,),
        title: new Text("Birthday"),
        subtitle: new Text(this.client.getParameterByString("birthday")),
        trailing: this._settingsBtns[2],
      ),
    );

    // Registration Date
    this._clientInfo.add(
      new ListTile(
        leading: new Icon(Icons.date_range, color: this._iconColor,),
        title: new Text("Registration Date"),
        subtitle: new Text(this.client.getParameterByString("registration")),
      ),
    );

    return new ListView(
      padding: EdgeInsets.only(top: 50, bottom: 30),
      shrinkWrap: true,
      children: <Widget>[
        new Text(
          this.client.getParameterByString("name"),
          style: new TextStyle(
            fontSize: 20,
          ),
          textAlign: TextAlign.center,
        ),
        new Text(
        this.client.getParameterByString("lname"),
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
                  elevation: 10,
                  hoverElevation: 10,
                  backgroundColor: Colors.red,
                  child: this._settingsBtns[this.client.getTotalRealParameters()],
                  mini: true,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget manyOptionsScreen() {
    return new Center(
      child: ListView(
        shrinkWrap: true,
        children: <Widget>[
          ContainerTemplate.buildTileOption(
            Icons.folder,
            "Check\nSignatures",
            () async {
              String imgserver_link = "";
              DialogTemplate.initLoader(context, "Please, wait for a moment...");
              final CollectionReference misc = FirebaseFirestore.instance.collection('miscellaneous');
              await misc.doc("imgserver").get().then((
                  snapshot) {
                if(snapshot.exists) {
                  imgserver_link = snapshot.get("server");
                }
              });
              var signames = await AIHTTPRequest.imagesRequest(imgserver_link, this.client.getUID(), true);
              DialogTemplate.terminateLoader();

              if (signames == null) DialogTemplate.showMessage(context, "The user does not have any registered signatures");
              else Navigator.push(context, MaterialPageRoute(builder: (context) => ClientSignatureScreen(issuer: this.issuer, client: this.client, signames: signames))).then((value) => setState(() {}));
            },
          ),
          ContainerTemplate.buildTileOption(
            Icons.note_add,
            "Add\nSignatures",
            () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ClientMoreSignaturesScreen(issuer: this.issuer, client: this.client))).then((value) => setState(() {}));
            },
          ),
          ContainerTemplate.buildTileOption(
              Icons.android,
              "Check\nAI Model",
              () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => AIMainClientScreen(client: this.client, issuer: this.issuer,)));
              }
          ),
        ],
      ),
    );
  }

  Widget returnScreen() {
    switch(this.navBar.getPageIndex()) {
      case 0:
        return this.manyOptionsScreen();
      case 1:
        return this._profile();
      case 2:
        return new ClientVerifyScreen(client: this.client, issuer: this.issuer);
      default:
        return new Container();
    }
  }

  void navOnTap(index){
    setState(() {
      this.navBar.setBoth(index);
      this.navBar.setOnMainScreen(index == 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return NavBarTemplate.buildBottomNavBar(
      this.navBar,
      NavBarTemplate.buildTripletItems([Icons.assignment, Icons.search], ["Menu", "Verify"]),
      navOnTap,
      NavBarTemplate.buildFAB(
        this.navBar.isOnMainScreen()? Icons.home : Icons.keyboard_return,
            () {
          if(this.navBar.isOnMainScreen()) Navigator.of(context).pop();
          else setState(() {
            this.navBar.setBoth(1);
            this.navBar.setOnMainScreen(true);
          });
        },
        "client_information_fab"
      ),
      this._fadeAnimation.fadeNow(this.returnScreen()),
    );
  }
}