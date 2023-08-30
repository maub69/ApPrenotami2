import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mia_prima_app/utility/utility.dart';
import '../../../global/model.dart';
import '../prenotazione/visualizza_prenotazione.dart';

class ListPage extends StatefulWidget {
  final String title;
  final List<dynamic> list;
  final Function getWidget;

  const ListPage({Key key, this.title, this.list, this.getWidget})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ListPageState();
  }
}

class _ListPageState extends State<ListPage> {
  List<dynamic> listNew;
  Widget _body = Container();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (listNew == null) {
      listNew = widget.list
          .where((element) => element["type"] == -5)
          .toList();
    }
    setBody();
    return _body;
  }

  void setBody() {
    _body = Model(
      textAppBar: widget.title,
      body: ListView.builder(
          itemCount: listNew.length + 1,
          itemBuilder: (context, i) {
            if (i == listNew.length) {
              return Container(height: 20);
            } else {
              return widget.getWidget(listNew[i], i, () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) =>
                            VisualizzaPrenotazione(
                                prenotazione: listNew[i],
                                cardPos: i,
                                delWidget: delWidget))).then((value) {
                });
              });
            }
          }),
    );
  }

  // funzione diversa rispetto a quella in listaPrenotazioni, perchè in questo caso va eliminato il widget dalla schermata archivio e non da lista_prenotazioni
  // elimina sia dal listNew temporaneo che da quello globale
  void delWidget(int index, bool isToDelete) {
    // nel primo caso deve solo toglierlo dalla lista delle prenotazioni
    // nel secondo invece deve torglierlo dalla lista prelle prenotazoni locali e cambiare lo stato nelle prenotazioni globali
    // così da farlo vedere nuovamente
    setState(() {
      if (isToDelete) {
        dynamic prenotazioneNoArchivio = listNew[index];
        Utility.listaPrenotazioni.remove(prenotazioneNoArchivio);
        listNew.remove(prenotazioneNoArchivio);
      } else {
        dynamic prenotazioneNoArchivio = listNew[index];
        listNew.remove(prenotazioneNoArchivio);
        Utility.listaPrenotazioni.remove(prenotazioneNoArchivio);
        prenotazioneNoArchivio["type"] = prenotazioneNoArchivio["prev_type"];
        Utility.listaPrenotazioni.add(prenotazioneNoArchivio);
      }
    });
  }
}
