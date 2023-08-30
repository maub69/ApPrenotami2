import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mia_prima_app/utility/endpoint.dart';
import 'package:mia_prima_app/utility/pop_bottom_menu.dart';
import 'package:mia_prima_app/utility/request_http.dart';
import 'package:http/http.dart' as http;

/*
  Azioni:
    - Archiviare: CONCLUSO, RIFIUTATO, CANCELLATO
    - Cancellare: CONCLUSO, RIFIUTATO, CANCELLATO
*/
/// corrisponde alla classe usata per gestire il popup che viene aperto quando si vuole
/// cancellare o archiviare un appuntamento direttamente dalla lista di tutte le prenotazioni
class PopupMenuAppuntamenti {
  static void showMenu(
      {@required BuildContext context,
      dynamic prenotazione,
      int cardPos,
      Function(int, bool) delWidget}) {
    List<ItemPopBottomMenu> items = [];
    bool hasCommands = false;

    // CANCELLA
    if (prenotazione["type"] == -4 ||
        prenotazione["type"] == -1 ||
        prenotazione["type"] == -3) {
      hasCommands = true;
      items.add(ItemPopBottomMenu(
        onPressed: () {
          http.post(Uri.parse(EndPoint.getUrlKey(EndPoint.CANCELLA_APPUNTAMENTO)),
              headers: {
                "Content-Type": "application/json",
                "Accept": "*/*"
              },
              body: jsonEncode({"id": prenotazione["id"].toString()})).then((value) {
                if (value.statusCode == 200) {
                  delWidget(cardPos, true);
                  Navigator.of(context).pop();
                } else {
                  FlutterToast.showToast(
                      msg: "Comando momentaneamente non eseguibile",
                      toastLength: Toast.LENGTH_LONG,
                      gravity: ToastGravity.BOTTOM,
                      backgroundColor: Color(0xFF616161),
                      textColor: Colors.white,
                      fontSize: 16.0);
                  Navigator.of(context).pop();
                }
          });
        },
        label: "CANCELLA",
      ));
    }

    // ARCHIVIA
    if (prenotazione["type"] == -4 ||
        prenotazione["type"] == -1 ||
        prenotazione["type"] == -3) {
      hasCommands = true;
      items.add(ItemPopBottomMenu(
        onPressed: () {
          http.post(
              Uri.parse(EndPoint.getUrlKey(EndPoint.ARCHIVIA_APPUNTAMENTO)),
              headers: {
                "Content-Type": "application/json",
                "Accept": "*/*"
              },
              body: jsonEncode({"id": prenotazione["id"].toString()})).then((value) {
                // cancella l'elemento anche visivamente solo se la richiesta è andata effettivamente in successo
                if (value.statusCode == 200) {
                  delWidget(cardPos, false);
                  Navigator.of(context).pop();
                } else {
                  FlutterToast.showToast(
                      msg: "Comando momentaneamente non eseguibile",
                      toastLength: Toast.LENGTH_LONG,
                      gravity: ToastGravity.BOTTOM,
                      backgroundColor: Color(0xFF616161),
                      textColor: Colors.white,
                      fontSize: 16.0);
                  Navigator.of(context).pop();
                }
          });
        },
        label: "ARCHIVIA",
      ));
    }

    if (hasCommands) {
      showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (context) {
          return PopBottomMenu(
            title: TitlePopBottomMenu(
              label: "Opzioni",
            ),
            items: items,
          );
        },
      );
    }
  }
}
