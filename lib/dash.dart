import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mia_prima_app/calendario.dart';
import 'package:mia_prima_app/creaAppuntamento.dart';
import 'package:mia_prima_app/steps.dart';
import 'package:mia_prima_app/listaPrenotazioniFuture.dart';
import 'package:mia_prima_app/main.dart';
import 'package:mia_prima_app/model.dart';
import 'package:mia_prima_app/utility/convertSettimanaInCalendario.dart';
import 'package:mia_prima_app/utility/downloadJson.dart';
import 'package:http/http.dart' as http;
import 'package:mia_prima_app/utility/endpoint.dart';
import 'package:mia_prima_app/utility/utility.dart';
import 'package:mia_prima_app/visualizzaPrenotazioneFutura.dart';

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
  Function onPressedListaPrenotazioniFuture;
  Function onPressedNotifiche;
  BuildContext _context;

  @override
  void initState() {
    super.initState();
    //questa classe serve a gestire le richieste get per scasricare i json. Necessita dell'url e della funzione da avviare una volta finito di scaricare il json.
    //la funzione letturaTerminata viene eseguita una votla che il json viene scaricato
    //si tratta di una classe generica e' puo' essere usata in qualsiasi contesto serva scaricare un json e poi eseguire una funzione su di esso, NON solo strettamente per il calendario
    Utility.idCalendario = widget.idCalendario;
    DownloadJson downloadJson = new DownloadJson(
        url: EndPoint.GET_CALENDARI_SETTIMANE,
        parametri: {
          "id_calendario": widget.idCalendario,
          "calendari_timestamp": "-1"
        },
        // passo al parametro letturaTerminata la funzione letturaTerminata
        // che verrà eseguita nella classe DownloadJson
        letturaTerminata: letturaTerminataCalendarioRichieste);
    // funzione presente nella classe DownloadJson tramite url lancia la funzione
    downloadJson.start();

    DownloadJson downloadJsonListaPrenotazioni = new DownloadJson(
        url: EndPoint.GET_APPUNTAMENTI,
        // passo al parametro letturaTerminata la funzione letturaTerminata
        // che verrà eseguita nella classe DownloadJson
        letturaTerminata: letturaTerminataListaPrenotazioni);
    // funzione presente nella classe DownloadJson tramite url lancia la funzione
    downloadJsonListaPrenotazioni.start();

    DownloadJson downloadNotifiche = new DownloadJson(
        url: EndPoint.GET_APPUNTAMENTI,
        // passo al parametro letturaTerminata la funzione letturaTerminata
        // che verrà eseguita nella classe DownloadJson
        letturaTerminata: letturaTerminataNotifiche);
    // funzione presente nella classe DownloadJson tramite url lancia la funzione
    downloadNotifiche.start();
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

  letturaTerminataListaPrenotazioni(http.Response data) {
    if (data.statusCode == 200) {
      Utility.listaPrenotazioni = jsonDecode(data.body);
      onPressedListaPrenotazioniFuture = () {
        _onPressedListaPrenotazioniFuture();
      };

      if (idAppuntamento != "-1") {
        // se idAppuntamento != "-1", allora cio' significa che e' presente un appuntamento da aprire
        // viene cercato l'appuntamento tra la lista degli appuntamenti e poi viene aperto con VisualizzaPrenotazioneFutura
        // il parametro aggiornaPrenotazioni permette di modificare la listaPrenotazioni con le nuove info sulla prenotazione
        // non e' necessario aprire la schermata della lista delle prenotazioni, in quanto sono già presenti tutte le info per aprire la sezione di dettaglio da questa schermata
        int idAppuntamentoAprire = -1;
        for (int i = 0; i < Utility.listaPrenotazioni.length; i++) {
          if (Utility.listaPrenotazioni[i]["id"].toString() == idAppuntamento) {
            idAppuntamentoAprire = i;
          }
        }
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => VisualizzaPrenotazioneFutura(
                    prenotazione:
                        Utility.listaPrenotazioni[idAppuntamentoAprire],
                    aggiornaPrenotazioni: (String body) {
                      Map<String, dynamic> _arrayBody = jsonDecode(body);
                      Utility.listaPrenotazioni[idAppuntamentoAprire] =
                          _arrayBody["new_element"];
                    })));
      }
      setState(() {});
    }
  }

  letturaTerminataNotifiche(http.Response data) {
    if (data.statusCode == 200) {
      List<dynamic> listaNotifiche = jsonDecode(data.body);
      onPressedNotifiche = () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => Scaffold(
                  appBar: AppBar(title: Text("Esempio")),
                  body: Steps(
                    json: '{"title": "Processo olive", "started": true, "description": "Le varie fasi per spremere le olive","steps": [{"name": "Fase 1","done": true,"messages": ["prima sotto fase fatta", "seconda sotto fase fatta"]},{"name": "Fase 2", "done": true, "messages": ["prima sotto fase fatta 2","seconda sottofase fatta 2"]}]}'
                  )
          ),
            ));
      };
      setState(() {});
    }
  }

  //questa funzione viene eseguita una volta che viene scaricato il json contenente gli appuntamenti prenotabili e non del calendario
  //funzione usata SOLO per la sezione "Calendario richieste"
  letturaTerminataCalendarioRichieste(http.Response data) {
    if (data.statusCode == 200) {
      // print(data.body);
      // prende i dati da data e li decodifica mettendoli in result
      /*Map<String, dynamic> results = jsonDecode(data.body);
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
      });*/

      ConvertSettimanaInCalendario convertSettimana =
          new ConvertSettimanaInCalendario(jsonString: data.body);
      Utility.calendario = convertSettimana.getCalendarioDisponibilita();
      Utility.calendario.forEach((element) {
        element.showMessage = _showMessage;
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
      onPressedCalendario = () {
        _onPressedCal(Utility.calendario);
      };

      setState(() {});
    } else {
      print("Erorre: ${data.statusCode}");
    }
  }

  void _showMessage(
      String title, String body, String messageAdmin, Color color) {
    //per funzionare necessita di utilizzare un context, sul quale poi appunto si applica la funzione showSnackBar
    //il problema pero' e' che non può essere utilizzato lo stesso context dello statefulwidget, percio' contextGlobal non puo essere usato
    //cio' significa che bisgona utilizzare un nuovo context, per fare cio' bisogna crearlo con l'oggetto Builder che si trova piu' sotto
    Scaffold.of(_context).showSnackBar(new SnackBar(
      content: Column(
          children: [
            Text(title, style: TextStyle(fontSize: 20)),
            Text(body, style: TextStyle(fontSize: 15)),
            Text(messageAdmin, style: TextStyle(fontSize: 10))
          ],
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start),
      backgroundColor: color,
      duration: Duration(seconds: 10),
    ));
  }

  // avvia la pagina contenenete il calendario, e' fondamentale passargli in ingresso gli appuntamenti, dovrebbe essere generica per tutti i calendari
  _onPressedCal(List<Disponibilita> meetings) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => Calendario(
                calendario: meetings,
                onTapDisponibilita: (Disponibilita appuntamento) {
                  //sequenza avvia la pagina che permette di richiedere un appuntamento
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => CreaAppuntamento(
                                disponibilita: appuntamento,
                                idCalendario: widget.idCalendario,
                              )));
                  print("risposta: ${appuntamento.descrizione}");
                })));
  }

  _onPressedListaPrenotazioniFuture() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => ListaPrenotazioniFuture()));
  }

  @override
  Widget build(BuildContext context) {
    Model.stackContext.push(context);
    // return Text("${widget.utente.username} - ${widget.utente.email}");
    return Model(
        confermaChiusura: true,
        appBarColor: Color(
          0xFFFF1744,
        ),
        body: new Builder(builder: (BuildContext context) {
          _context = context;
          return Padding(
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
                        child: Text('Lista prenotazioni future'),
                        onPressed: onPressedListaPrenotazioniFuture)),
                Container(
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: RaisedButton(
                        textColor: Colors.white,
                        color: Colors.blue,
                        child: Text('Notifiche'),
                        onPressed: onPressedNotifiche))
              ]));
        }));
  }
}
