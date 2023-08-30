import 'dart:convert';
import 'package:mia_prima_app/utility/utility.dart';
import 'cache_manager_url.dart';
import 'package:mia_prima_app/utility/endpoint.dart';

/// Questa classe permette di conoscere quali chat non sono ancora state lette
/// e offre varie funzioni per maneggiare la lista delle chat non lette
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
    CacheManagerUrl.instance
        .get(Uri.parse(EndPoint.getUrlKey(EndPoint.GET_CHAT_NON_LETTE)))
        .then((value) {
      _listChatNonLette = [];
      if (value.statusCode != 503) {
        print("body: ${value.body}");
        // TODO ATTENZIONE! Verificare se tutta questa gestione delle chat non lette serve o è già stata sostituita da altri componenti
        // TODO capire come dare l'elenco delle chat non lette, nel senso di creare l'api e fare anche l'api per leggere tutti i messaggi non letti
        List<dynamic> list = jsonDecode(value.body);
        list.forEach((element) {
          _listChatNonLette.add(element);
        });
      } else {
        Utility.callConnessioneServerAssente();
      }
    });
  }

  /// rimuove la chat da lista delle chat non lette una volta che viene letta
  static removeChat(int idAppuntamento) {
    _listChatNonLette.remove(idAppuntamento);
  }

  ///  aggiunge una chat alla lista delle chat non lette sono se non è già presente
  /// al suo interno
  static addChat(int idAppuntamento) {
    if (!_listChatNonLette.contains(idAppuntamento)) {
      _listChatNonLette.add(idAppuntamento);
    }
  }
}
