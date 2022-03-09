import 'package:flutter/material.dart';
import 'package:mia_prima_app/utility/endpoint.dart';
import 'package:pop_bottom_menu/pop_bottom_menu.dart';
import 'package:http/http.dart' as http;

/*
  Azioni:
    - Archiviare: CONCLUSO, RIFIUTATO, CANCELLATO
    - Cancellare: CONCLUSO, RIFIUTATO, CANCELLATO
*/
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
          print("SONO QUI 200");
          http.delete(Uri.parse(EndPoint.getUrlKey(EndPoint.APPUNTAMENTO)),
              body: {"id": prenotazione["id"].toString()});
          delWidget(cardPos, true);
          Navigator.of(context).pop();
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
          print("SONO QUI 201");
          http.post(
              Uri.parse(EndPoint.getUrlKey(EndPoint.ARCHIVIA_APPUNTAMENTO)),
              body: {"id": prenotazione["id"].toString()});
          delWidget(cardPos, false);
          Navigator.of(context).pop();
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
