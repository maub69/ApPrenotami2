import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mia_prima_app/chat/risposte/risposta.dart';
import 'package:mia_prima_app/messagetile.dart';
import 'package:mia_prima_app/upload/media_upload.dart';
import 'package:mia_prima_app/utility/uploadManager.dart';
import 'package:path/path.dart';

/*
  Rappresenta il messaggio in chat piu' semplice, quello di testo libero
*/
class Photo extends Risposta {
  final String idAppuntamento;
  final ProgressFile progressFile;

  Photo(
      String idChat,
      Map<String, dynamic> body,
      DateTime datetime,
      BuildContext context,
      Function(List<Widget> listWidgets) delWidgets,
      this.idAppuntamento, 
      {this.progressFile})
      : super(idChat, body, datetime, context, delWidgets);

  @override
  List<Widget> getRisposta() {
    Random random = Random();
    return [
      MediaUpload(
          isPhoto: true,
          progressFile: progressFile,
          url: body["url"],
          datetime: datetime,
          isAmministratore: body["isAmministratore"],
          idChat: idChat,
          key: Key(random.nextInt(10000).toString()),
          idAppuntamento: idAppuntamento)
    ];
  }

  @override
  String get type => "photo";
}
