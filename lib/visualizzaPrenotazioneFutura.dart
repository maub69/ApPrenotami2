import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:loading/indicator/ball_pulse_indicator.dart';
import 'package:loading/loading.dart';
import 'package:mia_prima_app/chatpage.dart';
import 'package:mia_prima_app/model.dart';
import 'package:http/http.dart' as http;
import 'package:mia_prima_app/notificationSender.dart';
import 'package:mia_prima_app/steps.dart';
import 'package:mia_prima_app/utility/endpoint.dart';
import 'package:mia_prima_app/utility/utility.dart';

class VisualizzaPrenotazioneFutura extends StatefulWidget {
  final dynamic prenotazione;

  VisualizzaPrenotazioneFutura({this.prenotazione});

  @override
  State createState() => _StateVisualizzaPrenotazioneFutura();
}

class _StateVisualizzaPrenotazioneFutura
    extends State<VisualizzaPrenotazioneFutura> {
  Widget buttonElimina = Text("Elimina", style: TextStyle(color: Colors.red));

  // value --> // 1=richiesta annullamento, 2=elimina, 3=archivia
  void onClickElimina(int type, String description,
      {String title, String doButtonText}) async {
    String response = "1";
    if (title != null) {
      TextEditingController testoController = TextEditingController();
      //qui viene chiamato il dialog e la schermata rimane in attesa finche' non viene fornita una risposta
      response = await showDialog<String>(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Color(0xFD292929),
            content: Column(children: [
              Padding(
                  padding: EdgeInsets.only(bottom: 15),
                  child: Text("RICHIESTA ANNULLAMENTO", style: TextStyle(color: Colors.blue[400], fontSize: 16, fontWeight: FontWeight.bold))),
              Padding(
                  padding: EdgeInsets.only(bottom: 15),
                  child: Text(title, textAlign: TextAlign.justify, style: TextStyle(color: Colors.white))),
              TextField(
                style: TextStyle(color: Colors.white),
                keyboardType: TextInputType.multiline,
                minLines: 3,
                maxLines: null,
                cursorColor: Colors.white,
                controller: testoController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Inserisci la motivazione',
                  labelStyle: TextStyle(color: Colors.white),

                ),
              )
            ], mainAxisSize: MainAxisSize.min),
            actions: <Widget>[
              TextButton(
                  child: Text(doButtonText, style: TextStyle(fontSize: 15)),
                  onPressed: () =>
                      Navigator.pop(context, testoController.text)),
              TextButton(
                  child: const Text('ANNULLA', style: TextStyle(fontSize: 15)),
                  // Return "No" when dismissed.
                  onPressed: () => Navigator.pop(context, '-1')),
            ],
          );
        },
      );
    }

    //se la risposta e' uguale a -1 signica che e' stato cliccato "Annulla"
    if (response != "-1") {
      //qui si va a sostiuire il testo del bottone con un caricamento
      buttonElimina = Loading(
          indicator: BallPulseIndicator(), size: 40.0, color: Colors.red);
      setState(() {});

      //qui si fa partire la richiesta e poi si gestira' il fatto di uscire dalla pagina e di tornare alla precedente
      http.post(Uri.parse(EndPoint.getUrlKey(EndPoint.DEL_PRENOTAZIONE)),
          body: {
            "motivo": response,
            "type": type.toString(),
            "id_appuntamento": widget.prenotazione["id"].toString()
          }).then((value) {
        Map<String, dynamic> jsonBody = jsonDecode(value.body);
        if (jsonBody["new_element"]["type"] == -4) {
          widget.prenotazione["prev_type"] = widget.prenotazione["type"];
        }
        widget.prenotazione["type"] = jsonBody["new_element"]["type"];
        _showMessage(
            Utility.getNameStateAppuntamento(jsonBody["new_element"]["type"])
                    .substring(0, 1) +
                Utility.getNameStateAppuntamento(
                        jsonBody["new_element"]["type"])
                    .substring(1)
                    .toLowerCase(),
            description,
            Colors.green[900]);
        if (type == 2) {
          Navigator.pop(context);
          Utility.deletePrenotazione(widget.prenotazione["id"].toString());
          Utility.listaPrenotazioni.remove(widget.prenotazione);
        } else {
          setState(() {});
        }
      });
    }
  }

  void _showMessage(String title, String body, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
      content: Column(
          children: [
            Text(title, style: TextStyle(fontSize: 20)),
            Text(body, style: TextStyle(fontSize: 15)),
          ],
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start),
      backgroundColor: color,
      duration: Duration(seconds: 10),
    ));
  }

  @override
  void initState() {
    super.initState();
    print(widget.prenotazione);
  }

  @override
  Widget build(BuildContext context) {
    Widget card = Material(
        key: Key(Random()
            .nextInt(100000)
            .toString()), //IMPORTANTE, perche' altrimenti visualizzerebbe ancora i widget vecchi, perche' userebbe quelli in cache
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Color(0xA9000000),
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10)),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 7,
                offset: Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
          margin: EdgeInsets.only(left: 8, right: 8, top: 10),
          padding: EdgeInsets.only(top: 6, bottom: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                  padding: EdgeInsets.only(bottom: 2),
                  child: Center(
                      child: Text(widget.prenotazione["calendario_nome"],
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          )))),
              Padding(
                padding: EdgeInsets.only(left: 15, right: 15),
                child: Center(
                  child: Text(
                      'Data richiesta: ' +
                          Utility.formatStringDatefromString(
                              "yyyy-MM-dd HH:mm:ss",
                              "dd/MM/yyyy HH:mm",
                              widget.prenotazione["richiesto"]),
                      style: TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                ),
              ),
              widget.prenotazione['type'] == -2 ? Padding(
                  padding: EdgeInsets.only(top: 5, left: 15, right: 15),
                  child: Center(
                    child: Text(
                        'Richiesta cancellazione: ' +
                            Utility.formatStringDatefromString(
                                "yyyy-MM-dd HH:mm:ss",
                                "dd/MM/yyyy HH:mm",
                                widget.prenotazione["richiesto_cancellazione"]),
                        style: TextStyle(
                            fontSize: 13,
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                  ),
                ) : Container(),
              Padding(
                padding:
                    EdgeInsets.only(left: 15, right: 15, bottom: 5, top: 10),
                child: Text(widget.prenotazione["calendario_descrizione"],
                    textAlign: TextAlign.justify,
                    style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
              Padding(
                  padding: EdgeInsets.only(left: 12, right: 12),
                  child: Divider(color: Colors.white30, thickness: 1.5)),
              Center(
                  child: Container(
                decoration: BoxDecoration(
                    color: Utility.getColorStateAppuntamento(
                        widget.prenotazione["type"]),
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10))),
                padding:
                    EdgeInsets.only(top: 5, bottom: 5, left: 20, right: 20),
                margin: EdgeInsets.only(bottom: 5),
                child: Text(
                    Utility.getNameStateAppuntamento(
                        widget.prenotazione["type"]),
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              )),
              Padding(
                padding: EdgeInsets.only(left: 15, right: 15, bottom: 10),
                child: Text(widget.prenotazione["message_admin"],
                    style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
              Padding(
                padding: EdgeInsets.only(left: 15, right: 15, bottom: 5),
                child: Text(
                    'Data appuntammento: ' +
                        Utility.formatStringDatefromString(
                            "yyyy-MM-dd HH:mm:ss",
                            "dd/MM/yyyy HH:mm",
                            widget.prenotazione["start"]),
                    style: TextStyle(fontSize: 16, color: Colors.white)),
              )
            ],
          ),
        ));

    List<Widget> listWidget = [
      card,
      /*Text(
          "#" +
              widget.prenotazione["id"].toString() +
              " " +
              widget.prenotazione["calendario_nome"],
          style: TextStyle(fontSize: 30)),
      Text(widget.prenotazione["calendario_descrizione"],
          style: TextStyle(fontSize: 20)),
      Text(widget.prenotazione["start"], style: TextStyle(fontSize: 15)),
      Text(widget.prenotazione["end"], style: TextStyle(fontSize: 15)),
      Text(widget.prenotazione["message"], style: TextStyle(fontSize: 15)),
      Text(widget.prenotazione["message_admin"],
          style: TextStyle(fontSize: 15)),
      Text(widget.prenotazione["type"].toString(),
          style: TextStyle(fontSize: 15)),
      RaisedButton(
          onPressed: () {
            print("Vai alla chat");
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ChatPage(
                      idAppuntamento: widget.prenotazione["id"],
                      indexPrenotazioni: widget.indexPrenotazioni)),
            ).then((value) {
              NotificationSender notificationSender = NotificationSender();
              notificationSender.configureFirebaseNotification();
            });
          },
          child: Text("Vai alla chat")),
      RaisedButton(onPressed: onClickElimina, child: buttonElimina),*/
    ];

    if (widget.prenotazione["steps"] != null) {
      listWidget.add(Steps(json: widget.prenotazione['steps']));
    }

    List<Widget> actions = [];
    if (widget.prenotazione["type"] == 2 ||
        widget.prenotazione["type"] == 1 ||
        widget.prenotazione["type"] == 0) {
      actions = [
        PopupMenuButton<int>(
            itemBuilder: (BuildContext context) => <PopupMenuItem<int>>[
                  new PopupMenuItem<int>(
                      value: 1,
                      child: Row(
                        children: [
                          Icon(
                            Icons.cancel,
                            color: Color(0xA9000000),
                            size: 25.0,
                            semanticLabel: 'Richiesta di annullamento',
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 5),
                            child: Text("Richiesta di annullamento",
                                style: TextStyle(fontSize: 17)),
                          )
                        ],
                      ))
                ],
            onSelected: (int value) {
              onClickElimina(
                value,
                "L'operazione è in corso",
                title:
                    "Specifica il motivo per il quale vuoi annullare la prenotazione. Questa operazione non è istantanea, ma necessità di essere approvata.",
                doButtonText: "INVIA RICHIESTA",
              );
            })
      ];
    } else if (widget.prenotazione["type"] == -1 ||
        widget.prenotazione["type"] == -3 ||
        widget.prenotazione["type"] == -4) {
      actions = [
        PopupMenuButton<int>(
            itemBuilder: (BuildContext context) => <PopupMenuItem<int>>[
                  new PopupMenuItem<int>(
                      value: 2,
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete,
                            color: Color(0xA9000000),
                            size: 25.0,
                            semanticLabel: 'Elimina',
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 5),
                            child:
                                Text("Elimina", style: TextStyle(fontSize: 17)),
                          )
                        ],
                      )),
                  new PopupMenuItem<int>(
                      value: 3,
                      child: Row(
                        children: [
                          Icon(
                            Icons.archive,
                            color: Color(0xA9000000),
                            size: 25.0,
                            semanticLabel: 'Archivia',
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 5),
                            child: Text("Archivia",
                                style: TextStyle(fontSize: 17)),
                          )
                        ],
                      ))
                ],
            onSelected: (int value) {
              onClickElimina(value, "L'operazione è stata eseguita");
            })
      ];
    } else if (widget.prenotazione["type"] == -5) {
      actions = [
        PopupMenuButton<int>(
            itemBuilder: (BuildContext context) => <PopupMenuItem<int>>[
                  new PopupMenuItem<int>(
                      value: 2,
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete,
                            color: Color(0xA9000000),
                            size: 25.0,
                            semanticLabel: 'Elimina',
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 5),
                            child:
                                Text("Elimina", style: TextStyle(fontSize: 17)),
                          )
                        ],
                      )),
                      new PopupMenuItem<int>(
                      value: 4,
                      child: Row(
                        children: [
                          Icon(
                            Icons.settings_backup_restore_rounded,
                            color: Color(0xA9000000),
                            size: 25.0,
                            semanticLabel: 'Ripristina',
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 5),
                            child:
                                Text("Ripristina", style: TextStyle(fontSize: 17)),
                          )
                        ],
                      ))
                ],
            onSelected: (int value) {
              onClickElimina(value, "L'operazione è stata eseguita");
            })
      ];
    }

    return Model(
        actions: actions,
        body: ListView(children: listWidget),
        floatingActionButton: Stack(
          children: [
            Container(
              padding: EdgeInsets.only(top: 6, right: 6),
              child: FloatingActionButton(
                  backgroundColor: Colors.green[900],
                  child: Icon(
                    Icons.chat,
                    color: Colors.white,
                    size: 30.0,
                    semanticLabel: 'Chat',
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ChatPage(
                              idAppuntamento: widget.prenotazione["id"],
                              prenotazione: widget.prenotazione)),
                    ).then((value) {
                      setState(() {
                        NotificationSender notificationSender =
                            NotificationSender();
                        notificationSender.configureFirebaseNotification();
                      });
                    });
                  }),
            ),
            ((widget.prenotazione["msg_non_letti"] != 0)
                ? Utility.getBoxNotification(
                    widget.prenotazione["msg_non_letti"],
                    hasIcon: true)
                : Text(""))
          ],
        ));
  }
}
