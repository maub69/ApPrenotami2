import 'dart:io';

import 'package:flutter/material.dart';
import 'pages/avvio/login.dart';
import 'package:mia_prima_app/utility/utility.dart';
import 'package:path_provider/path_provider.dart';
import 'package:stack/stack.dart' as st;

class Model extends StatelessWidget {
  static st.Stack<BuildContext> stackContext = new st
      .Stack(); // permette di conservare lo stack con tutti i context attivi, in questo moto si ha sempre nel top il context che si sta visualizzando e dato che model viene usato per tutte le schermate, questa cosa risulta molto utile, per esempio per l'invio delle notifiche dall'interno dell'app
  final Widget body;
  final List<Widget> actions;
  final Color appBarColor;
  final bool confermaChiusura;
  final bool showAppbar;
  final String textAppBar;
  final Widget floatingActionButton;

  Model(
      {this.body,
      this.actions,
      this.appBarColor,
      this.confermaChiusura = false,
      this.showAppbar = true,
      this.textAppBar = "ApPuntamento",
      this.floatingActionButton});

  static BuildContext getContext() {
    return stackContext.top();
  }

  @override
  Widget build(BuildContext context) {
    stackContext.push(context);
    return WillPopScope(
        onWillPop: () {
          if (confermaChiusura) {
            return showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      contentPadding: EdgeInsets.only(top: 10.0),
                      title: Text("Confermi l'uscita dall'app?"),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5.0))),
                      // content: Text("Fai tap su Si per uscire"),
                      content: Container(
                        margin: EdgeInsets.only(top: 15),
                        padding: EdgeInsets.only(bottom: 2, top: 2, right: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(5), bottomRight: Radius.circular(5)),
                          color: Colors.green[900]
                        ),
                        child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop(false);
                          },
                          child: Padding(
                            padding: EdgeInsets.only(top: 10, left: 10, right: 25, bottom: 10),
                            child: Text("Annulla", style: TextStyle(fontSize: 19, color: Colors.white)),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop(true);
                          },
                          child: Padding(
                            padding: EdgeInsets.only(top: 10, right: 15, bottom: 10),
                            child: Text("Ok", style: TextStyle(fontSize: 19, color: Colors.white)),
                          ),
                        )
                      ]),
                      ),
                    );
                  },
                ) ??
                false;
          } else {
            stackContext.pop();
            return Future.value(true);
          }
          //
        },
        //quando si inserisce un widget Builder ricordarsi sempre che deve essere "figlio" dello scaffold, altirmenti non funziona
        //Diventa necessario il widget Builder quando serve il context, in particolare nel nostro codice quando serve il context per showSnackBar
        child: Scaffold(
            appBar: (showAppbar
                ? AppBar(
                    backgroundColor:
                        (appBarColor == null) ? Colors.green[900] : appBarColor,
                    centerTitle: true,
                    title: Text(this.textAppBar),
                    actions: (actions == null) ? [] : actions,
                  )
                : null),
            /* drawer: Drawer(
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
            ),*/
            body: body,
            floatingActionButton: floatingActionButton
          ));
  }
}

void delDataLogin() async {
  final directory = await getApplicationDocumentsDirectory();
  String path = directory.path;
  File file = File('$path/id.txt');
  file.delete();
}
