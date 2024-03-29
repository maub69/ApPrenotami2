import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:loading/indicator/ball_pulse_indicator.dart';
import 'package:loading/loading.dart';
import 'package:mia_prima_app/utility/request_http.dart';
import '../calendario.dart';
import '../../../global/model.dart';
import 'package:mia_prima_app/utility/endpoint.dart';
import 'package:mia_prima_app/utility/utility.dart';

/// Questa è la pagina che viene aperta quanto si clicca su un item sul calendario e si vuole
/// creare un nuovo appuntamento
class CreaAppuntamento extends StatefulWidget {
  final Disponibilita disponibilita;
  final String idCalendario;

  CreaAppuntamento({this.disponibilita, this.idCalendario});

  @override
  State<StatefulWidget> createState() {
    return _StateCreaAppuntamento();
  }
}

class _StateCreaAppuntamento extends State<CreaAppuntamento> {
  TextEditingController testoController = TextEditingController();
  BuildContext context;
  Widget childAggiungi = Text("Aggiungi");
  Function _onPressedAggiungi;

  @override
  void initState() {
    super.initState();
    _onPressedAggiungi = _richiediAppuntamento;
  }

  @override
  Widget build(BuildContext context) {
    this.context = context;
    return Model(
      body: ListView(children: [
        Padding(
          padding: EdgeInsets.only(top: 30, bottom: 20),
          child: Text(
            "Richiesta prenotazione",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 20, right: 10, left: 10),
          child: Text(
            Utility.getDateStringFromDateTime(
                                widget.disponibilita.from,
                                "Per il giorno dd/MM/yyyy ") + "alle ore " + 
                                Utility.getDateStringFromDateTime(
                                widget.disponibilita.from,
                                "HH:mm"),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20),
          ),
        ),
        widget.disponibilita.hasDurata ? Padding(
          padding: EdgeInsets.only(bottom: 20, right: 10, left: 10),
          child: Text(
            "Durata prevista ${Utility.formattaDurata(widget.disponibilita.from, widget.disponibilita.to)}",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20),
          ),
        ) : Container(),
        Container(
          padding: EdgeInsets.all(10),
          child: TextField(
                style: TextStyle(color: Colors.black),
                keyboardType: TextInputType.multiline,
                minLines: 3,
                maxLines: null,
                cursorColor: Colors.black,
                controller: testoController,
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                  border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15.0)),
                          borderSide: BorderSide(
                            color: Colors.black,
                            width: 1.0,
                            style: BorderStyle.solid,
                          ),
                        ),
                  labelText: 'Inserisci la richiesta',
                  labelStyle: TextStyle(color: Colors.black),
                  
                ),
                
              ),
        ),
        Container(
            padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.green[900],
                  textStyle: TextStyle(color: Colors.white)
                ),
                child: Center(
                  child: childAggiungi,
                ),
                onPressed: _onPressedAggiungi))
      ]),
    );
  }

  /// Invia la richiesta al server per richiedere l'appuntamento e torna alla home
  void _richiediAppuntamento() {
    childAggiungi = Loading(
        indicator: BallPulseIndicator(), size: 40.0, color: Colors.white);
    _onPressedAggiungi = null;
    setState(() {});

    RequestHttp.post(Uri.parse(EndPoint.getUrlKey(EndPoint.INVIO_RICHIESTA_APPUNTAMENTO)), body: {
      "id_calendario": Utility.idCalendarioAperto.toString(),
      "start_time": widget.disponibilita.from.toString(),
      "end_time": widget.disponibilita.to.toString(),
      "descrizione": testoController.text.trim(),
    }).then((value) {
      print("testo: " + EndPoint.getUrl(EndPoint.INVIO_RICHIESTA_APPUNTAMENTO));
      print("risposta prenotazione: " + value.body);
      Navigator.pop(context);
      Navigator.pop(context);
      Map<String, dynamic> jsonResponse = jsonDecode(value.body);
      // la risposta deve contenere response: 0,1; messagge: risposta da visualizzare
      widget.disponibilita.showMessage(
          (jsonResponse["response"] == 1)
              ? "Richiesta ricevuta correttamente"
              : "Richiesta non inoltrata",
          jsonResponse["messagge"],
          "",
          (jsonResponse["response"] == 1) ? Colors.green : Colors.red);
    });
  }
}
