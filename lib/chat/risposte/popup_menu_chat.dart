import 'package:alert/alert.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mia_prima_app/utility/endpoint.dart';
import 'package:mia_prima_app/utility/utility.dart';
import 'package:pop_bottom_menu/pop_bottom_menu.dart';
import 'package:http/http.dart' as http;

import '../../cache_manager_chat.dart';

class PopupMenuChat {
    static List<Widget> listWidget;

    static Function updateView;

    static CacheManagerChat cacheManagerChat;

    static void showMenu({
      @required BuildContext context,
      @required bool isAmministratore,
      @required bool isChat,
      @required Widget widget,
      String text = "",
      String idChat}) {
    if (!isAmministratore && !isChat) {
      return;
    }

    List<ItemPopBottomMenu> items = [];

    if (isChat) {
      items.add(ItemPopBottomMenu(
        onPressed: () {
          print("copia");
          Clipboard.setData(ClipboardData(text: text));
          Navigator.of(context).pop();
        },
        label: "Copia",
      ));
    }

    if (isAmministratore) {
      items.add(ItemPopBottomMenu(
        onPressed: () {
          if (Utility.hasInternet) {
            print("elimina_messaggio: $idChat");
            http.delete(Uri.parse(EndPoint.getUrlKey(EndPoint.MESSAGGIO_CHAT)),
              body: {"id": idChat});
            listWidget.remove(widget);
            cacheManagerChat.remove(idChat);
            updateView();
          } else {
            Alert(message: 'Internet assente, non puoi eliminare un messaggio').show();
          }
          Navigator.of(context).pop();
        },
        label: "Elimina per te e per gli altri",
      ));
    }

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