import 'package:flutter/cupertino.dart';
import 'package:mia_prima_app/pages/dash/lista_prenotazioni/prenotazione/chat/risposte/risposta.dart';
import 'package:mia_prima_app/pages/dash/lista_prenotazioni/prenotazione/chat/risposte/widget/cambioOrario.dart';
import 'package:mia_prima_app/pages/dash/lista_prenotazioni/prenotazione/chat/risposte/widget/file.dart';
import 'package:mia_prima_app/pages/dash/lista_prenotazioni/prenotazione/chat/risposte/widget/free.dart';
import 'package:mia_prima_app/pages/dash/lista_prenotazioni/prenotazione/chat/risposte/widget/photo.dart';
import 'package:mia_prima_app/pages/dash/lista_prenotazioni/prenotazione/chat/risposte/widget/stepsMessage.dart';
import 'package:mia_prima_app/pages/dash/lista_prenotazioni/prenotazione/chat/risposte/widget/video.dart';

/// la classe che dato in ingresso il tipo di messaggio che si vuole avere in risposta
/// e passati i parametri corrispondenti, restituisce il widget da visualizzare
class RispostaFactory {
  static ResponseRispostaFactory getRisposta(
      String type,
      Map<String, dynamic> body,
      BuildContext context,
      Function(List<Widget> listWidget) delWidgets,
      String idAppuntamento) {
    DateTime datetime = DateTime.parse(body["datetime"]);
    switch (type) {
      case "free":
        return ResponseRispostaFactory(
            Free(body["id"], body["body"], datetime, context, delWidgets),
            datetime);

      case "cambio-orario":
        return ResponseRispostaFactory(
            CambioOrario(
                body["id"], body["body"], datetime, body["id_calendario"], context, delWidgets),
            datetime);

      case "steps":
        return ResponseRispostaFactory(
            StepsMessage(
                body["id"], body["body"], datetime, context, delWidgets),
            datetime);

      case "photo":
        return ResponseRispostaFactory(
            Photo(body["id"], body["body"], datetime, context, delWidgets,
                idAppuntamento),
            datetime);

      case "video":
        return ResponseRispostaFactory(
            Video(body["id"], body["body"], datetime, context, delWidgets,
                idAppuntamento),
            datetime);

      case "file":
        return ResponseRispostaFactory(
            File(body["id"], body["body"], datetime, context, delWidgets,
                idAppuntamento),
            datetime);
    }
  }
}

/// quest è la risposta della classe sopra. Se è presente un oggetto response, allora
/// restituisce questo, in quanto ciò significa che quel ResponseRispostaFactory è stato
/// dato in risposta dalla classe sopra, altrimenti che response è nullo, la funzione
/// get widget restituirà direttamente il widget che ha avuto in ingresso, questo
/// per risolvere un problema che era nato in fase di scrittura del codice, cioè
/// che non sempre gli oggetti da visualizzare passavano per in factory, erò per
/// poterli inserire nel flusso degli oggetti da visualizzare era necessario farli passare
/// per un factory
class ResponseRispostaFactory {
  final List<Widget> widgetsRisposta;
  final Risposta response;
  final DateTime dateTime;

  ResponseRispostaFactory(this.response, this.dateTime, [this.widgetsRisposta]);

  List<Widget> get widgets {
    if (response != null) {
      return response.getRisposta();
    } else {
      return widgetsRisposta;
    }
  }
}
