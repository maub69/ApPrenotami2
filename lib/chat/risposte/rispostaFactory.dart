import 'package:flutter/cupertino.dart';
import 'package:mia_prima_app/chat/risposte/widget/Free.dart';
import 'package:mia_prima_app/chat/risposte/widget/cambioOrario.dart';
import 'package:mia_prima_app/chat/risposte/widget/file.dart';
import 'package:mia_prima_app/chat/risposte/widget/photo.dart';
import 'package:mia_prima_app/chat/risposte/widget/stepsMessage.dart';
import 'package:mia_prima_app/chat/risposte/widget/video.dart';

class RispostaFactory {
  static ResponseRispostaFactory getRisposta(String type, Map<String, dynamic> body,
      BuildContext context, Function(List<Widget> listWidget) delWidgets, String idAppuntamento) {
    DateTime datetime = DateTime.parse(body["datetime"]);
    switch (type) {
      case "free":
        return ResponseRispostaFactory(Free(body["id"], body["body"], datetime, context, delWidgets)
            .getRisposta(), datetime);

      case "cambio-orario":
        return ResponseRispostaFactory(CambioOrario(
                body["id"], body["body"], datetime, context, delWidgets)
            .getRisposta(), datetime);

      case "steps":
        return ResponseRispostaFactory(StepsMessage(
                body["id"], body["body"], datetime, context, delWidgets)
            .getRisposta(), datetime);

      case "photo":
        return ResponseRispostaFactory(Photo(
                body["id"], body["body"], datetime, context, delWidgets, idAppuntamento)
            .getRisposta(), datetime);

      case "video":
        return ResponseRispostaFactory(Video(
                body["id"], body["body"], datetime, context, delWidgets, idAppuntamento)
            .getRisposta(), datetime);

      case "file":
        return ResponseRispostaFactory(File(
                body["id"], body["body"], datetime, context, delWidgets, idAppuntamento)
            .getRisposta(), datetime);
    }
  }
}

class ResponseRispostaFactory {
  final List<Widget> widgets;
  final DateTime dateTime;

  ResponseRispostaFactory(this.widgets, this.dateTime);
}