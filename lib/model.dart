import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mia_prima_app/login.dart';
import 'package:path_provider/path_provider.dart';

class Model extends StatelessWidget {
  final Widget body;
  final List<Widget> actions;
  final Color appBarColor;
  final bool confermaChiusura;

  Model({this.body, this.actions, this.appBarColor, this.confermaChiusura = false});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () {
          if (confermaChiusura) {
            return showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text("Confermi l'uscita?"),
                      content: Text("Fai tap su Si per uscire"),
                      actions: [
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop(false);
                          },
                          child: Text("No"),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop(true);
                          },
                          child: Text("Si"),
                        )
                      ],
                    );
                  },
                ) ??
                false;
          } else {
            return Future.value(true);
          }
          //
        },
        child: Scaffold(
            appBar: AppBar(
              backgroundColor:
                  (appBarColor == null) ? Colors.green : appBarColor,
              centerTitle: true,
              title: Text('ApPuntamento'),
              actions: (actions == null) ? [] : actions,
            ),
            drawer: Drawer(
              // Add a ListView to the drawer. This ensures the user can scroll
              // through the options in the drawer if there isn't enough vertical
              // space to fit everything.
              child: ListView(
                // Important: Remove any padding from the ListView.
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                    child: Text('Impostazioni'),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                    ),
                  ),
                  ListTile(
                    title: Text('Item 1'),
                    onTap: () {
                      // Update the state of the app.
                      // ...
                    },
                  ),
                  ListTile(
                    title: Text('Item 2'),
                    onTap: () {
                      // Update the state of the app.
                      // ...
                    },
                  ),
                  Container(
                      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                      child: RaisedButton(
                          textColor: Colors.white,
                          color: Colors.blue,
                          child: Text('Logout'),
                          onPressed: () {
                            delDataLogin();

                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        Login()));
                          }))
                ],
              ),
            ),
            body: body));
  }
}

void delDataLogin() async {
  final directory = await getApplicationDocumentsDirectory();
  String path = directory.path;
  File file = File('$path/id.txt');
  file.delete();
}
