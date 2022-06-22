import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mia_prima_app/utility/utility.dart';
import 'package:uuid/uuid.dart';

/// classe di supporto a request_http, nell'altra classe sono presenti le funzioni che vengono
/// effettivamente usate per fare le richieste rest, mentre qi è presente la logica vera e  propria
/// che salva le risposte in cache
class CacheManagerUrl {
  static CacheManagerUrl _instance;

  final Uuid _uuid = Uuid();

  static CacheManagerUrl get instance {
    if (_instance == null) {
      _instance = new CacheManagerUrl();
    }
    return _instance;
  }

  Uuid get uuid => _uuid;

  Future<http.Response> get(Uri request) async {
    http.Response response;
    String uuid = _uuid.v5(Uuid.NAMESPACE_URL, request.toString());
    try {
      response = await http.get(Uri.parse(request.toString())).timeout(Duration(seconds: 10));
      if(response.statusCode >= 500) {
        throw HttpException('${response.statusCode}');
      }
      saveResponse(response.body, uuid);
    } catch (e) {
      if (Utility.hasInternet) {
        Utility.callConnessioneServerAssente();
      }
      response = readOldResponse(uuid);
    }
    return response;
  }

  String get _pathPages {
    return Utility.pathDownload + "/pages";
  }

  void saveResponse(String body, String uuid) {
    File file = File(_pathPages + "/" + uuid);
    if (!file.existsSync()) {
      file.create(recursive: true);
    }
    file.writeAsString(body);
  }

  http.Response readOldResponse(String uuid) {
    File file = File(_pathPages + "/" + uuid);
    if (file.existsSync()) {
      return http.Response(file.readAsStringSync(), 200);
    } else {
      return http.Response("", 503);
    }
  }
}
