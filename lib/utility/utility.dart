import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'file_system_new.dart';
import '../pages/dash/calendari/calendario.dart';
import 'package:mia_prima_app/utility/download_json.dart';
import 'package:mia_prima_app/utility/endpoint.dart';
import 'package:mia_prima_app/utility/utente.dart';
import 'package:mia_prima_app/utility/upload_manager.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// classe di supporto per tutte le classi
class Utility {
  /// fa riferimento all'id del amministratore del quale dovra' prendere il calendario
  static String idApp;

  /// conserva l'id dell'utente
  static String idUtente;

  /// Classe con informazioni dell'utente
  static Utente utente;

  static List<CalendarioBox> calendari;
  static List<dynamic> listaPrenotazioni;

  static int idCalendarioAperto;

  static String pathTmpDownload;

  static String pathDownload;

  static Map<String, CacheManager> cacheManager = {};

  static bool hasInternet = true;

  static bool hasConnessioneServer = true;

  static bool isLogged = false;

  /// del dispositivo
  static double width;
  
  /// del dispositivo
  static double height;

  /// età minia per iscriversi all'app
  static int ageApp = 18;

  static SharedPreferences preferences;

  /// invia la notifica per dire che internet è assente, se chiamata più volte
  /// se la connessione è sempre assente non rimostra il popup
  static void callConnessioneServerAssente() {
    if (hasConnessioneServer && hasInternet) {
      hasConnessioneServer = false;
      FlutterToast.showToast(
          msg: "Server temporaneamente irraggiungibile",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Color(0xFF616161),
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  /// questa funzione permette di ottenere l'oggetto di gestione della cache per le immagini
  /// in particolare ogni chat deve avere un proprio oggetto che gestisca separatamente
  /// la cache delle immagini, in questo modo, nel momento nel quale viene cancellata una chat
  /// può essere eliminata singolarmente la cache delle immagini di questa chat
  /// lasciando tutte le altre attive. Questo dettaglio è molto importante in quanto di base
  /// la classe CacheManager non permette di avere questa gestione separata delle cache, cosa
  /// che abbiamo dovuto realizzare noi in modo dedicato.
  /// In particolare in ingresso a questa funzione viene passato l'id dell appuntamento
  /// che verrà utilizzato per creare in particolare la folder nel quale verranno
  /// salvate le immagini della chat, per poi potrà essere eliminata come una qualsiasi
  /// altra cartella. Questa istanza viene usata sia per mettere in cache le immagini
  /// e sia dai widget preesistenti che si appoggiano su questa istanza per capire da dove
  /// leggere le immagini in cache
  static CacheManager getCacheManager(String idAppuntamento) {
    if (!cacheManager.containsKey(idAppuntamento)) {
      cacheManager[idAppuntamento] = CacheManager(
        Config(
          "images_$idAppuntamento",
          stalePeriod: const Duration(days: 720),
          maxNrOfCacheObjects: 1000,
          repo: JsonCacheInfoRepository(databaseName: "images_$idAppuntamento"),
          fileSystem: FileSystemNew("images/$idAppuntamento"),
          fileService: HttpFileService(),
        ),
      );
    }
    return cacheManager[idAppuntamento];
  }

  static UploadManager uploadManager = new UploadManager();

  static String getDateInCorrectFormat(DateTime dateTime) {
    DateFormat formatter = DateFormat('yyyy-MM-dd_hh-mm-ss');
    return formatter.format(dateTime);
  }

  static String getDateStringFromDateTime(DateTime dateTime, String format) {
    DateFormat formatter = DateFormat(format);
    return formatter.format(dateTime);
  }

  static String formattaDurata(DateTime from, DateTime to) {
    String output = "";
    Duration duration = to.difference(from);
    if (duration.inDays > 1) {
      output = "${duration.inDays} giorni ";
    }
    if (duration.inDays == 1) {
      output = "${duration.inDays} giorno ";
    }
    if (duration.inHours % 24 > 1) {
      output = output + "${duration.inHours % 24} ore ";
    }
    if (duration.inHours % 24 == 1) {
      output = output + "${duration.inHours % 24} ora ";
    }
    if (duration.inMinutes % 60 > 1) {
      output = output + "${duration.inMinutes % 60} minuti ";
    }
    if (duration.inMinutes % 60 == 1) {
      output = output + "${duration.inHours % 60} minuto ";
    }
    return output.trim();
  }

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

  /// risulta importante aggiornare il calendario in quanto dopo un cambio di orario o comunque un cambio di info dell'appuntamento il calendario potrebbe aver subito delle variazioni
  static Function updateCalendario;

  /// aggiorna la lista degli appuntamenti
  static void updateAppuntamenti() {
    DownloadJson downloadJsonListaPrenotazioni = new DownloadJson(
        url: EndPoint.GET_LISTA_PRENOTAZIONI,
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

  /// fornisce il box che può essere trovato dentro lista appuntamenti, per box si intende
  /// il widget che rappresenta un appuntamento
  static Positioned getBoxNotification(
    int numNotifiche, {
    double right = 0,
    double top = 0,
    bool hasIcon = false,
  }) {
    Widget content;
    if (hasIcon) {
      content = Container(
        padding: EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: Colors.green[700],
          borderRadius: BorderRadius.circular(22),
        ),
        constraints: BoxConstraints(
          minWidth: 28,
          minHeight: 12,
        ),
        child: Text(
          '$numNotifiche',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
          textAlign: TextAlign.center,
        ),
      );
    } else {
      content = Stack(alignment: Alignment.center, children: [
        Transform(
          alignment: Alignment.center,
          transform: Matrix4.rotationY(pi),
          child: Icon(
            Icons.mode_comment,
            color: Colors.green[700],
            size: 40.0,
            semanticLabel: 'Messaggi non letti',
          ),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 6),
          child: Text(
            '$numNotifiche',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
          ),
        )
      ]);
    }
    return Positioned(
      right: right,
      top: top,
      child: content,
    );
  }

  static String _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  static Random _rnd = Random();

  static String getRandomString(int length) =>
      String.fromCharCodes(Iterable.generate(
          length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  static Function onMessageFirebase;

  static String formatStringDatefromString(
      String start, String end, String dateTimeString) {
    return DateFormat(end).format(DateFormat(start).parse(dateTimeString));
  }

  // (int)2:prenotato|1:in attesa dell'azienda|0:in attesa del cliente|-1:rifituato|-2:in attesa di cancellazione|-3:cancellato|-4:terminato
  static Color getColorStateAppuntamento(int state) {
    switch (state) {
      case 2:
        return Colors.green[400];
      case 1:
        return Colors.orange[300];
      case 0:
        return Colors.orange[300];
      case -1:
        return Colors.red[400];
      case -2:
        return Colors.orange[300];
      case -3:
        return Colors.red[400];
      case -4:
        return Colors.brown[200];
      case -5:
        return Colors.brown[200];
      default:
        return Colors.white;
    }
  }

  static String getNameStateAppuntamento(int state) {
    switch (state) {
      case 2:
        return "PRENOTATO";
      case 1:
        return "IN ATTESA DI CONFERMA";
      case 0:
        return "DA CONFERMARE";
      case -1:
        return "RIFIUTATO";
      case -2:
        return "IN ATTESA DI CANCELLAZIONE";
      case -3:
        return "CANCELLATO";
      case -4:
        return "CONCLUSO";
      case -5:
        return "ARCHIVIATO";
      default:
        return "";
    }
  }

  static void deletePrenotazione(String idPrenotazione) {
    File fileChat = File(Utility.pathDownload + "/chats/" + idPrenotazione);
    if (fileChat.existsSync()) {
      fileChat.deleteSync();
    }

    Directory filesDir =
        Directory(Utility.pathDownload + "/files/" + idPrenotazione);
    if (filesDir.existsSync()) {
      filesDir.deleteSync(recursive: true);
    }

    Directory imagesDir =
        Directory(Utility.pathDownload + "/images/" + idPrenotazione);
    if (imagesDir.existsSync()) {
      imagesDir.deleteSync(recursive: true);
    }
  }

  static void displaySnackBar(String message, BuildContext _scaffoldContext,
      {String actionMessage, VoidCallback onClick, int type = 1}) {
    Color colorType;
    if (type == 1) {
      //success
      colorType = Colors.green[900];
    } else if (type == 2) {
      //warning
      colorType = Colors.orange;
    } else {
      //error
      colorType = Colors.red;
    }
    ScaffoldMessenger.of(_scaffoldContext).showSnackBar(SnackBar(
      content: Text(
        message,
        style: TextStyle(color: Colors.white, fontSize: 14.0),
      ),
      action: (actionMessage != null)
          ? SnackBarAction(
              textColor: Colors.white,
              label: actionMessage,
              onPressed: () {
                return onClick != null ? onClick() : () {};
              },
            )
          : null,
      duration: Duration(seconds: 3),
      backgroundColor: colorType,
    ));
  }

  // TODO https://pub.dev/packages/get_storage
  // TODO https://pub.dev/packages/shared_preferences
  // TODO gestire le impostazioni, sia notifiche che logout, in particolare le notifiche gestiscile con questa libreria
  // TODO - gestione notifiche, attivarle o no e tutte le cose ricollegate

  // TODO - fai una segnalazione
  // TODO - librerie opensource utilizzate
  // TODO - logout
}
