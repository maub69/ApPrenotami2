import 'package:flutter/material.dart';
import 'package:mia_prima_app/creaAppuntamento.dart';
import 'package:mia_prima_app/model.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:syncfusion_localizations/syncfusion_localizations.dart';

class Calendario extends StatefulWidget {
  final List<Meeting> meetings;
  //questa unzione specifica che cosa fare quando un evento sul calendario viene cliccato, gli viene passato in entrata l'appuntamento cosi' sa che cosa gestire
  final Function(Meeting appuntamento) onTapMeeting;

  Calendario({this.meetings, this.onTapMeeting});

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
    meetingDataSource = MeetingDataSource(widget.meetings);
  }

  @override
  Widget build(BuildContext context) {
    return Model(
        body: SfCalendar(
      view: CalendarView.week,
      dataSource: meetingDataSource,
      onTap: (CalendarTapDetails details) {
        List<dynamic> appuntamenti = details.appointments;
        if (appuntamenti == null) {
          print("risposta: non ci sono appuntamenti");
        } else {
          widget.onTapMeeting((appuntamenti[0] as Meeting));
        }
      },
      timeSlotViewSettings: TimeSlotViewSettings(
          startHour: 1,
          endHour: 23,
          nonWorkingDays: <int>[DateTime.friday, DateTime.saturday]),
    ));
  }
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Meeting> source) {
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

class Meeting {
  String descrizione;
  DateTime from;
  DateTime to;
  bool isAllDay;
  String prenotato;

  Meeting(
      {this.descrizione,
      this.from,
      this.to,
      this.prenotato,
      this.isAllDay = false});

  Color get background {
    if (prenotato == "1") {
      return Colors.green;
    } else {
      return Colors.red;
    }
  }
}
