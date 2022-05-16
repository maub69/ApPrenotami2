import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mia_prima_app/utility/request_http.dart';
import 'package:mia_prima_app/utility/utility.dart';
import 'package:uuid/uuid.dart';

class CacheManagerChat {
  Uuid _uuid = Uuid();
  final String idAppuntamento;

  CacheManagerChat(this.idAppuntamento);

  String idChat(int idAppuntamento, int numMessages) {
    return _uuid.v5(Uuid.NAMESPACE_URL, "$idAppuntamento-$numMessages-${Utility.getRandomString(5)}");
  }

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

  void append(String jsonMessage) {
    print("sono qui 30: $jsonMessage");
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
