//import 'package:sqflite/sqflite.dart';
import 'dart:convert';
import 'dart:math';

import 'package:mia_prima_app/calendario.dart';
import 'package:mia_prima_app/utility/convertSettimanaInCalendario.dart';
import 'package:mia_prima_app/utility/databaseHelper.dart';
import 'package:mia_prima_app/utility/downloadJson.dart';
import 'package:mia_prima_app/utility/endpoint.dart';
import 'package:mia_prima_app/utility/utente.dart';
import 'package:mia_prima_app/utility/uploadManager.dart';
import 'package:http/http.dart' as http;

/// la classe Utility permette di utilizzare
/// dei dati tra le varie altre classi
class Utility {
  //fa riferimento all'id del amministratore del quale dovra' prendere il calendario, ora lo settiamo banalmente qui, ma poi si puo' pensare una logica migliroe per impostarlo
  static String idApp = "32";

  /// Utility.idUtente porta l'id dell'utente letto dal database
  /// e serve a riconoscerlo in modo univoco
  static String idUtente;

  /// Utility.Database
  static dynamic database;

  /// Utility.DatabaseHelper
  static DatabaseHelper databaseHelper;

  /// questa e la chiave di login con il quale l'utente si connette e manitne la connessione
  static Utente utente;

  static List<Disponibilita> calendario;
  static List<dynamic> listaPrenotazioni;

  static String idCalendario;

  static UploadManager uploadManger = new UploadManager();

  static int getSettimana() {
    var now = new DateTime.now();
    int adesso = now.millisecondsSinceEpoch;
    int adessoInt = adesso ~/ 1000; //(adesso/1000).toInt()
    double ris =
        ((((adessoInt / 60) / 60) / 24) - (((1609110000 / 60) / 60) / 24)) / 7;
    return ris.toInt();
  }

  static DateTime annoZero() {
    return DateTime.utc(2020, 12, 28);
  }

  /*
    Questa funzione permette semplicemente di aggiornare il calendario che è aperto
  */
  static void updateCalendario() {
    DownloadJson downloadJson = new DownloadJson(
        url: EndPoint.GET_CALENDARI_SETTIMANE,
        parametri: {"id_calendario": idCalendario, "calendari_timestamp": "-1"},
        // passo al parametro letturaTerminata la funzione letturaTerminata
        // che verrà eseguita nella classe DownloadJson
        letturaTerminata: letturaTerminataCalendarioRichieste);
    // funzione presente nella classe DownloadJson tramite url lancia la funzione
    downloadJson.start();
  }

  static void updateAppuntamenti() {
    DownloadJson downloadJsonListaPrenotazioni = new DownloadJson(
        url: EndPoint.GET_APPUNTAMENTI,
        // passo al parametro letturaTerminata la funzione letturaTerminata
        // che verrà eseguita nella classe DownloadJson
        letturaTerminata: (http.Response data) {
          if (data.statusCode == 200) {
            Utility.listaPrenotazioni = jsonDecode(data.body);
          }
        });
    // funzione presente nella classe DownloadJson tramite url lancia la funzione
    downloadJsonListaPrenotazioni.start();
  }

  static void letturaTerminataCalendarioRichieste(http.Response data) {
    if (data.statusCode == 200) {
      ConvertSettimanaInCalendario convertSettimana =
          new ConvertSettimanaInCalendario(jsonString: data.body);
      Utility.calendario = convertSettimana.getCalendarioDisponibilita();
    } else {
      print("Erorre: ${data.statusCode}");
    }
  }

  static String _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  static Random _rnd = Random();

  static String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
    length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
}
