import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mia_prima_app/dash.dart';
import 'package:mia_prima_app/model.dart';
import 'package:mia_prima_app/utility/downloadJson.dart';
import 'package:http/http.dart' as http;
import 'package:mia_prima_app/utility/utility.dart';

class SceltaCalendario extends StatefulWidget {
  SceltaCalendario();

  @override
  State createState() => _StateSceltaCalendario();
}

class _StateSceltaCalendario extends State<SceltaCalendario> {
  Widget _body = Text("");

  @override
  void initState() {
    List<Widget> listCalendari = [];

    //in questo punto scarico tutti i calendari di un determinato amministratore, l'obiettivo e' quello di scaricarli e poi decidere quale visualizzare
    //TODO un qualche cosa da mettere nel body in attesa
    //TODO sistemare la visualizzazione del container ricordandosi di inserire anche la descrizione
    DownloadJson downloadJson = new DownloadJson(
        url: "getCalendari.php",
        parametri: {"id": Utility.idApp},
        letturaTerminata: (http.Response data) {
          List<dynamic> results = jsonDecode(data.body);
          results.forEach((element) {
            print("Calendario: " +
                element["id"] +
                " - " +
                element["nome"] +
                " - " +
                element["descrizione"]);

            listCalendari.add(GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => Dash(idCalendario: element["id"], nome: element["nome"], descrizione: element["descrizione"])));
                  },
                child: Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.all(10),
                    child: Text(
                      element["nome"],
                      style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                          fontSize: 20),
                    ))));
          });

          _body = Padding(
              padding: EdgeInsets.all(10),
              child: ListView(children: listCalendari));
        });
    // funzione presente nella classe DownloadJson tramite url lancia la funzione
    downloadJson.start();
  }

  @override
  Widget build(BuildContext context) {
    return Model(body: _body);
  }
}
