import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:mia_prima_app/utility/cache_manager_url.dart';
import 'package:mia_prima_app/utility/utility.dart';
import 'package:uuid/uuid.dart';

/// ATTENZIONE: e' necessario che tutti i body passati alle richieste siano in stringe
/// sotto forma di json, inoltre necessita di avere gli header valorizzati come sotto, questo
/// perche' il web server flask altrimenti rigetta la richiesta

/// per gestire la situazione in cui il server per un qualsiasi motivo non è raggiungibile
/// è stata creata questa classe contenente le funzioni get e post da usare esattamente come
/// si usano quelle nella classe http, ma con la differenza che in caso di assenza di internet
/// la risposta viene presa dalla cache
class RequestHttp {
  static Future<http.Response> post(Uri url,
      {Map<String, String> headers, dynamic body, Encoding encoding}) async {
    if (headers == null) {
      headers = {};
    }
    headers["Content-Type"] = "application/json";
    headers["Accept"] = "*/*";
    String textBody = jsonEncode(body);
    String uuid = CacheManagerUrl.instance.uuid
        .v5(Uuid.NAMESPACE_URL, "POST:" + url.toString());
    try {
      Response response = await http
          .post(url, headers: headers, body: textBody, encoding: encoding)
          .timeout(Duration(seconds: 10));
      if(response.statusCode >= 500) {
        throw HttpException('${response.statusCode}');
      }
      CacheManagerUrl.instance.saveResponse(response.body, uuid);
      return response;
    } catch (e) {
      if (Utility.hasInternet) {
        Utility.callConnessioneServerAssente();
      }
      return CacheManagerUrl.instance.readOldResponse(uuid);
    }
  }

  static Future<http.Response> get(Uri url,
      {Map<String, String> headers}) async {
    if (headers == null) {
      headers = {};
    }
    headers["Content-Type"] = "application/json";
    headers["Accept"] = "*/*";
    String uuid = CacheManagerUrl.instance.uuid
        .v5(Uuid.NAMESPACE_URL, "GET:" + url.toString());
    try {
      Response response =
          await http.get(url, headers: headers).timeout(Duration(seconds: 10));
      CacheManagerUrl.instance.saveResponse(response.body, uuid);
      if(response.statusCode >= 500) {
        throw HttpException('${response.statusCode}');
      }
      return response;
    } catch (e) {
      if (Utility.hasInternet) {
        Utility.callConnessioneServerAssente();
      }
      return CacheManagerUrl.instance.readOldResponse(uuid);
    }
  }

  static Future<http.Response> delete(Uri url,
      {Map<String, String> headers, Object body, Encoding encoding}) async {
    if (headers == null) {
      headers = {};
    }
    headers["Content-Type"] = "application/json";
    headers["Accept"] = "*/*";
    String textBody = jsonEncode(body);
    String uuid = CacheManagerUrl.instance.uuid
        .v5(Uuid.NAMESPACE_URL, "DELETE:" + url.toString());
    try {
      Response response = await http
          .delete(url, headers: headers, body: textBody, encoding: encoding)
          .timeout(Duration(seconds: 10));
      if(response.statusCode >= 500) {
        throw HttpException('${response.statusCode}');
      }
      CacheManagerUrl.instance.saveResponse(response.body, uuid);
      return response;
    } catch (e) {
      if (Utility.hasInternet) {
        Utility.callConnessioneServerAssente();
      }
      return CacheManagerUrl.instance.readOldResponse(uuid);
    }
  }
}
