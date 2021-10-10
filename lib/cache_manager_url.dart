import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:mia_prima_app/utility/utility.dart';
import 'package:uuid/uuid.dart';

class CacheManagerUrl {
  static CacheManagerUrl _instance;

  final Uuid _uuid = Uuid();

  static CacheManagerUrl get instance {
    if (_instance == null) {
      _instance = new CacheManagerUrl();
    }
    return _instance;
  }

  Future<http.Response> get(Uri request) async {
    http.Response response;
    String uuid = _uuid.v5(Uuid.NAMESPACE_URL, request.toString());
    try {
      response = await http.get(Uri.parse(request.toString()));
      _saveResponse(response.body, uuid);
    } catch (e) {
      response = _readOldResponse(uuid);
    }
    return response;
  }

  String get _pathPages {
    return Utility.pathDownload + "/pages";
  }

  void _saveResponse(String body, String uuid) {
    File file = File(_pathPages + "/" + uuid);
    if (!file.existsSync()) {
      file.create(recursive: true);
    }
    file.writeAsString(body);
  }

  http.Response _readOldResponse(String uuid) {
    File file = File(_pathPages + "/" + uuid);
    if (file.existsSync()) {
      return http.Response(file.readAsStringSync(), 200);
    } else {
      return http.Response("", 503);
    }
  }
}
