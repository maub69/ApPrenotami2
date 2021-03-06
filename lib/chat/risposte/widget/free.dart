import 'package:flutter/material.dart';
import 'package:mia_prima_app/chat/risposte/risposta.dart';
import 'package:mia_prima_app/messagetile.dart';
import 'package:path/path.dart';

/*
  Rappresenta il messaggio in chat piu' semplice, quello di testo libero
*/
class Free extends Risposta {
  Free(int idChat, Map<String, dynamic> body, DateTime datetime, BuildContext context, Function(List<Widget> listWidgets) delWidgets)
      : super(idChat, body, datetime, context, delWidgets);

  @override
  List<Widget> getRisposta() {
    return [MessageTile(
      messageText: body["message"],
      isLeft: body["isAmministratore"],
      datetime: datetime,
    )];
  }
}
