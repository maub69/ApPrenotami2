import 'dart:math';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:loading/indicator/ball_pulse_indicator.dart';
import 'package:loading/loading.dart';
import 'package:mia_prima_app/chatpage.dart';
import 'package:mia_prima_app/main.dart';
import 'package:mia_prima_app/model.dart';
import 'package:http/http.dart' as http;
import 'package:mia_prima_app/notificationSender.dart';
import 'package:mia_prima_app/steps.dart';
import 'package:mia_prima_app/utility/endpoint.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    as nt;

class VisualizzaPrenotazioneFutura extends StatefulWidget {
  final dynamic prenotazione;
  final Function aggiornaPrenotazioni;

  VisualizzaPrenotazioneFutura({this.prenotazione, this.aggiornaPrenotazioni});

  @override
  State createState() => _StateVisualizzaPrenotazioneFutura();
}

class _StateVisualizzaPrenotazioneFutura
    extends State<VisualizzaPrenotazioneFutura> {
  Widget buttonElimina = Text("Elimina", style: TextStyle(color: Colors.red));
  Function onClickElimina;

  @override
  void initState() {
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
        http.post(Uri.parse(EndPoint.getUrlKey(EndPoint.DEL_PRENOTAZIONE)), body: {
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
    List<Widget> listWidget = [
      Text(
          "#" +
              widget.prenotazione["id"].toString() +
              " " +
              widget.prenotazione["calendario_nome"],
          style: TextStyle(fontSize: 30)),
      Text(widget.prenotazione["calendarion_descrizione"],
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
                  builder: (context) =>
                      ChatPage(idAppuntamento: widget.prenotazione["id"])),
            ).then((value) {
              NotificationSender notificationSender = NotificationSender();
              notificationSender.configureFirebaseNotification();
            });
          },
          child: Text("Vai alla chat")),
      RaisedButton(onPressed: onClickElimina, child: buttonElimina),
    ];

    if (widget.prenotazione["steps"] != null) {
      listWidget.add(Steps(json: widget.prenotazione['steps']));
    }

    return Model(
      body: ListView(children: listWidget),
    );
  }
}
