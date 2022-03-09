import 'dart:convert';

import 'package:flutter/material.dart';
/*
  Questa classe rappresenta la classe astratta di tutti i messaggi che poi verranno visualizzati nella chat
*/

abstract class Risposta {
  final String idChat;
  final Map<String, dynamic> body;
  final DateTime datetime;
  final BuildContext context;
  final Function(List<Widget> listWidgets)
      delWidgets; //permette di eliminare un widget passandogli effettivamente la lsita degli oggetti dei widget interessati

  Risposta(
      this.idChat, this.body, this.datetime, this.context, this.delWidgets);

  /*
    Trona una lista di Widget che verranno visualizzati nella chat. E' utile far tornare una lista in quanto
    in alcuni casi più complicati e' necessario mostrare piu' elementi nella chat, un esempio e' quello della scelda dell'orario
  */
  List<Widget> getRisposta();

  String get type;

  String getJsonResponse() {
    return getJson(idChat, type, datetime, body);
  }

  static String getJson(String id, String action, DateTime datetime, dynamic body) {
    var response = {
      "id": id,
      "action": action,
      "datetime": datetime.toString(),
      "body": body
    };
    return jsonEncode(response);
  }
}
