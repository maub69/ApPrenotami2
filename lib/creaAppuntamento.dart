import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:loading/indicator/ball_pulse_indicator.dart';
import 'package:loading/loading.dart';
import 'package:mia_prima_app/calendario.dart';
import 'package:mia_prima_app/model.dart';
import 'package:mia_prima_app/utility/endpoint.dart';
import 'package:mia_prima_app/utility/utility.dart';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;

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

  String _defaulVolteRicorsivo = "1";
  String _correnteVolteRicorsivo;
  List<String> _volteRicorsivo = [
    "1",
    "2",
    "3",
    "4",
    "5",
    "6",
    "7",
    "8",
    "9",
    "10",
  ];

  @override
  void initState() {
    _correnteVolteRicorsivo = _defaulVolteRicorsivo;
    _onPressedAggiungi = _aggiungiFrase;
  }

  @override
  Widget build(BuildContext context) {
    this.context = context;
    return Model(
      body: ListView(children: [
        Padding(
          padding: EdgeInsets.all(10),
          child: Text(
            "Richiesta prenotazione per il giorno ${widget.disponibilita.from.day} ${widget.disponibilita.from.month} ${widget.disponibilita.from.year} alle ore ${widget.disponibilita.from.hour}:${widget.disponibilita.from.minute}",
            style: TextStyle(fontSize: 25),
          ),
        ),
        Container(
          padding: EdgeInsets.all(10),
          child: TextField(
            keyboardType: TextInputType.multiline,
            minLines: 3,
            maxLines: null,
            controller: testoController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Inserisci titolo',
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.all(10),
          child: DropdownButton<String>(
            value: _correnteVolteRicorsivo,
            iconSize: 24,
            elevation: 16,
            style: TextStyle(color: Colors.deepPurple),
            underline: Container(
              height: 2,
              color: Colors.deepPurpleAccent,
            ),
            onChanged: (String newValue) {
              setState(() {
                _correnteVolteRicorsivo = newValue;
              });
            },
            items:
                _volteRicorsivo.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ),
        Container(
            padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
            child: RaisedButton(
                textColor: Colors.white,
                color: Colors.blue,
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
      "ricorsiva": _correnteVolteRicorsivo,
      "descrizione": testoController.text.trim(),
    }).then((value) {
      print("testo: " + EndPoint.getUrl(EndPoint.CREA_APPUNTAMENTO));
      print("risposta prenotazione: " + value.body);
      Navigator.pop(context);
      Navigator.pop(context);
      Map<String, dynamic> jsonResponse = jsonDecode(value.body);
      widget.disponibilita.showMessage((jsonResponse["response"] == 1)?"Richiesta ricevuta correttamente":"Richiesta non inoltrata", jsonResponse["messagge"], jsonResponse["messagge_admin"], (jsonResponse["response"] == 1)?Colors.green:Colors.red);
    });
  }
}
