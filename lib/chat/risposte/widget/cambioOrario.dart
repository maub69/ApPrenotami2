import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:mia_prima_app/calendario.dart';
import 'package:mia_prima_app/chat/risposte/risposta.dart';
import 'package:mia_prima_app/messagetile.dart';
import 'package:mia_prima_app/utility/endpoint.dart';
import 'package:mia_prima_app/utility/utility.dart';
import 'package:http/http.dart' as http;

class CambioOrario extends Risposta {
  CambioOrario(int idChat, Map<String, dynamic> body, DateTime datetime,
      BuildContext context, Function(List<Widget> listWidgets) delWidgets)
      : super(idChat, body, datetime, context, delWidgets);

  @override
  List<Widget> getRisposta() {
    return [
      MessageTile(
        messageText: body["message"],
        isLeft: false,
        datetime: datetime,
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
    scelte.forEach((element) {
      listBottoni.insert(
          0,
          Padding(
            padding: EdgeInsets.only(right: 10),
            child: RaisedButton(
                child: Text(element),
                // quando viene cliccato, viene inviata al server la tua scelta. E poi ritorna la risposta, non direttamente, ma tramite una notifica di Firebase onMessage
                onPressed: () {
                  http.post(EndPoint.getUrlKey(EndPoint.MESSAGGIO_CHAT), body: {
                    "appuntamento_id": idChat.toString(),
                    "messaggio_id": body["id"].toString(),
                    "type": "cambio_orario",
                    "is_proposta": "0",
                    "text": element.toString()
                  }).then((value) {
                    delWidgets([containerResponse]);
                    //risulta importante aggiornare il calendario in quanto dopo un cambio di orario o comunque un cambio di info dell'appuntamento il calendario potrebbe aver subito delle variazioni
                    Utility.updateCalendario();
                  });
                }),
          ));
    });

    if (proponiOrario) {
      listBottoni.insert(
          0,
          RaisedButton(
              child: Text("Scegli l'orario"),
              // qua viene aperto il calendario e viene gestito il click sulla disponibilita, anche se quello viene fatto nella funzione callQuandoDisponiblitaOn
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => Calendario(
                            calendario: Utility.calendario,
                            onTapDisponibilita: (disponibilita) {
                              callQuandoDisponibilitaOn(
                                  disponibilita, containerResponse);
                              Navigator.pop(context);
                            })));
              }));
    }

    containerResponse = Container(
        height: 50,
        child: ListView(
            reverse: true,
            scrollDirection: Axis.horizontal,
            children: listBottoni));

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
    http.post(EndPoint.getUrlKey(EndPoint.MESSAGGIO_CHAT), body: {
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
