import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mia_prima_app/utility/utility.dart';
import 'dart:math';
import 'package:intl/intl.dart';

/// Classe che si occupa della gestione delle notifiche relative al promemoria dell'appuntamento
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
    /// conserva la lista delle notifiche che sono attive all'interno dell'app per i vari appuntamenti
    List<String> listNotification =
        Utility.preferences.getStringList("notifica-$idAppuntamento");
    // Utility.preferences.remove("notifica-$idAppuntamento");
    if (listNotification == null) {
      /// se non è mai stata creata la lista delle notifiche per un certo appuntamento
      /// allora è certo che la classe è stata lanciata per la prima volta per un certo appuntamento
      /// e ci si dovrà comportare di conseguenza
      _hasNotNotifica();
    } else {
      /// se invece è presente una lista, allora bisognerà solamente leggerne il contenuto
      _readNotifiche(listNotification);
    }
  }

  List<NotificaScheduler> get notificheScheduler {
    return _notificheScheduler;
  }

  /// Permette di creare la prima notifica di default per l'appuntamento
  /// o meglio la crea se il default è a true, altrimenti lo salta e crea una lista vuota
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

  /// il contenuto delle notifiche viene letto e formattato in modo corretto
  /// se una data tra quelle presenti nella lista è più vecchia di quella attuale
  /// allora quella notifica verrà scartata e non inserita nella lista delle notifiche
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

  /// funzione che permette di verificare se per un certo appuntamento e ad un certo orario è già stata impostata una notifica
  /// in modo tale da evitare di creare una nuova notifica per lo stesso orario
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

  /// permette di creare la notifica per un certo orario, più precisamente gli viene passato in ingresso
  /// quanti minuti prima dell'orario della prenotazione si vuole ricevere la notifica
  /// perciò se l'orario dell'appuntamento è alle 18:30 e si mettono 120 min, la notifica verrà impostata
  /// alle 16:30
  /// se però si prova a mettere una differenza di minuti che porterebbe a creare una notifica nel passato
  /// allora questo ti viene notificato dicendo che non puoi farlo
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

  /// funzione simile a quella immediatamente sopra, con la differenza che viene passata
  /// la data di quando impostare la notifica e non la differenza temporale
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

  /// queste due funzioni servono banalmente per ordinare le notifiche
  /// questo in quanto poi a livello di visualizzazione devono essere messe in ordine temporale
  void _sortListNotifiche() {
    _notificheScheduler.sort((a, b) {
      return a.start.compareTo(b.start);
    });
  }

  List<String> _sortListNotificheString(List<String> list) {
    list.sort((a, b) {
      return a.split("-")[1].compareTo(b.split("-")[1]);
    });
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

    /// dopo aver creato la notifica che poi verrà inviata all'app, ritorna la stringa
    /// che poi verrà inserita nella lista delle notifiche per memorizzare che esiste questa notifica
    /// è importante conservare l'ip in quanto poi può essere utilizzato per eliminare una notifica
    return "$idNotifica-${dataSchedulazione.millisecondsSinceEpoch}";
  }
}

class NotificaScheduler {
  final int id;
  final DateTime start;

  NotificaScheduler(this.id, this.start);
}
