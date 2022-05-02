import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mia_prima_app/pages/dash/lista_prenotazioni/prenotazione/notifiche/notifica_scheduler.dart';
import 'package:mia_prima_app/utility/utility.dart';
import 'dart:math';
import 'package:intl/intl.dart';

class NotificheManager {
  static bool hasDefault = true;
  static int minutesBefore = 30;
  final DateTime dataAppuntamento;
  final String idAppuntamento;
  final String nomeAppuntamento;
  List<NotificaScheduler> _notificheScheduler = [];
  Random _random;

  NotificheManager(
      {this.dataAppuntamento, this.idAppuntamento, this.nomeAppuntamento});

  void start() {
    _random = new Random();
    List<String> listNotification =
        Utility.preferences.getStringList("notifica-$idAppuntamento");
    // Utility.preferences.remove("notifica-$idAppuntamento");
    if (listNotification == null) {
      _hasNotNotifica();
    } else {
      _readNotifiche(listNotification);
    }
  }

  List<NotificaScheduler> get notificheScheduler {
    return _notificheScheduler;
  }

  void _hasNotNotifica() {
    List<String> listNotification = [];
    if (hasDefault) {
      DateTime dataSchedulazione =
          dataAppuntamento.add(Duration(minutes: minutesBefore * (-1)));
      if (_isDateValid(dataSchedulazione)) {
        listNotification.add(_createNotifica(dataSchedulazione));
      }
    }
    Utility.preferences
        .setStringList("notifica-$idAppuntamento", listNotification);
  }

  void _readNotifiche(List<String> listNotification) {
    _notificheScheduler = [];
    listNotification.forEach((element) {
      List<String> notificaSplit = element.split("-");
      DateTime date =
          DateTime.fromMillisecondsSinceEpoch(int.parse(notificaSplit[1]));
      if (_isDateValid(date)) {
        _notificheScheduler
            .add(NotificaScheduler(int.parse(notificaSplit[0]), date));
      }
    });
  }

  bool _dataSchedulazioneExists(DateTime dataSchedulazione) {
    bool hasDataSchedulazione = false;
    List<String> notifications =
        Utility.preferences.getStringList("notifica-$idAppuntamento");
    String millisData = dataSchedulazione.millisecondsSinceEpoch.toString();
    notifications.forEach((element) {
      if (element.split("-")[1] == millisData) {
        hasDataSchedulazione = true;
      }
    });
    return hasDataSchedulazione;
  }

  void addNotificaDifference(int minutes) {
    DateTime date = dataAppuntamento.add(Duration(minutes: minutes * (-1)));
    addNotifica(date);
    if(!_isDateValid(date)) {
      FlutterToast.showToast(
              msg: "Non è possibile selezionare una data nel passato",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Color(0xFF616161),

              textColor: Colors.white,
              fontSize: 16.0
            );
    }
  }

  void addNotifica(DateTime dataSchedulazione) {
    if (!_dataSchedulazioneExists(dataSchedulazione) &&
        _isDateValid(dataSchedulazione)) {
      List<String> listNotification =
          Utility.preferences.getStringList("notifica-$idAppuntamento");
      listNotification.add(_createNotifica(dataSchedulazione));

      Utility.preferences.setStringList("notifica-$idAppuntamento",
          _sortListNotificheString(listNotification));
    }
  }

  void _sortListNotifiche() {
    _notificheScheduler.sort((a, b) {
      return a.start.compareTo(b.start);
    });
  }

  List<String> _sortListNotificheString(List<String> list) {
    print("non ordinata");
    print(list);
    list.sort((a, b) {
      return a.split("-")[1].compareTo(b.split("-")[1]);
    });
    print("ordinata");
    print(list);
    return list;
  }

  bool _isDateValid(DateTime dateTime) {
    return dateTime.isAfter(DateTime.now());
  }

  void removeNotifica(int idNotifica) {
    AwesomeNotifications().cancel(idNotifica);
    List<String> listNotification =
        Utility.preferences.getStringList("notifica-$idAppuntamento");
    int idSearch = -1;
    listNotification.asMap().forEach((index, element) {
      if (element.startsWith("$idNotifica-")) {
        idSearch = index;
      }
    });
    listNotification.removeAt(idSearch);
    _readNotifiche(listNotification);
    Utility.preferences
        .setStringList("notifica-$idAppuntamento", listNotification);
  }

  String _createNotifica(DateTime dataSchedulazione) {
    int idNotifica = _random.nextInt(1000000);

    AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: idNotifica,
          channelKey: 'scheduler_prenotazioni_high',
          title: 'Promemoria appuntamento',
          body:
              '$nomeAppuntamento del ${Utility.getDateStringFromDateTime(dataSchedulazione, 'dd/MM/yyyy hh:mm')}',
          wakeUpScreen: false,
          displayOnBackground: true,
          displayOnForeground: true,
          category: NotificationCategory.Reminder,
          payload: {'uuid': 'uuid-test'},
          autoDismissible: false,
        ),
        schedule: NotificationCalendar.fromDate(date: dataSchedulazione));

    _notificheScheduler.add(NotificaScheduler(idNotifica, dataSchedulazione));
    _sortListNotifiche();

    return "$idNotifica-${dataSchedulazione.millisecondsSinceEpoch}";
  }
}

class NotificaScheduler {
  final int id;
  final DateTime start;

  NotificaScheduler(this.id, this.start);
}
