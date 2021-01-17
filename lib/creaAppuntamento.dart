import 'package:flutter/material.dart';
import 'package:mia_prima_app/calendario.dart';
import 'package:mia_prima_app/model.dart';
import 'package:mia_prima_app/utility/utility.dart';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;

class CreaAppuntamento extends StatefulWidget {
  final Meeting meeting;

  CreaAppuntamento({this.meeting});

  @override
  State<StatefulWidget> createState() {
    return _StateCreaAppuntamento();
  }
}

class _StateCreaAppuntamento extends State<CreaAppuntamento> {
  TextEditingController titoloController = TextEditingController();
  TextEditingController testoController = TextEditingController();
  BuildContext context;

  @override
  Widget build(BuildContext context) {
    this.context = context;
    return Model(
      body: ListView(children: [
        Padding(
          padding: EdgeInsets.all(10),
          child: Text(
            "Richiesta prenotazione per il giorno ${widget.meeting.from.day} ${widget.meeting.from.month} ${widget.meeting.from.year} alle ore ${widget.meeting.from.hour}:${widget.meeting.from.minute}",
            style: TextStyle(fontSize: 25),
          ),
        ),
        Container(
          padding: EdgeInsets.all(10),
          child: TextField(
            controller: titoloController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Inserisci titolo',
            ),
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
            padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
            child: RaisedButton(
                textColor: Colors.white,
                color: Colors.blue,
                child: Text('Aggiungi'),
                onPressed: _aggiungiFrase))
      ]),
    );
  }

  void _aggiungiFrase() {
    // iserire controllo quantita'

    http.post("https://prenotamionline.000webhostapp.com/insert.php",
        body: {
          "inizio": widget.meeting.from.toString(),
          "fine": widget.meeting.from.toString(),
          "ricorsivo": "0",
          "quantita": "0",
          "testo": testoController.text.trim(),
          "titolo": titoloController.text.trim()
        }
    );
    Navigator.pop(context);
  }
}
