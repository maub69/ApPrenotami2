import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mia_prima_app/utility/endpoint.dart';

//TODO terminata la parte di downloadChatNonLette per quanto riguarda il primo avvio, ma ora bisogna gestire la casistica di quando l'app viene messa in pausa nel task manager e di quando l'app e aperta e arrivano le notifiche
/*
  Questa classe permette di conoscere quali chat non sono ancora state lette e offre varie funzioni per maneggiare la lista delle chat non lette
*/
class MessagesManager {
  static bool isNotChat = true;
  static int idChat = -1;
  static List<int> _listChatNonLette = [];

  static bool haveChatNotRead() {
    return !_listChatNonLette.isEmpty;
  }

  static List<int> listChatNotRead() {
    return _listChatNonLette;
  }

  static bool hasAppuntamentoChatNotRead(int idAppuntamento) {
    return _listChatNonLette.contains(idAppuntamento);
  }

  static downloadChatNonLette() async {
    http.get(Uri.parse(EndPoint.getUrlKey(EndPoint.GET_CHAT_NON_LETTE))).then((value) {
      _listChatNonLette = [];
      List<dynamic> list = jsonDecode(value.body);
      list.forEach((element) {
        _listChatNonLette.add(element);
      });
      print("messaggesManager $_listChatNonLette");
    });
  }

  /*
    Questa e' necessaria per la casistica nel quale l'app e aperta e bisogna modificare la lista
  */
  static removeChat(int idAppuntamento) {
    _listChatNonLette.remove(idAppuntamento);
    print("messaggesManager $_listChatNonLette");
  }

  /*
    Questa e' necessaria per la casistica nel quale l'app e aperta e bisogna modificare la lista
  */
  static addChat(int idAppuntamento) {
    if (!_listChatNonLette.contains(idAppuntamento)) {
      _listChatNonLette.add(idAppuntamento);
    }
    print("messaggesManager $_listChatNonLette");
  }
}