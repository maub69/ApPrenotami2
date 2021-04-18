import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mia_prima_app/main.dart';
import 'package:mia_prima_app/model.dart';
import 'package:mia_prima_app/visualizzaPrenotazioneFutura.dart';

class ListaPrenotazioniFuture extends StatefulWidget {
  final List<dynamic> prenotazioni;

  ListaPrenotazioniFuture({this.prenotazioni});

  @override
  State createState() => _StateListaPrenotazioniFuture();
}

class _StateListaPrenotazioniFuture extends State<ListaPrenotazioniFuture> {
  Random _random = new Random();
  List<Widget> _listCard = [];
  List<dynamic> _listPrenotazioni = [];
  BuildContext _context;

  @override
  void initState() {
    _listPrenotazioni = widget.prenotazioni;
    _aggiornaListaPrenotazioniFuture();
  }

  //TODO gestire l'evento di quando si clicca fuori dal dialog
  //questa funzione viene chiamata da visualizzaPrenotazioni future e permette di aggiornare la lista modificando il card d'interesse con le nuove informazioni
  void _aggiornaPrenotazione(String body) {
    Map<String, dynamic> _arrayBody = jsonDecode(body);
    _showMessage("Eliminazione appuntamento", _arrayBody["response"]["message"],
        Colors.red);
    for (int i = 0; i < _listPrenotazioni.length; i++) {
      //una volta trovata la prenotazione interesssata, viene sostituita con le nuove informazioni
      if (_listPrenotazioni[i]["id"] == _arrayBody["new_element"]["id"]) {
        _listPrenotazioni[i] = _arrayBody["new_element"];
        break;
      }
    }
    _listCard = []; //ricordiarsi, se no aggiunge
    _aggiornaListaPrenotazioniFuture();
    setState(() {});
  }

  //nei fatti non fa altro che popolare _listCard con i nuovi Widget delle prenotazioni
  void _aggiornaListaPrenotazioniFuture() {
    for (int i = 0; i < _listPrenotazioni.length; i++) {
      _listCard.add(Material(
          key: Key(_random
              .nextInt(100000)
              .toString()), //IMPORTANTE, perche' altrimenti visualizzerebbe ancora i widget vecchi, perche' userebbe quelli in cache
          color: Colors.transparent,
          child: InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) =>
                            VisualizzaPrenotazioneFutura(
                                prenotazione: _listPrenotazioni[i],
                                aggiornaPrenotazioni: _aggiornaPrenotazione)));
              },
              child: Card(
                  color: Colors.transparent,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      ListTile(
                        leading: _getIconFromType(_listPrenotazioni[i]["type"]),
                        title: Text(_listPrenotazioni[i]["calendario_nome"]),
                        subtitle: Text(_listPrenotazioni[i]["message_admin"]),
                      ),
                    ],
                  )))));
    }
  }

  Icon _getIconFromType(int type) {
    switch (type) {
      case 2:
        return Icon(Icons.assignment_turned_in);
      case 1:
        return Icon(Icons.access_time);
      case 0:
        return Icon(Icons.block);
      case -1:
        return Icon(Icons.alarm_off);
      case -2:
        return Icon(Icons.cancel);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Model(body: new Builder(builder: (BuildContext context) {
      _context = context;
      return ListView(children: _listCard);
    }));
  }

  void _showMessage(String title, String body, Color color) {
    Scaffold.of(_context).showSnackBar(new SnackBar(
      content: Column(
          children: [
            Text(title, style: TextStyle(fontSize: 20)),
            Text(body, style: TextStyle(fontSize: 15))
          ],
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start),
      backgroundColor: color,
      duration: Duration(seconds: 10),
    ));
  }
}
