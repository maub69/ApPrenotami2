import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:loading/indicator/ball_pulse_indicator.dart';
import 'package:loading/loading.dart';
import '../calendario.dart';
import '../../../global/model.dart';
import 'package:mia_prima_app/utility/endpoint.dart';
import 'package:http/http.dart' as http;
import 'package:mia_prima_app/utility/utility.dart';

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
    _onPressedAggiungi = _aggiungiFrase;
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

  void _aggiungiFrase() {
    // iserire controllo quantita'

    childAggiungi = Loading(
        indicator: BallPulseIndicator(), size: 40.0, color: Colors.white);
    _onPressedAggiungi = null;
    setState(() {});

    http.post(Uri.parse(EndPoint.getUrlKey(EndPoint.CREA_APPUNTAMENTO)), body: {
      "id_calendario": widget.idCalendario,
      "start_time": widget.disponibilita.from.toString(),
      "end_time": widget.disponibilita.to.toString(),
      "descrizione": testoController.text.trim(),
    }).then((value) {
      print("testo: " + EndPoint.getUrl(EndPoint.CREA_APPUNTAMENTO));
      print("risposta prenotazione: " + value.body);
      Navigator.pop(context);
      Navigator.pop(context);
      Map<String, dynamic> jsonResponse = jsonDecode(value.body);
      widget.disponibilita.showMessage(
          (jsonResponse["response"] == 1)
              ? "Richiesta ricevuta correttamente"
              : "Richiesta non inoltrata",
          jsonResponse["messagge"],
          jsonResponse["messagge_admin"],
          (jsonResponse["response"] == 1) ? Colors.green : Colors.red);
    });
  }
}
