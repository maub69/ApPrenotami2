import 'dart:math';

import 'package:flutter/material.dart';
import 'package:loading/indicator/ball_pulse_indicator.dart';
import 'package:loading/loading.dart';
import 'package:mia_prima_app/chatpage.dart';
import 'package:mia_prima_app/model.dart';
import 'package:http/http.dart' as http;
import 'package:mia_prima_app/notificationSender.dart';
import 'package:mia_prima_app/steps.dart';
import 'package:mia_prima_app/utility/endpoint.dart';
import 'package:mia_prima_app/utility/utility.dart';

class VisualizzaPrenotazioneFutura extends StatefulWidget {
  final dynamic prenotazione;
  final int indexPrenotazioni;
  final Function aggiornaPrenotazioni;

  VisualizzaPrenotazioneFutura(
      {this.prenotazione, this.indexPrenotazioni, this.aggiornaPrenotazioni});

  @override
  State createState() => _StateVisualizzaPrenotazioneFutura();
}

class _StateVisualizzaPrenotazioneFutura
    extends State<VisualizzaPrenotazioneFutura> {
  Widget buttonElimina = Text("Elimina", style: TextStyle(color: Colors.red));
  Function onClickElimina;

  @override
  void initState() {
    super.initState();
    print(widget.prenotazione);
    //e' la funzione che viene inserita nel bottone elimina
    //chiama un popup model per chiedere se si vuole eliminare la prenotazione e in caso chiede il motivo
    //successivamente invia una richiesta al server per procedere con l'eliminazione e ritorna la risposta alla pagina precedente
    onClickElimina = () async {
      TextEditingController testoController = TextEditingController();
      //qui viene chiamato il dialog e la schermata rimane in attesa finche' non viene fornita una risposta
      String response = await showDialog<String>(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Column(children: [
              Text("Come mai vuoi eliminare questa prenotazione?"),
              TextField(
                keyboardType: TextInputType.multiline,
                minLines: 3,
                maxLines: null,
                controller: testoController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Inserisci titolo',
                ),
              )
            ], mainAxisSize: MainAxisSize.min),
            actions: <Widget>[
              FlatButton(
                  child: const Text('Elimina'),
                  onPressed: () =>
                      Navigator.pop(context, testoController.text)),
              FlatButton(
                  child: const Text('Annulla'),

                  // Return "No" when dismissed.
                  onPressed: () => Navigator.pop(context, '-1')),
            ],
          );
        },
      );

      //se la risposta e' uguale a -1 signica che e' stato cliccato "Annulla"
      if (response != "-1") {
        //qui si va a sostiuire il testo del bottone con un caricamento
        buttonElimina = Loading(
            indicator: BallPulseIndicator(), size: 40.0, color: Colors.red);
        onClickElimina = null;
        setState(() {});

        //qui si fa partire la richiesta e poi si gestira' il fatto di uscire dalla pagina e di tornare alla precedente
        http.post(Uri.parse(EndPoint.getUrlKey(EndPoint.DEL_PRENOTAZIONE)),
            body: {
              "motivo": response,
              "id_appuntamento": widget.prenotazione["id"].toString()
            }).then((value) {
          print("risposta prenotazione: " + value.body);
          widget.aggiornaPrenotazioni(value.body);
          Navigator.pop(context);
        });
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    Widget card = Material(
        key: Key(Random()
            .nextInt(100000)
            .toString()), //IMPORTANTE, perche' altrimenti visualizzerebbe ancora i widget vecchi, perche' userebbe quelli in cache
        color: Colors.transparent,
        child: Container(
              decoration: BoxDecoration(
                color: Color(0xA9000000),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 7,
                    offset: Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
              margin: EdgeInsets.only(left: 8, right: 8, top: 10),
              padding: EdgeInsets.only(top: 6, bottom: 5),
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                  padding: EdgeInsets.only(bottom: 2),
                  child: Center(
                      child: Text(widget.prenotazione["calendario_nome"],
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          )))),
              Padding(
                padding: EdgeInsets.only(left: 15, right: 15),
                child: Center(
                  child: Text(
                      'Data richiesta: ' +
                          Utility.formatStringDatefromString(
                              "yyyy-MM-dd HH:mm:ss",
                              "dd/MM/yyyy HH:mm",
                              widget.prenotazione["richiesto"]),
                      style: TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                ),
              ),
              Padding(
                padding:
                    EdgeInsets.only(left: 15, right: 15, bottom: 5, top: 10),
                child: Text(widget.prenotazione["calendario_descrizione"],
                      textAlign: TextAlign.justify,
                    style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
                  Padding(
                      padding: EdgeInsets.only(left: 12, right: 12),
                      child: Divider(color: Colors.white30, thickness: 1.5)),
                  Center(
                      child: Container(
                    decoration: BoxDecoration(
                        color: Utility.getColorStateAppuntamento(widget.prenotazione["type"]),
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10))),
                    padding:
                        EdgeInsets.only(top: 5, bottom: 5, left: 20, right: 20),
                    margin: EdgeInsets.only(bottom: 5),
                    child: Text(Utility.getNameStateAppuntamento(widget.prenotazione["type"]),
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  )),
                  Padding(
                    padding: EdgeInsets.only(left: 15, right: 15, bottom: 10),
                    child: Text(widget.prenotazione["message_admin"],
                        style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 15, right: 15, bottom: 5),
                    child: Text(
                        'Data appuntammento: ' +
                            Utility.formatStringDatefromString(
                                "yyyy-MM-dd HH:mm:ss",
                                "dd/MM/yyyy HH:mm",
                                widget.prenotazione["start"]),
                        style: TextStyle(fontSize: 16, color: Colors.white)),
                  )
                ],
              ),
            ));

    List<Widget> listWidget = [
      card,
      /*Text(
          "#" +
              widget.prenotazione["id"].toString() +
              " " +
              widget.prenotazione["calendario_nome"],
          style: TextStyle(fontSize: 30)),
      Text(widget.prenotazione["calendario_descrizione"],
          style: TextStyle(fontSize: 20)),
      Text(widget.prenotazione["start"], style: TextStyle(fontSize: 15)),
      Text(widget.prenotazione["end"], style: TextStyle(fontSize: 15)),
      Text(widget.prenotazione["message"], style: TextStyle(fontSize: 15)),
      Text(widget.prenotazione["message_admin"],
          style: TextStyle(fontSize: 15)),
      Text(widget.prenotazione["type"].toString(),
          style: TextStyle(fontSize: 15)),
      RaisedButton(
          onPressed: () {
            print("Vai alla chat");
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ChatPage(
                      idAppuntamento: widget.prenotazione["id"],
                      indexPrenotazioni: widget.indexPrenotazioni)),
            ).then((value) {
              NotificationSender notificationSender = NotificationSender();
              notificationSender.configureFirebaseNotification();
            });
          },
          child: Text("Vai alla chat")),
      RaisedButton(onPressed: onClickElimina, child: buttonElimina),*/
    ];

    if (widget.prenotazione["steps"] != null) {
      listWidget.add(Steps(json: widget.prenotazione['steps']));
    }

    // TODO Fare in modo che sul bottone della chat sia presente una bolla che segna quanti messaggi non letti ci sono
    // TODO stesso ragionamento da fare per la lista prenotazioni future
    return Model(
        body: ListView(children: listWidget),
        floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.blue,
            child: Icon(
              Icons.chat,
              color: Colors.white,
              size: 30.0,
              semanticLabel: 'Rimuovi filtro',
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ChatPage(
                        idAppuntamento: widget.prenotazione["id"],
                        indexPrenotazioni: widget.indexPrenotazioni)),
              ).then((value) {
                NotificationSender notificationSender = NotificationSender();
                notificationSender.configureFirebaseNotification();
              });
            }));
  }
}
