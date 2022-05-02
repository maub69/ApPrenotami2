import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:http/http.dart';
import 'package:mia_prima_app/utility/utility.dart';

// TODO notificare all'utente quando l'app non riesce a collegarsi al server
// TODO con queste due funzioni vado a sostituire tutte le occorrenze di get e post al fine gestire la callConnessioneServerAssente
// TODO questa operazione e' la prossima cosa da fare
class RequestHttp {
  static Future<void> post(Uri url,
      {Map<String, String> headers,
      Object body,
      Encoding encoding,
      Function then}) async {
    Response response =
        await http.post(url, headers: headers, body: body, encoding: encoding);
    if (response.statusCode == 503) {
      Utility.callConnessioneServerAssente();
    } else {
      then(response);
    }
  }

  static Future<void> get(Uri url,
      {Map<String, String> headers, Function then}) async {
    Response response = await http.get(url, headers: headers);
    if (response.statusCode == 503) {
      Utility.callConnessioneServerAssente();
    } else {
      then(response);
    }
  }
}
