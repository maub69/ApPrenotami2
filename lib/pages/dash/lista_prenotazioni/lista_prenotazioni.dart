import 'dart:math';

import 'package:flutter/material.dart';
import 'filtro/filtra_page.dart';
import 'archivio/list_page_archiviati.dart';
import '../../global/model.dart';
import 'popup_menu_appuntamenti.dart';
import 'package:mia_prima_app/utility/utility.dart';
import 'prenotazione/visualizza_prenotazione.dart';

class ListaPrenotazioni extends StatefulWidget {
  ListaPrenotazioni();

  @override
  State createState() => _StateListaPrenotazioni();
}

class _StateListaPrenotazioni extends State<ListaPrenotazioni> {
  Random _random = new Random();
  List<Widget> _listCard = [];
  List<TypeFiltro> _filtri = [];
  List<dynamic> listaPrenotazioniNoArchivio = [];

  @override
  void initState() {
    super.initState();
    _aggiornaListaPrenotazioni();
  }

  /// si tratta della funzione che popola _listCard, cioè la lista che contiene i widget che vengono visualizzati
  /// riceve in ingresso la lista dei filtri della tipologia di appuntamenti che devono essere scartati
  /// non riceve una lista di filtri, ma solo l'intero che li rappresenta, cioè l'id della tipologia
  void _aggiornaListaPrenotazioni({List<int> discard}) {
    if (discard == null) {
      discard = [];
    }
    /// l'id 5 rappresenta gli archiviati, che devono sempre essere scartati dalla visualizzazione principale
    discard.add(-5);

    _listCard = [];

    /// crea la lista degli appuntamenti che non devono essere visualizzati
    /// cioè conserva solo quelli che hanno la tipologia che non è stata trovata nella lista dei filtri
    listaPrenotazioniNoArchivio = Utility.listaPrenotazioni
        .where((element) => discard.indexOf(element["type"]) == -1)
        .toList();
    /// vengono effettivamente realizzati i widget per visualizzare gli appuntamenti
    for (int i = 0; i < listaPrenotazioniNoArchivio.length; i++) {
      _listCard.add(getWidgetList(listaPrenotazioniNoArchivio[i], i, () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => VisualizzaPrenotazione(
                    prenotazione: listaPrenotazioniNoArchivio[i],
                    cardPos: i,
                    delWidget: delWidget))).then((_) {
          setState(() {
            /// è presente l'aggiornamento nel caso in cui si torni indietro fino a questa pagina
            /// perchè dopo aver visualizzato un appuntamento le informazioni di quest'ultimo potrebbero essere cambiate
            _aggiornaListaPrenotazioni(discard: discard);
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
                      /// rappresenta l'azione che viene fatta quando si clicca sul bottone filtra
                      /// qua viene scritta la funzione di callback che poi viene eseguita dalla pagina dei filtri
                      /// si può vedere che viene eseguito _aggiornaListaPrenotazioni nel quale la lista 
                      /// dei filtri viene trasformata in una lista di interi
                      builder: (context) => FiltraPage(
                            filtri: _filtri,
                            callback: (filtri) {
                              _filtri = filtri;
                              _aggiornaListaPrenotazioni(
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
                    /// crea la pagina per visualizzare gli archiviati
                    /// usa un oggetto che permette di creare velocemente una visualizzazione
                    /// di widget passando gli oggetti da convertire e la funzione
                    /// da applicare per creare il widget, in questo caso getWidgetList
                    builder: (context) => ListPage(
                      title: "Archiviati",
                      list: listaArchiviati,
                      getWidget: getWidgetList,
                    ),
                  ),
                ).then((value) {
                  setState(() {
                    _aggiornaListaPrenotazioni(
                        discard: _filtri.map((e) => e.nameInt).toList());
                  });
                });
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
                    _aggiornaListaPrenotazioni();
                  });
                })
            : null);
  }

  /// questa funzione viene passata in ingresso ad ogni visualizzazione della prenotazione
  /// se una prenotazione venisse eliminata dalla sezione apposita, allora verrà richiamata
  /// anche questa funzione, al fine di eliminare la prenotazione dalla lista delle prenotazioni
  void delWidget(int index, bool isToDelete) {
    setState(() {
      dynamic prenotazioneNoArchivio = listaPrenotazioniNoArchivio[index];
      if (isToDelete) {
        Utility.listaPrenotazioni.remove(prenotazioneNoArchivio);
      } else {
        prenotazioneNoArchivio["prev_type"] = prenotazioneNoArchivio["type"];
        prenotazioneNoArchivio["type"] = -5;
      }
      setState(() {
        _aggiornaListaPrenotazioni(
            discard: _filtri.map((e) => e.nameInt).toList());
      });
    });
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
                prenotazione['type'] == -2 ? Padding(
                  padding: EdgeInsets.only(top: 5, left: 15, right: 15),
                  child: Center(
                    child: Text(
                        'Richiesta cancellazione: ' +
                            Utility.formatStringDatefromString(
                                "yyyy-MM-dd HH:mm:ss",
                                "dd/MM/yyyy HH:mm",
                                prenotazione["richiesto_cancellazione"]),
                        style: TextStyle(
                            fontSize: 13,
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                  ),
                ) : Container(),
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
                  padding:
                      EdgeInsets.only(top: 5, bottom: 5, left: 20, right: 20),
                  margin: EdgeInsets.only(bottom: 5),
                  child: Text(
                      Utility.getNameStateAppuntamento(prenotazione["type"]),
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
          ),
          ((prenotazione["msg_non_letti"] != 0)
              ? Utility.getBoxNotification(prenotazione["msg_non_letti"],
                  right: 21, top: 18)
              : Container())
        ]),
      ),
    );
    return card;
  }
}
