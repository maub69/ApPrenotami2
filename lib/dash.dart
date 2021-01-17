import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mia_prima_app/aggiungiFrase.dart';
import 'package:mia_prima_app/calendario.dart';
import 'package:mia_prima_app/creaAppuntamento.dart';
import 'package:mia_prima_app/model.dart';
import 'package:mia_prima_app/utility/downloadJson.dart';
import 'package:mia_prima_app/utility/utility.dart';
import 'package:mia_prima_app/visualizzaFrasi.dart';
//import 'package:sqflite/sqflite.dart';
import 'login.dart';
import 'utility/utente.dart';
import 'package:path_provider/path_provider.dart';
import 'package:mia_prima_app/utility/utente.dart';
import 'package:http/http.dart' as http;

/// Pagina Dashboard che contiene il menu principale
class Dash extends StatefulWidget {
  final String idCalendario;
  final String nome;
  final String descrizione;

  Dash({this.idCalendario, this.nome, this.descrizione});

  @override
  State createState() => _StateDash();
}

class _StateDash extends State<Dash> {
  Function onPressedCalendario;

  @override
  void initState() {
    super.initState();
    //questa classe serve a gestire le richieste get per scasricare i json. Necessita dell'url e della funzione da avviare una volta finito di scaricare il json.
    //la funzione letturaTerminata viene eseguita una votla che il json viene scaricato
    //si tratta di una classe generica e' puo' essere usata in qualsiasi contesto serva scaricare un json e poi eseguire una funzione su di esso, NON solo strettamente per il calendario
    DownloadJson downloadJson = new DownloadJson(
        url: "carica_calendari.php",
        parametri: {"calendario_id": widget.idCalendario},
        // passo al parametro letturaTerminata la funzione letturaTerminata
        // che verrà eseguita nella classe DownloadJson
        letturaTerminata: letturaTerminataCalendarioRichieste);
    // funzione presente nella classe DownloadJson tramite url lancia la funzione
    downloadJson.start();
  }

  int impostaGiorno(int giornoJson) {
    var currDt = DateTime.now();
    int oggi = currDt.weekday;
    int giornoGiusto = oggi - giornoJson;
    int giornoPartenza = currDt.day - giornoGiusto;
    if (giornoPartenza < currDt.day) {
      giornoPartenza += 7;
    }
    return giornoPartenza;
  }

  //questa funzione viene eseguita una volta che viene scaricato il json contenente gli appuntamenti prenotabili e non del calendario
  //funzione usata SOLO per la sezione "Calendario richieste"
  letturaTerminataCalendarioRichieste(http.Response data) {
    if (data.statusCode == 200) {
      // print(data.body);
      // prende i dati da data e li decodifica mettendoli in result
      Map<String, dynamic> results = jsonDecode(data.body);
      // creo una lista dove ogni elemento e' un oggetto di tipo Meeting
      List<Meeting> meetings = List<Meeting>();
      String xx = results["base"]["base"];
      List listaJs = jsonDecode(xx);
      List orari;
      listaJs.forEach((ele) {
        List<dynamic> orario = ele["orari"];
        orario.forEach((eleOra) {
          List <String> soloOrainizio = eleOra["start"].split(":");
          List <String> soloOraFine = eleOra["end"].split(":");
        });
      });

      /*var dayOfWeek = 1;
      DateTime date = DateTime.now();
      var lastMonday = date
          .subtract(Duration(days: date.weekday - dayOfWeek)).to;
      print(lastMonday);*/

      // print(listaJs[0].toString());

      // listaJs.forEach((dato){
      //   meetings.add(Meeting(
      //     descrizione: )
      //  )
      // });

      /* prende i Meeting da result e li aggiunge a meetings tramite un ciclo
      results.forEach((element) {
        meetings.add(Meeting(
            descrizione: element["disponibilita"],
            from: DateTime.parse(element["inizio"]),
            to: DateTime.parse(element["fine"]),
            prenotato: element["prenotato"]));
      });
      */
      // onPressedCalendario e' la funzione che viene avviata quando si clicca calendarioRichieste, di base eì nulla
      /*onPressedCalendario = () {
        _onPressedCal(meetings);
      };*/

      setState(() {});
    } else {
      print("Erorre: ${data.statusCode}");
    }
  }

  // avvia la pagina contenenete il calendario, e' fondamentale passargli in ingresso gli appuntamenti, dovrebbe essere generica per tutti i calendari
  _onPressedCal(List<Meeting> meetings) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => Calendario(
                meetings: meetings,
                onTapMeeting: (Meeting appuntamento) {
                  //sequenza avvia la pagina che permette di richiedere un appuntamento
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) =>
                              CreaAppuntamento(meeting: appuntamento)));
                  print("risposta: ${appuntamento.descrizione}");
                })));
  }

  @override
  Widget build(BuildContext context) {
    // return Text("${widget.utente.username} - ${widget.utente.email}");
    return Model(
        confermaChiusura: true,
        appBarColor: Color(
          0xFFFF1744,
        ),
        body: Padding(
            padding: EdgeInsets.all(10),
            child: ListView(children: [
              Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.all(10),
                  child: Text(
                    'Nome Calendario: ${widget.nome}',
                    style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                        fontSize: 20),
                  )),
              Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.all(10),
                  child: Text(
                    'Descrizione: ${widget.descrizione} ',
                    style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                        fontSize: 20),
                  )),
              Container(
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: RaisedButton(
                      textColor: Colors.white,
                      color: Colors.blue,
                      child: Text('Calendario richieste'),
                      onPressed: onPressedCalendario)),
              Container(
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: RaisedButton(
                      textColor: Colors.white,
                      color: Colors.blue,
                      child: Text('Calendario richieste in attesa'),
                      onPressed: onPressedCalendario)),
              Container(
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: RaisedButton(
                      textColor: Colors.white,
                      color: Colors.blue,
                      child: Text('Calendario richieste confermate'),
                      onPressed: onPressedCalendario))
            ])));
  }
}
