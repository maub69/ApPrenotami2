import 'package:flutter/material.dart';
import 'crea_appuntamento/crea_appuntamento.dart';
import '../../global/model.dart';
import 'package:mia_prima_app/utility/utility.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:syncfusion_localizations/syncfusion_localizations.dart';

/// Questa classe si occupa di andare a creare il widget rappresentante il calendario
/// Si tratta di un widget come tutti gli altri, ma poi nella sua build ritorna l'istanza del widget del calendario
/// della libreria specifica che stiamo usando per creare la visualizzazione del calendario
class Calendario extends StatefulWidget {
  final List<Disponibilita> calendario;
  //questa funzione specifica che cosa fare quando un evento sul calendario viene cliccato, gli viene passato in entrata l'appuntamento cosi' sa che cosa gestire
  final Function(Disponibilita appuntamento) onTapDisponibilita;

  Calendario({this.calendario, this.onTapDisponibilita});

  @override
  State<StatefulWidget> createState() {
    return _StateCalendario();
  }
}

class _StateCalendario extends State<Calendario> {
  MeetingDataSource meetingDataSource;

  @override
  void initState() {
    super.initState();
    meetingDataSource = MeetingDataSource(widget.calendario);
  }

  /// Ritorna innanzitutto il widget SfCalendar, che è quello della libreria del calendario che stiamo usando
  /// gli item vhe vengono visualizzati all'intenro del calendario sono quelli di meetingDataSource
  @override
  Widget build(BuildContext context) {
    return Model(
      textAppBar: Utility.calendari
          .where((element) => element.id == Utility.idCalendarioAperto)
          .first
          .name,
      body: new Builder(
        builder: (BuildContext context) {
          return SfCalendar(
            view: CalendarView.week,
            dataSource: meetingDataSource,
            onTap: (CalendarTapDetails details) {
              List<dynamic> appuntamenti = details.appointments;
              if (appuntamenti == null) {
                print("risposta: non ci sono appuntamenti");
              } else if ((appuntamenti[0] as Disponibilita).descrizione == '0') {
                print("risposta: non ci sono appuntamenti");
              } else {
                  widget.onTapDisponibilita((appuntamenti[0] as Disponibilita));
              }
            },
            timeSlotViewSettings: TimeSlotViewSettings(
                startHour: 0,
                endHour: 24,
                nonWorkingDays: <int>[DateTime.friday, DateTime.saturday]),
          );
        },
      ),
    );
  }
}

/// si tratta della classe che viene utilizzata dalla libreria del calendario per visualizzare le informazioni
/// perciò deve necessariamente essere una classe estesa se no non potrebbe funzionare
class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Disponibilita> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return appointments[index].from;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments[index].to;
  }

  @override
  String getSubject(int index) {
    return "Dis: " + appointments[index].descrizione;
  }

  @override
  Color getColor(int index) {
    if (appointments[index].descrizione == '0') {
      return Colors.redAccent;
    }
    return appointments[index].background;
  }

  @override
  bool isAllDay(int index) {
    return appointments[index].isAllDay;
  }
}

/// rappresenta l'oggetto che viene usato per estrarre le informazioni riguardanti l'appuntamento dal item del calendario una volta che viene cliccato
class Disponibilita {
  String descrizione;
  DateTime from;
  DateTime to;
  bool hasDurata;
  bool isAllDay;
  String prenotato;
  Function(String title, String body, String messageAdmin, Color color)
      showMessage;

  Disponibilita(
      {this.descrizione,
      this.from,
      this.to,
      this.prenotato,
      this.isAllDay = false,
      this.hasDurata});

  Color get background {
    if (prenotato == "1") {
      return Colors.green;
    } else {
      return Colors.red;
    }
  }
}

class CalendarioBox {
  final int id;
  final String name;
  final List<Disponibilita> appuntamenti;

  CalendarioBox({this.id, this.name, this.appuntamenti});
}
