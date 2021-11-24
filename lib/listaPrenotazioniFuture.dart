import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mia_prima_app/list_page.dart';
import 'package:mia_prima_app/model.dart';
import 'package:mia_prima_app/utility/utility.dart';
import 'package:mia_prima_app/visualizzaPrenotazioneFutura.dart';

class ListaPrenotazioniFuture extends StatefulWidget {
  ListaPrenotazioniFuture();

  @override
  State createState() => _StateListaPrenotazioniFuture();
}

class _StateListaPrenotazioniFuture extends State<ListaPrenotazioniFuture> {
  Random _random = new Random();
  List<Widget> _listCard = [];

  @override
  void initState() {
    super.initState();
    _aggiornaListaPrenotazioniFuture();
  }

  //TODO gestire l'evento di quando si clicca fuori dal dialog
  //questa funzione viene chiamata da visualizzaPrenotazioni future e permette di aggiornare la lista modificando il card d'interesse con le nuove informazioni
  void _aggiornaPrenotazione(String body) {
    Map<String, dynamic> _arrayBody = jsonDecode(body);
    _showMessage("Eliminazione appuntamento", _arrayBody["response"]["message"],
        Colors.red);
    for (int i = 0; i < Utility.listaPrenotazioni.length; i++) {
      //una volta trovata la prenotazione interesssata, viene sostituita con le nuove informazioni
      if (Utility.listaPrenotazioni[i]["id"] ==
          _arrayBody["new_element"]["id"]) {
        Utility.listaPrenotazioni[i] = _arrayBody["new_element"];
        break;
      }
    }
    _listCard = []; //ricordiarsi, se no aggiunge
    _aggiornaListaPrenotazioniFuture();
    setState(() {});
  }

  //nei fatti non fa altro che popolare _listCard con i nuovi Widget delle prenotazioni
  void _aggiornaListaPrenotazioniFuture() {
    List<dynamic> listaPrenotazioniNoArchivio = Utility.listaPrenotazioni
        .where((element) => element["type"] != -5)
        .toList();
    for (int i = 0; i < listaPrenotazioniNoArchivio.length; i++) {
      _listCard.add(getWidgetList(listaPrenotazioniNoArchivio[i], () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => VisualizzaPrenotazioneFutura(
                    prenotazione: listaPrenotazioniNoArchivio[i],
                    indexPrenotazioni: i,
                    aggiornaPrenotazioni: _aggiornaPrenotazione)));
      }));
    }
    _listCard.add(Container(height: 20));
  }

  @override
  Widget build(BuildContext context) {
    return Model(
        textAppBar: "Lista appuntamenti",
        actions: [
          // TODO realizzare la schermata di filtro, sostanzialmente viene aperta una scherata dove si spunta quali tipi si vuole vedere e quali no, una volta cliccato filtra torna alla pagina prima e ti filtra i contenuti
          // TODO se ce un filtro applicato compare un'icona tra l'appbar e il primo box nel quale a e' presente una x che serve per cancellare il filtro
          IconButton(
              icon: const Icon(
                Icons.filter_alt_outlined,
                color: Colors.white,
              ),
              tooltip: "Filtra",
              onPressed: () {
                List<dynamic> listaArchiviati = Utility.listaPrenotazioni
                    .where((element) => element["type"] == -5)
                    .toList();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ListPage(
                            title: "Filtra",
                            list: listaArchiviati,
                            print: (element, i) {
                              return getWidgetList(element, () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            VisualizzaPrenotazioneFutura(
                                                prenotazione:
                                                    listaArchiviati[i],
                                                indexPrenotazioni: i,
                                                aggiornaPrenotazioni:
                                                    _aggiornaPrenotazione)));
                              });
                            },
                          )),
                );
              }),
              IconButton(
              icon: const Icon(
                Icons.archive,
                color: Colors.white,
              ),
              tooltip: "Archiviati",
              onPressed: () {
                List<dynamic> listaArchiviati = Utility.listaPrenotazioni
                    .where((element) => element["type"] == -5)
                    .toList();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ListPage(
                            title: "Archiviati",
                            list: listaArchiviati,
                            print: (element, i) {
                              return getWidgetList(element, () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            VisualizzaPrenotazioneFutura(
                                                prenotazione:
                                                    listaArchiviati[i],
                                                indexPrenotazioni: i,
                                                aggiornaPrenotazioni:
                                                    _aggiornaPrenotazione)));
                              });
                            },
                          )),
                );
              })
        ],
        body: new Builder(builder: (BuildContext context) {
          return ListView(children: _listCard);
        }));
  }

  String _getNameStateAppuntamento(int state) {
    switch (state) {
      case 2:
        return "PRENOTATO";
      case 1:
        return "IN ATTESA DI CONFERMA";
      case 0:
        return "DA CONFERMARE";
      case -1:
        return "RIFIUTATO";
      case -2:
        return "IN ATTESA DI CANCELLAZIONE";
      case -3:
        return "CANCELLATO";
      case -4:
        return "CONCLUSO";
      case -5:
        return "ARCHIVIATO";
      default:
        return "";
    }
  }

  // (int)2:prenotato|1:in attesa dell'azienda|0:in attesa del cliente|-1:rifituato|-2:in attesa di cancellazione|-3:cancellato|-4:terminato
  Color _getColorStateAppuntamento(int state) {
    switch (state) {
      case 2:
        return Colors.green[400];
      case 1:
        return Colors.orange[300];
      case 0:
        return Colors.orange[300];
      case -1:
        return Colors.red[400];
      case -2:
        return Colors.orange[300];
      case -3:
        return Colors.red[400];
      case -4:
        return Colors.brown[200];
      case -5:
        return Colors.brown[200];
      default:
        return Colors.white;
    }
  }

  void _showMessage(String title, String body, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
      content: Column(
          children: [
            Text(title, style: TextStyle(fontSize: 20)),
            Text(body, style: TextStyle(fontSize: 15)),
          ],
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start),
      backgroundColor: color,
      duration: Duration(seconds: 10),
    ));
  }

  Widget getWidgetList(dynamic prenotazione, Function onTap) {
    return Material(
        key: Key(_random
            .nextInt(100000)
            .toString()), //IMPORTANTE, perche' altrimenti visualizzerebbe ancora i widget vecchi, perche' userebbe quelli in cache
        color: Colors.transparent,
        child: InkWell(
            onTap: onTap,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.brown[400],
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
                          child: Text(prenotazione["calendario_nome"],
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)))),
                  Padding(
                    padding: EdgeInsets.only(left: 15, right: 15),
                    child: Center(
                      child: Text(
                          'Data richiesta: ' +
                              Utility.formatStringDatefromString(
                                  "yyyy-MM-dd HH:mm:ss",
                                  "dd/MM/yyyy HH:mm",
                                  prenotazione["richiesto"]),
                          style: TextStyle(
                              fontSize: 13,
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                  Padding(
                      padding: EdgeInsets.only(left: 12, right: 12),
                      child: Divider(color: Colors.white30, thickness: 1.5)),
                  Center(
                      child: Container(
                    decoration: BoxDecoration(
                        color: _getColorStateAppuntamento(prenotazione["type"]),
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10))),
                    padding:
                        EdgeInsets.only(top: 5, bottom: 5, left: 20, right: 20),
                    margin: EdgeInsets.only(bottom: 5),
                    child: Text(_getNameStateAppuntamento(prenotazione["type"]),
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  )),
                  Padding(
                    padding: EdgeInsets.only(left: 15, right: 15, bottom: 10),
                    child: Text(prenotazione["message_admin"],
                        style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 15, right: 15, bottom: 5),
                    child: Text(
                        'Data appuntammento: ' +
                            Utility.formatStringDatefromString(
                                "yyyy-MM-dd HH:mm:ss",
                                "dd/MM/yyyy HH:mm",
                                prenotazione["start"]),
                        style: TextStyle(fontSize: 16, color: Colors.white)),
                  )
                ],
              ),
            )));
  }
}
