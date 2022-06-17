import 'package:alert/alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mia_prima_app/utility/endpoint.dart';
import 'package:mia_prima_app/utility/request_http.dart';
import 'package:mia_prima_app/utility/utility.dart';
import 'package:pop_bottom_menu/pop_bottom_menu.dart';
import 'package:mia_prima_app/pages/dash/lista_prenotazioni/prenotazione/chat/cache_manager_chat.dart';

/// questa classe si occupa di gestire il popup che si presenta quando si tiene premuto
/// un messaggio, in particolare può permettere di copiarne il contenuto e eliminare il messaggio
class PopupMenuChat {
    /// la lista dei widget è necessaria per poter eliminare effettivamente un widget dalla lista
    /// dei widget della chat
    static List<Widget> listWidget;

    /// viene passata in ingresso da chatPage per aggiornare la pagina dopo che è stato
    /// eliminato un messaggio
    static Function updateView;

    /// necessario in quanto dopo che è stato eliminato un messaggio dalla vista
    /// è necessario che questo venga anche eliminato dalla cache
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

    /// solo l'amministratore di un messaggio può eliminarlo, inoltre si può vedere
    /// che viene anche effettuata la richiesta web per eliminare il messaggio dal server
    if (isAmministratore) {
      items.add(ItemPopBottomMenu(
        onPressed: () {
          if (Utility.hasInternet) {
            print("elimina_messaggio: $idChat");
            RequestHttp.delete(Uri.parse(EndPoint.getUrlKey(EndPoint.MESSAGGIO_CHAT)),
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