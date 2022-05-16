import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:mia_prima_app/utility/cache_manager_url.dart';
import 'package:mia_prima_app/utility/utility.dart';
import 'package:uuid/uuid.dart';


class RequestHttp {
  static Future<http.Response> post(Uri url,
      {Map<String, String> headers, Object body, Encoding encoding}) async {
    String uuid = CacheManagerUrl.instance.uuid
        .v5(Uuid.NAMESPACE_URL, "POST:" + url.toString());
    try {
      Response response = await http
          .post(url, headers: headers, body: body, encoding: encoding)
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
    String uuid = CacheManagerUrl.instance.uuid
        .v5(Uuid.NAMESPACE_URL, "DELETE:" + url.toString());
    try {
      Response response = await http
          .delete(url, headers: headers, body: body, encoding: encoding)
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
