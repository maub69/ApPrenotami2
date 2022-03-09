import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mia_prima_app/pages/dash/lista_prenotazioni/prenotazione/chat/risposte/risposta.dart';
import 'package:mia_prima_app/pages/dash/lista_prenotazioni/prenotazione/chat/upload/file_upload.dart';

/*
  Rappresenta il messaggio in chat piu' semplice, quello di testo libero
*/
class File extends Risposta {
  final String idAppuntamento;

  File(
      String idChat,
      Map<String, dynamic> body,
      DateTime datetime,
      BuildContext context,
      Function(List<Widget> listWidgets) delWidgets,
      this.idAppuntamento)
      : super(idChat, body, datetime, context, delWidgets);

  @override
  String get type => "file";

  @override
  List<Widget> getRisposta() {
    Random random = Random();
    return [
      FileUpload(
          idChat: idChat,
          idAppuntamento: idAppuntamento,
          progressFile: null,
          url: body["url"],
          name: body["name"],
          datetime: datetime,
          isAmministratore: body["isAmministratore"],
          key: Key(random.nextInt(10000).toString(),
          ))
    ];
  }
}
