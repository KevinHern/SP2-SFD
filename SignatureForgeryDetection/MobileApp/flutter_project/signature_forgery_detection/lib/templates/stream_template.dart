import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StreamTemplate {
  final ScrollController listScrollController = new ScrollController();

  Widget buildStreamWithContext(bool compare, String messageWhenEmpty,
      Stream stream,
      Widget howToList(BuildContext context, DocumentSnapshot doc)) {
    return StreamBuilder(
      stream: stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
              child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue)));
        } else {
          if (snapshot.data.documents.length > 0) {
            return ListView.builder(
              padding: EdgeInsets.all(5.0),
              itemCount: snapshot.data.documents.length,
              itemBuilder: (context, index) {
                return howToList(context, snapshot.data.documents[index]);
              },
              controller: listScrollController,
            );
          }
          else {
            return new AlertDialog(
              title: new Text("Warning"),
              content: new Text(messageWhenEmpty),
            );
          }
        }
      },
    );
  }
}