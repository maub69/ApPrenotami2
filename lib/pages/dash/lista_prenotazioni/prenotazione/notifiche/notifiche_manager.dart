import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:mia_prima_app/pages/dash/lista_prenotazioni/prenotazione/notifiche/notifica_scheduler.dart';
import 'package:mia_prima_app/utility/utility.dart';

class NotificheManager {
  static bool hasDefault = true;
  static int minutesBefore = 30;

  final DateTime dataAppuntamento;
  final String idAppuntamento;
  List<NotificaScheduler> _notificaScheduler = [];

  NotificheManager({this.dataAppuntamento, this.idAppuntamento}) {
    // TODO le schedulazioni devono essere salvate come lista di stringhe dentro le preferences, la chiave può essere una cosa del genere "notifica-<id-prenotazione>"
    // TODO se è presente una chiava e di conseguenza una lista usa quella, altrimento ne crea una da zero creando per la prima volta la prima notifica, ovviamente se il default è abilitato
    // TODO usare il contenuto della funzione notifica per schedulare e rimuovere una notifica schedulata
    // Utility.preferences.setStringList(key, value)
  }

  void notifica() async {
    print("--------> scheduler notifica");

    await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 12, // usa come id un id generato casualmente e presente nella lista salvata nelle preferences
          channelKey: 'scheduler_prenotazioni_high',
          title: 'Just in time!',
          body: 'Test invio notifica',
          wakeUpScreen: false,
          displayOnBackground: true,
          displayOnForeground: true,
          category: NotificationCategory.Reminder,
          payload: {'uuid': 'uuid-test'},
          autoDismissible: false,
        ),
        schedule: NotificationCalendar.fromDate(
            date: DateTime(2022, 04, 11, 22, 20)));

        await AwesomeNotifications().cancel(12);
        
  }

  void addNotifica() {}

  void deleteNotifica() {}
}
