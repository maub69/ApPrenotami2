import 'package:flutter/material.dart';
import 'package:mia_prima_app/pages/dash/lista_prenotazioni/prenotazione/chat/risposte/risposta.dart';
import '../../message_tile.dart';

/*
  Rappresenta il messaggio in chat piu' semplice, quello di testo libero
*/
class Free extends Risposta {
  Free(String idChat, Map<String, dynamic> body, DateTime datetime,
      BuildContext context, Function(List<Widget> listWidgets) delWidgets)
      : super(idChat, body, datetime, context, delWidgets);

  @override
  List<Widget> getRisposta() {
    return [
      MessageTile(
        messageText: body["message"],
        isLeft: body["isAmministratore"],
        datetime: datetime,
        idChat: idChat,
      )
    ];
  }

  @override
  String get type => "free";
}
