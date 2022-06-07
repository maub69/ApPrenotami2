import 'package:flutter/material.dart';
import 'package:mia_prima_app/pages/dash/calendari/calendario.dart';
import 'package:mia_prima_app/pages/dash/lista_prenotazioni/prenotazione/chat/risposte/risposta.dart';
import 'package:mia_prima_app/utility/request_http.dart';
import '../../message_tile.dart';
import 'package:mia_prima_app/utility/endpoint.dart';
import 'package:mia_prima_app/utility/utility.dart';
import 'package:http/http.dart' as http;

class CambioOrario extends Risposta {
  final int idCalendario;

  CambioOrario(
      String idChat,
      Map<String, dynamic> body,
      DateTime datetime,
      this.idCalendario,
      BuildContext context,
      Function(List<Widget> listWidgets) delWidgets)
      : super(idChat, body, datetime, context, delWidgets);

  @override
  String get type => "cambio-orario";

  @override
  List<Widget> getRisposta() {
    return [
      MessageTile(
        messageText: body["message"],
        isLeft: true,
        datetime: datetime,
        idChat: idChat,
      ),
      getBottoniScelte(body["scelte"], body["proponi-orario"])
    ];
  }

  /*
    Qua sostanzialmente viene restituito il container contenente i bottoni delle scelte, che sara' composto dai bottoni nella lista body["scelte"], ma anche eventualmente da proponiOrario
  */
  Widget getBottoniScelte(List<dynamic> scelte, bool proponiOrario) {
    Container containerResponse;
    List<Widget> listBottoni = [];
    /*
      Inserisco sempre nella prima posizione per poi fare il reverse della listView e avere tutto allineato a destra
    */

    ButtonStyle buttonStyle = ButtonStyle(
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.0))));

    scelte.forEach((element) {
      listBottoni.insert(
          0,
          Padding(
            padding: EdgeInsets.only(left: 10),
            child: ElevatedButton(
                child: Text(element),
                style: buttonStyle,
                // quando viene cliccato, viene inviata al server la tua scelta. E poi ritorna la risposta, non direttamente, ma tramite una notifica di Firebase onMessage
                onPressed: () {
                  RequestHttp.post(
                      Uri.parse(EndPoint.getUrlKey(EndPoint.MESSAGGIO_CHAT)),
                      body: {
                        "appuntamento_id": idChat.toString(),
                        "messaggio_id": body["id"].toString(),
                        "type": "cambio_orario",
                        "is_proposta": "0",
                        "text": element.toString()
                      }).then((value) {
                    delWidgets([containerResponse]);
                    //risulta importante aggiornare il calendario in quanto dopo un cambio di orario o comunque un cambio di info dell'appuntamento il calendario potrebbe aver subito delle variazioni
                    Utility.updateCalendario();
                    Utility.updateAppuntamenti();
                  });
                }),
          ));
    });

    if (proponiOrario) {
      listBottoni.insert(
          0,
          Padding(
              padding: EdgeInsets.only(left: 20),
              child: ElevatedButton(
                  child: Text("Scegli l'orario"),
                  style: buttonStyle,
                  // qua viene aperto il calendario e viene gestito il click sulla disponibilita, anche se quello viene fatto nella funzione callQuandoDisponiblitaOn
                  onPressed: () {
                    Utility.idCalendarioAperto = idCalendario;
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) => Calendario(
                                calendario: Utility.calendari
                                    .where(
                                        (element) => element.id == idCalendario)
                                    .first
                                    .appuntamenti,
                                onTapDisponibilita: (disponibilita) {
                                  Utility.idCalendarioAperto = idCalendario;
                                  callQuandoDisponibilitaOn(
                                      disponibilita, containerResponse);
                                  Navigator.pop(context);
                                })));
                  })));
    }

    containerResponse = Container(
        height: 50,
        child:
            ListView(scrollDirection: Axis.horizontal, children: listBottoni));

    return containerResponse;
  }

  /*
    Si occupa di gestire l'onClick sulla disponibilita' del calendario
  */
  void callQuandoDisponibilitaOn(
      Disponibilita disponibilita, Container containerResponse) {
    print(disponibilita.from);
    print(disponibilita.to);
    //in conformita a quanto scritto su postman viene inviata la richiesta al server
    RequestHttp.post(Uri.parse(EndPoint.getUrlKey(EndPoint.MESSAGGIO_CHAT)), body: {
      "appuntamento_id": idChat.toString(),
      "messaggio_id": body["id"].toString(),
      "type": "cambio_orario",
      "is_proposta": "1",
      "start_proposta": disponibilita.from.toString(),
      "end_proposta": disponibilita.to.toString()
    }).then((value) {
      delWidgets([containerResponse]);
      //risulta importante aggiornare il calendario in quanto dopo un cambio di orario o comunque un cambio di info dell'appuntamento il calendario potrebbe aver subito delle variazioni
      Utility.updateCalendario();
    });
  }
}
