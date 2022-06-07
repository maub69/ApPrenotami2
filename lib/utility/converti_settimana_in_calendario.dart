import 'dart:convert';

import 'utility.dart';

import '../pages/dash/calendari/calendario.dart';

/// questa classe prende in ingresso il body json di ogni calendario e lo trasforma
/// in una lista di appuntamenti che sono caratterizzati da inizio, fine e descrizione
class ConvertSettimanaInCalendario {
  final List<dynamic> results;

  ConvertSettimanaInCalendario({this.results});

  List<Disponibilita> getCalendarioDisponibilita() {
    List<Disponibilita> meetings = [];
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
            prenotato: "1",
            hasDurata: element["has_durata"]));
      });
    });
    return meetings;
  }

  /// dato che la data arriva dal server in un formato "settimana", cioè si contano
  /// le settimane a partire dal 28/12/2020, per ottenere la data corrente deve essere convertita con questa funzione
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
