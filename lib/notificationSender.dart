import 'dart:convert';
import 'dart:math';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mia_prima_app/chatpage.dart';
import 'package:mia_prima_app/main.dart';
import 'package:mia_prima_app/model.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    as nt;
import 'package:mia_prima_app/utility/messagesManager.dart';

/*
  Questa classe fa fondamentalmente due cose:
    - showNotificationWithoutSound permette di invia una notifica forzatamente dall'intenro dell'app, in questo modo anche se firebase di base nonla invia, questa funzione la avvia lo stesso
    - configureFirebaseNotification configura interamente firebase, questa e' una funzione fondamentale perche' senza questa dopo aver aperto una chat si perderebbe completamente la gestione delle notifiche di firebase
*/
class NotificationSender {
  Future showNotificationWithoutSound(Map<String, dynamic> message,
      [Function onNextCallNotification]) async {
    print(message);
    print(message["data"]["id_appuntamento"].toString());

    var initializationSettingsAndroid =
        new nt.AndroidInitializationSettings('ic_launcher');
    var initializationSettings =
        new nt.InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin = new nt.FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (onNextCallNotification ==
                null //di base la funzione che deve essere chiamata
            // alla chiusura di una chat e' configureFirebaseNotification, in quanto ricopre quasi tutte le casistiche,
            // c'e' pero' una caisistica non coperta, cioe' quell nella quale si apre una chat a partire da un altra chat
            // in quel caso bisogna chiamare un'altra funzione di configurazione a partire dalla classe che gestisce la chat
            ? onSelectNotification(configureFirebaseNotification)
            : onSelectNotification(onNextCallNotification)));

    //final random = new Random();
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        'apprenotami.appuntamenti',
        'Appuntamenti',
        'Qui ricevi le notifiche per gli appuntamenti',
        playSound: false);
    var platformChannelSpecifics =
        new NotificationDetails(android: androidPlatformChannelSpecifics);
    flutterLocalNotificationsPlugin.show(
      jsonDecode(message["data"]["body"])["id"],
      message["notification"]["title"],
      message["notification"]["body"],
      platformChannelSpecifics,
      payload: jsonDecode(message["data"]["body"])["id"].toString(),
    );
  }

  Function onSelectNotification(Function nextCall) {
    return (String payload) async {
      try {
        Navigator.push(
          Model.getContext(),
          MaterialPageRoute(
              builder: (context) =>
                  ChatPage(idAppuntamento: int.parse(payload))),
        ).then((value) {
          nextCall();
        });
      } catch (e) {
        print(e);
      }
    };
  }

  void configureFirebaseNotification() {
    MessagesManager.isNotChat = true;
    final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
    _firebaseMessaging.configure(
        onResume: (Map<String, dynamic> message) async {
      print('on resume $message');
      Navigator.push(
        Model.getContext(),
        MaterialPageRoute(
            builder: (context) => ChatPage(
                idAppuntamento: jsonDecode(message["data"]["body"])["id"])),
      ).then((value) {
        configureFirebaseNotification();
      });
    }, onMessage: (Map<String, dynamic> message) async {
      try {
        NotificationSender notificationSender = NotificationSender();
        notificationSender.showNotificationWithoutSound(message);
        MessagesManager.addChat(jsonDecode(message["data"]["body"])["id"]);
      } catch (e) {
        print(e);
      }
    }, onLaunch: (Map<String, dynamic> message) async {
      // in caso dell'onLauch, bisogna settare la variabile del calendario e dell'appuntamento che si vuole aprire, in questo modo il flusso del programma sa che dovra intraprendere delle azioni speciali per aprire un appuntamento
      idCalendario = message["data"]["id_calendario"];
      idAppuntamento = jsonDecode(message["data"]["body"])["id"].toString();
      /*FlutterToast.showToast(
        msg: message["data"]["id_calendario"],
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0
      );*/
    });
  }
}
