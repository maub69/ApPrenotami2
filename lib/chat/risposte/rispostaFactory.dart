import 'package:flutter/cupertino.dart';
import 'package:mia_prima_app/chat/risposte/widget/Free.dart';
import 'package:mia_prima_app/chat/risposte/widget/cambioOrario.dart';
import 'package:mia_prima_app/chat/risposte/widget/stepsMessage.dart';

class RispostaFactory {
  static List<Widget> getRisposta(String type, Map<String, dynamic> body, BuildContext context, Function(List<Widget> listWidget) delWidgets) {
    DateTime datetime = DateTime.parse(body["datetime"]);
    switch (type) {
      case "free":
        return Free(body["id"], body["body"], datetime, context, delWidgets).getRisposta();

      case "cambio-orario":
        return CambioOrario(body["id"], body["body"], datetime, context, delWidgets).getRisposta();

      case "steps":
        return StepsMessage(body["id"], body["body"], datetime, context, delWidgets).getRisposta();
    }
  }
}
