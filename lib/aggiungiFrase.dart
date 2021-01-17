import 'package:flutter/material.dart';
import 'package:mia_prima_app/model.dart';
import 'package:mia_prima_app/utility/utility.dart';

class AggiungiFrase extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _StateAggiungifrase();
  }
}

class _StateAggiungifrase extends State<AggiungiFrase> {
  TextEditingController titoloController = TextEditingController();
  TextEditingController testoController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Model(
      body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
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

  void _aggiungiFrase()
  {
    Utility.databaseHelper.insertIntoDati(
                      titolo: titoloController.text.trim(),
                      testo: testoController.text.trim(),
                      date: DateTime.now().toUtc().millisecondsSinceEpoch);
                  Navigator.pop(context);
  }
}
