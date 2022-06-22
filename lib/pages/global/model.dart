import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:stack/stack.dart' as st;

/// classe che viene usata da tutti i widget che vogliono visualizzare una pagina a schermo intero
/// usando questa si evita di ricreare tutto a mano e perciò risulta pratica da utilizzare
class Model extends StatelessWidget {
  static st.Stack<BuildContext> stackContext = new st
      .Stack(); // permette di conservare lo stack con tutti i context attivi, in questo modo si ha sempre nel top il context che si sta visualizzando e dato che model viene usato per tutte le schermate, questa cosa risulta molto utile, per esempio per l'invio delle notifiche dall'interno dell'app
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
        },
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
