import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mia_prima_app/filtra_page.dart';
import 'package:mia_prima_app/list_page.dart';
import 'package:mia_prima_app/model.dart';
import 'package:mia_prima_app/popup_menu_appuntamenti.dart';
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
  List<TypeFiltro> _filtri = [];
  List<dynamic> listaPrenotazioniNoArchivio = [];

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
    _aggiornaListaPrenotazioniFuture();
    setState(() {});
  }

  //nei fatti non fa altro che popolare _listCard con i nuovi Widget delle prenotazioni
  void _aggiornaListaPrenotazioniFuture({List<int> discard}) {
    if (discard == null) {
      discard = [];
    }
    discard.add(-5);

    _listCard = [];
    listaPrenotazioniNoArchivio = Utility.listaPrenotazioni
        .where((element) => discard.indexOf(element["type"]) == -1)
        .toList();
    for (int i = 0; i < listaPrenotazioniNoArchivio.length; i++) {
      _listCard.add(getWidgetList(listaPrenotazioniNoArchivio[i], i, () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => VisualizzaPrenotazioneFutura(
                    prenotazione: listaPrenotazioniNoArchivio[i],
                    aggiornaPrenotazioni: _aggiornaPrenotazione))).then((_) {
                      setState(() {
                        _aggiornaListaPrenotazioniFuture(discard: discard);
                      });
        });
      }));
    }
    _listCard.add(Container(height: 20));
  }

  @override
  Widget build(BuildContext context) {
    return Model(
        textAppBar: "Lista appuntamenti",
        actions: [
          IconButton(
              icon: const Icon(
                Icons.visibility,
                color: Colors.white,
              ),
              tooltip: "Filtra",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => FiltraPage(
                            filtri: _filtri,
                            callback: (filtri) {
                              _filtri = filtri;
                              _aggiornaListaPrenotazioniFuture(
                                  discard:
                                      filtri.map((e) => e.nameInt).toList());
                            },
                          )),
                ).then((value) => setState(() {}));
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
                              return getWidgetList(element, i, () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            VisualizzaPrenotazioneFutura(
                                                prenotazione:
                                                    listaArchiviati[i],
                                                aggiornaPrenotazioni:
                                                    _aggiornaPrenotazione)));
                              });
                            },
                          )),
                );
              })
        ],
        body: new Builder(builder: (BuildContext context) {
          return _listCard.length == 1
              ? Center(
                  child: Text(
                    "Nessun appuntamento da visualizzare",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 25),
                  ),
                )
              : ListView.builder(
                  itemCount: _listCard.length,
                  itemBuilder: (BuildContext context, int index) {
                    return _listCard[index];
                  });
        }),
        floatingActionButton: _filtri.length != 0
            ? FloatingActionButton(
                backgroundColor: Colors.blue,
                child: Icon(
                  Icons.visibility_off,
                  color: Colors.white,
                  size: 30.0,
                  semanticLabel: 'Rimuovi filtro',
                ),
                onPressed: () {
                  setState(() {
                    _filtri.clear();
                    _aggiornaListaPrenotazioniFuture();
                  });
                })
            : null);
  }

  void delWidget(int index, bool isToDelete) {
    setState(() {
      dynamic prenotazioneNoarchivio = listaPrenotazioniNoArchivio[index];
      if (isToDelete) {
        Utility.listaPrenotazioni.remove(prenotazioneNoarchivio);
      } else {
        prenotazioneNoarchivio["type"] = -5;
      }
      setState(() {
        _aggiornaListaPrenotazioniFuture(
            discard: _filtri.map((e) => e.nameInt).toList());
      });
    });
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

  Widget getWidgetList(dynamic prenotazione, int posWidget, Function onTap) {
    Widget card = Material(
        key: Key(_random
            .nextInt(100000)
            .toString()), //IMPORTANTE, perche' altrimenti visualizzerebbe ancora i widget vecchi, perche' userebbe quelli in cache
        color: Colors.transparent,
        child: InkWell(
            onTap: onTap,
            onLongPress: () {
              PopupMenuAppuntamenti.showMenu(
                  context: context,
                  prenotazione: prenotazione,
                  cardPos: posWidget,
                  delWidget: delWidget);
            },
            child: Stack(children: [
              Container(
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
                          color: Utility.getColorStateAppuntamento(
                              prenotazione["type"]),
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                              bottomLeft: Radius.circular(10),
                              bottomRight: Radius.circular(10))),
                      padding: EdgeInsets.only(
                          top: 5, bottom: 5, left: 20, right: 20),
                      margin: EdgeInsets.only(bottom: 5),
                      child: Text(
                          Utility.getNameStateAppuntamento(
                              prenotazione["type"]),
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
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
              ),
              ((prenotazione["msg_non_letti"] != 0)
                  ? Utility.getBoxNotification(prenotazione["msg_non_letti"],
                      right: 21, top: 18)
                  : Container())
            ])));
    return card;
  }
}
