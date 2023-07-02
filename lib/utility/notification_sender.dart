import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../pages/dash/lista_prenotazioni/prenotazione/chat/chat_page.dart';
import 'package:mia_prima_app/main.dart';
import '../pages/global/model.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart' as nt;
import 'package:mia_prima_app/utility/messages_manager.dart';
import 'package:mia_prima_app/utility/utility.dart';

/// Questa classe fa fondamentalmente due cose:
/// - showNotificationWithoutSound permette di inviare una notifica forzatamente dall'interno dell'app,
/// in questo modo anche se firebase di base non la invia, questa funzione la avvia lo stesso
/// - configureFirebaseNotification configura interamente firebase,
/// questa e' una funzione fondamentale perche' senza questa dopo aver aperto una chat si perderebbe
/// completamente la gestione delle notifiche di firebase
class NotificationSender {
  Future showNotificationWithoutSound(RemoteMessage message,
      [Function onNextCallNotification]) async {
    var initializationSettingsAndroid =
        new nt.AndroidInitializationSettings('ic_launcher');
    var initializationSettings =
        new nt.InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin = new nt.FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (onNextCallNotification ==
                null //di base la funzione che deve essere chiamata
            // alla chiusura di una chat e' configureFirebaseNotification, in quanto ricopre quasi tutte le casistiche,
            // c'e' pero' una casistica non coperta, cioe' quell nella quale si apre una chat a partire da un altra chat
            // in quel caso bisogna chiamare un'altra funzione di configurazione a partire dalla classe che gestisce la chat
            ? onSelectNotification(configureFirebaseNotification)
            : onSelectNotification(onNextCallNotification)));

    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        'apprenotami.appuntamenti',
        'Appuntamenti',
        playSound: false);
    var platformChannelSpecifics =
        new NotificationDetails(android: androidPlatformChannelSpecifics);
    flutterLocalNotificationsPlugin.show(
      int.parse(message.data["id_appuntamento"]),
      message.notification.title,
      message.notification.body,
      platformChannelSpecifics,
      payload: message.data["id_appuntamento"].toString(),
    );
  }

  Function onSelectNotification(Function nextCall) {
    return (String payload) async {
      try {
        dynamic prenotazione = Utility.listaPrenotazioni
            .where((element) => element["id"] == int.parse(payload)).first;
        Navigator.push(
          Model.getContext(),
          MaterialPageRoute(
              builder: (context) =>
                  ChatPage(
                    idAppuntamento: int.parse(payload),
                    prenotazione: prenotazione,
                          )),
        ).then((value) {
          nextCall();
        });
      } catch (e) {
        print(e);
      }
    };
  }

  void configureFirebaseNotification() {
    Utility.onMessageFirebase = _setOnMessage;
  }

  void configureFirebaseNotificationOnStart() async {
    configureFirebaseNotification();
    MessagesManager.isNotChat = true;

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('on resume $message');
      dynamic prenotazione = Utility.listaPrenotazioni
          .where((element) => element["id"] == int.parse(message.data["id_appuntamento"])).first;
      Navigator.push(
        Model.getContext(),
        MaterialPageRoute(
            builder: (context) => ChatPage(
                idAppuntamento: int.parse(message.data["id_appuntamento"]),
                prenotazione: prenotazione)),
      ).then((value) {
        configureFirebaseNotification();
      });
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      Utility.onMessageFirebase(message);
    });

    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage message) {
      if (message != null) {
        // in caso dell'onLauch, bisogna settare la variabile del calendario e dell'appuntamento che si vuole aprire, in questo modo il flusso del programma sa che dovra intraprendere delle azioni speciali per aprire un appuntamento
        // print("contentuto-data: sono qui");
        // print("contentuto-data: ${message.data}");
        idCalendario = message.data["id_calendario"];
        idAppuntamento = message.data["id_appuntamento"].toString();
      }
    });
  }

  void _setOnMessage(RemoteMessage message) {
    try {
      NotificationSender notificationSender = NotificationSender();
      notificationSender.showNotificationWithoutSound(message);
      MessagesManager.addChat(jsonDecode(message.data["body"])["id"]);
    } catch (e) {
      print(e);
    }
  }
}
