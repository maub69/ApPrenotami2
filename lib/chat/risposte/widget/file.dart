import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mia_prima_app/chat/risposte/risposta.dart';
import 'package:mia_prima_app/messagetile.dart';
import 'package:mia_prima_app/upload/file_upload.dart';
import 'package:path/path.dart';

/*
  Rappresenta il messaggio in chat piu' semplice, quello di testo libero
*/
class File extends Risposta {
  File(int idChat, Map<String, dynamic> body, DateTime datetime,
      BuildContext context, Function(List<Widget> listWidgets) delWidgets)
      : super(idChat, body, datetime, context, delWidgets);


  //TODO bisogna fare in modo che se non è scaricato compare il bottone che dice di scaricarlo e si attende lo scaricamento, il file finisce in download secondo le indicazioni su notion

  @override
  List<Widget> getRisposta() {
    Random random = Random();
    return [
      FileUpload(
          progressFile: null,
          url: body["url"],
          name: body["name"],
          datetime: datetime,
          isAmministratore: body["isAmministratore"],
          key: Key(random.nextInt(10000).toString()))
    ];
  }
}
