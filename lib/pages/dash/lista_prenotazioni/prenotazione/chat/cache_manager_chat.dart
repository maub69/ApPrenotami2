import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mia_prima_app/utility/request_http.dart';
import 'package:mia_prima_app/utility/utility.dart';
import 'package:uuid/uuid.dart';

/// Classe che gestisce la cache della chat, permette di salvare il body delle risposte delle richieste
/// per leggere una chat, al fine di poter visionare una chat anche in assenza di internet
class CacheManagerChat {
  Uuid _uuid = Uuid();
  final String idAppuntamento;

  CacheManagerChat(this.idAppuntamento);

  /// permette di creare un id identificativo di un messaggio della chat, di qualsiasi tipologia di widget sia
  /// presente all'interno della cartella risposte/widget
  String idChat(int idAppuntamento, int numMessages) {
    return _uuid.v5(Uuid.NAMESPACE_URL, "$idAppuntamento-$numMessages-${Utility.getRandomString(5)}");
  }

  /// ritorna i messaggi di una chat a partire dall'url di richiesta, torna la cache altrimenti
  Future<String> getMessages(Uri urlChat) async {
    try {
      http.Response response = await RequestHttp.get(urlChat);
      save(response.body);
      return response.body;
    } catch (e) {
      return "[" + await File(_pathChat).readAsString() + "]";
    }
  }

  void save(String chatJson) {
    File file = File(_pathChat);
    if (!file.existsSync()) {
      file.create(recursive: true);
    }
    chatJson = chatJson.trim();
    chatJson = chatJson.substring(1, chatJson.length - 1);
    file.writeAsString(chatJson.trim());
  }

  /// per evitare di leggere ogni volta il contenuto di un file per poi fare solo una piccola modifica
  /// all'interno della pagina della chat viene più volte richiamata questa funzione per aggiungere
  /// un messaggio in coda alla chat, questo a livello prestazionale è molto più efficiente
  void append(String jsonMessage) {
    File file = File(_pathChat);
    file.writeAsString("," + jsonMessage, mode: FileMode.append);
  }

  void remove(String idChat) async {
    List<dynamic> json = jsonDecode("[" + await File(_pathChat).readAsString() + "]");
    for (int i=0; i<json.length; i++) {
      if (json[i]["id"] == idChat) {
        json.remove(json[i]);
        save(jsonEncode(json));
        return;
      }
    }
  }

  String get _pathChat {
    return Utility.pathDownload + "/chats/" + idAppuntamento;
  }
}
