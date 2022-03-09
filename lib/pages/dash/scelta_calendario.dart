import 'dart:convert';

import 'package:flutter/material.dart';
import 'dash.dart';
import 'package:mia_prima_app/main.dart';
import '../global/model.dart';
import 'package:mia_prima_app/utility/download_json.dart';
import 'package:http/http.dart' as http;
import 'package:mia_prima_app/utility/endpoint.dart';
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
    super.initState();
    List<Widget> listCalendari = [];

    //in questo punto scarico tutti i calendari di un determinato amministratore, l'obiettivo e' quello di scaricarli e poi decidere quale visualizzare
    DownloadJson downloadJson = new DownloadJson(
        url: EndPoint.GET_CALENDARI,
        parametri: {"id": Utility.idApp},
        letturaTerminata: (http.Response data) {
          if (idCalendario != "-1") {
            // se idCalendario != "-1", cio' significa che e' presente un calendario che deve essere automanticamente aperto
            // nelle righe successive a partire dall'idCalendario si cerca l'oggetto del calendario corrispondente e viene aperta automaticamente la schermata della dash del calendario
            int idCalendarioAprire = -1;
            List<dynamic> results = jsonDecode(data.body);
            for (int i = 0; i < results.length; i++) {
              if (results[i]["id"] == idCalendario) {
                idCalendarioAprire = i;
              }
            }
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) =>
                        Dash(idCalendario: results[idCalendarioAprire]["id"])));
          } else {
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
                    print("calendario_id: ${element["id"]}");
                    print("calendario_nome: ${element["nome"]}");
                    print("calendario_descrizione: ${element["descrizione"]}");
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                Dash(idCalendario: element["id"])));
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
            setState(() {});
          }
        });
    // funzione presente nella classe DownloadJson tramite url lancia la funzione
    downloadJson.start();
  }

  @override
  Widget build(BuildContext context) {
    return Model(body: _body);
  }
}