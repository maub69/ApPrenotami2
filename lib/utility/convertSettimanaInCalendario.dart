import 'dart:convert';

import 'package:mia_prima_app/utility/downloadJson.dart';
import 'utility.dart';

import '../calendario.dart';

/// Questa classe serve per trasformarte una lista in un oggetto Meeting per popolare un calendario
class ConvertSettimanaInCalendario {
  final List<dynamic> results;
  /*List<dynamic> settimane = [
    {"start": "1|08:30", "end": "1|09:00", "disponiblita": 5},
    {"start": "1|09:00", "end": "1|09:15", "disponiblita": 2},
    {"start": "1|09:15", "end": "1|11:00", "disponiblita": 12},
    {"start": "1|14:00", "end": "1|15:00", "disponiblita": 4},
    {"start": "1|23:30", "end": "2|04:00", "disponiblita": 10},
    {"start": "2|09:30", "end": "2|10:00", "disponiblita": 5},
    {"start": "2|10:00", "end": "2|10:15", "disponiblita": 2},
    {"start": "2|10:30", "end": "2|11:30", "disponiblita": 12},
    {"start": "2|14:30", "end": "2|15:00", "disponiblita": 4},
    {"start": "2|18:30", "end": "3|04:00", "disponiblita": 10},
    {"start": "4|09:00", "end": "4|11:15", "disponiblita": 2},
    {"start": "4|15:00", "end": "4|18:00", "disponiblita": 2},
    {"start": "5|11:00", "end": "5|12:15", "disponiblita": 2},
    {"start": "5|15:00", "end": "5|19:00", "disponiblita": 2},
    {"start": "5|22:00", "end": "6|02:00", "disponiblita": 2}
  ];*/

  ConvertSettimanaInCalendario({this.results});

  /* entra la lista contenente i blocchi di una specifica settimana
  creare funzione che con ogni blocchettino interno al blocco settimanale crea un meeting
  esce una lista di meeting

  Prendo ogni oggetto della lista settimane
  quello che è contenuto in start lo splitto
  il numero della settimana lo uso con la funzione che mi ritorna una data
  */
  List<Disponibilita> getCalendarioDisponibilita() {
    List<Disponibilita> meetings = [];
    //scansioniamo blocco per blocco delle settimane (guarda struttura file base.json)
    results.forEach((ele) {
      //fornisce la settimana a partire dall'anno zero (28/12/2020)
      int settimana = int.parse(ele["settimana"]);
      //prendiamo il json interno contenente le pianificazioni per quella specifica settimana
      List<dynamic> pianificazione = jsonDecode(ele["pianificazione"]);
      //una volta prese le scansioniamo una a una (guarda struttura file pianificazione.json)
      pianificazione.forEach((element) {
        DateTime start = _getDataTimeFromString(element["start"], settimana);
        DateTime end = _getDataTimeFromString(element["end"], settimana);
        int disponibilita = element["disponibilita"];
        meetings.add(Disponibilita(
            descrizione: disponibilita.toString(),
            from: start,
            to: end,
            prenotato: "1"));
      });
    });
    return meetings;
    /*Meeting(
            descrizione: element["disponibilita"],
            from: DateTime.parse(element["inizio"]),
            to: DateTime.parse(element["fine"]),
            prenotato: element["prenotato"])*/
  }

  DateTime _getDataTimeFromString(String date, int settimana) {
    //dato che giorno e ora sono insieme, splittiamo le due informazioni
    List<String> giornoOra = date.split("|");
    //otteniamo il giorno e sottraiamo di uno, perche' per lui l'inizio settimana e' gia il lunedi'
    int giorno = int.parse(giornoOra[0]) - 1;
    List<String> oraList = giornoOra[1].split(":");
    int ora = int.parse(oraList[0]);
    int minuti = int.parse(oraList[1]);
    //aggiunge all'anno zero i giorni che permettono di arrivare alla data corrente
    return Utility.annoZero().add(
        Duration(days: settimana * 7 + giorno, hours: ora, minutes: minuti));
  }
}
