import 'package:flutter/material.dart';
import 'crea_appuntamento/crea_appuntamento.dart';
import '../../global/model.dart';
import 'package:mia_prima_app/utility/utility.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:syncfusion_localizations/syncfusion_localizations.dart';

class Calendario extends StatefulWidget {
  final List<Disponibilita> calendario;
  //questa unzione specifica che cosa fare quando un evento sul calendario viene cliccato, gli viene passato in entrata l'appuntamento cosi' sa che cosa gestire
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
    return appointments[index].background;
  }

  @override
  bool isAllDay(int index) {
    return appointments[index].isAllDay;
  }
}

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
