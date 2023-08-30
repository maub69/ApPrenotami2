import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading/indicator/ball_pulse_indicator.dart';
import 'package:loading/loading.dart';
import 'package:mia_prima_app/pages/dash/lista_prenotazioni/prenotazione/notifiche/notifiche_manager.dart';
import 'package:mia_prima_app/pages/dash/lista_prenotazioni/prenotazione/popup_add_notifica.dart';
import 'package:mia_prima_app/utility/request_http.dart';
import 'chat/chat_page.dart';
import '../../../global/model.dart';
import '../../../../utility/notification_sender.dart';
import 'processo/steps.dart';
import 'package:mia_prima_app/utility/endpoint.dart';
import 'package:mia_prima_app/utility/utility.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class VisualizzaPrenotazione extends StatefulWidget {
  final dynamic prenotazione;
  final int cardPos;
  final Function(int, bool) delWidget;

  VisualizzaPrenotazione({this.prenotazione, this.cardPos, this.delWidget});

  @override
  State createState() => _StateVisualizzaPrenotazione();
}

class _StateVisualizzaPrenotazione extends State<VisualizzaPrenotazione> {
  Widget buttonElimina = Text("Elimina", style: TextStyle(color: Colors.red));
  NotificheManager _notificheManager;
  Random _random = Random();
  TextEditingController testoController;

  /// funzione che apre il popup per richiedere la cancellazione e invia la richiesta
  /// il campo description specifica cosa deve essere visualizzato in risposta all'utente
  /// una volta che viene inviata la richiesta di annullamento
  /// possono esserci messaggi diversi in quanto a volte gli appuntamenti sono cancellabili in automatico
  /// altre volte no
  // value --> // 1=richiesta annullamento, 2=elimina, 3=archivia
  void onClickElimina(int type, String description,
      {String title, String doButtonText}) async {
    String response = "1";
    if (title != null) {
      testoController = TextEditingController();
      /// qui viene chiamato il dialog e la schermata rimane in attesa finche' non viene fornita una risposta
      response = await showDialog<String>(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15.0))),
            backgroundColor: Color(0xFD292929),
            content: Column(children: [
              Padding(
                  padding: EdgeInsets.only(bottom: 15),
                  child: Text("RICHIESTA ANNULLAMENTO",
                      style: TextStyle(
                          color: Colors.blue[400],
                          fontSize: 16,
                          fontWeight: FontWeight.bold))),
              Padding(
                  padding: EdgeInsets.only(bottom: 15),
                  child: Text(title,
                      textAlign: TextAlign.justify,
                      style: TextStyle(color: Colors.white))),
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

    /// se la risposta e' uguale a -1 significa che e' stato cliccato "Annulla"
    if (response != "-1") {
      /// qui si va a sostituire il testo del bottone con un caricamento
      buttonElimina = Loading(
          indicator: BallPulseIndicator(), size: 40.0, color: Colors.red);
      setState(() {});

      // TODO far si che quando la richiesta viene inviata si aggiorni anche l'interfaccia in tempo reale, quindi capire come gestire il delWidget per questa situazione
      if (type == 1) {
        RequestHttp.post(Uri.parse(EndPoint.getUrlKey(EndPoint.RICHIESTA_ANNULLAMENTO)),
            body: {
              "id_appuntamento": widget.prenotazione["id"].toString(),
              "messaggio": testoController.text
            }).then((value) {
          // widget.delWidget(widget.cardPos, false);
          Navigator.of(context).pop();
        });
      } else if (type == 2 || type == 3) {
        print("url--->" + Uri.parse(EndPoint.getUrlKey(type == 2 ? EndPoint.CANCELLA_APPUNTAMENTO : EndPoint.ARCHIVIA_APPUNTAMENTO)).toString());
        http.post(
            Uri.parse(EndPoint.getUrlKey(type == 2 ? EndPoint.CANCELLA_APPUNTAMENTO : EndPoint.ARCHIVIA_APPUNTAMENTO)),
            headers: {
              "Content-Type": "application/json",
              "Accept": "*/*"
            },
            body: jsonEncode({"id": widget.prenotazione["id"].toString()})).then((value) {
          if (value.statusCode == 200) {
            widget.delWidget(widget.cardPos, type == 2);
            Navigator.of(context).pop();
          } else {
            FlutterToast.showToast(
                msg: "Comando momentaneamente non eseguibile",
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.BOTTOM,
                backgroundColor: Color(0xFF616161),
                textColor: Colors.white,
                fontSize: 16.0);
            Navigator.of(context).pop();
          }
        });
      } else if (type == 4) {
        // TODO gestire il bottone ripristina su archivio, nel senso che deve toglierlo dalla sezione archiviati sia sul sistema locale che sul server
        RequestHttp.post(Uri.parse(EndPoint.getUrlKey(EndPoint.RIPRISTINA_DA_ARCHIVIO)),
            body: {
              "id_appuntamento": widget.prenotazione["id"].toString()
            }).then((value) {
              widget.delWidget(widget.cardPos, false);
              Navigator.of(context).pop();
            });
      } else {
        print("type: $type");
        /// qui si fa partire la richiesta e poi si gestira' il fatto di uscire dalla pagina e di tornare alla precedente
        RequestHttp.post(Uri.parse(EndPoint.getUrlKey(EndPoint.CANCELLA_PRENOTAZIONE)),
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
            widget.prenotazione['richiesto_cancellazione'] =
                Utility.getDateStringFromDateTime(
                    DateTime.now(), 'yyyy-MM-dd HH:mm:ss');
            setState(() {});
          }
        });
      }
    }
  }

  /// mostra il messaggio che parte dal basso dello schermo quando viene effettuata la richiesta di annulamento 
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
    _notificheManager = NotificheManager(
        dataAppuntamento: DateFormat("yyyy-MM-dd HH:mm:ss")
            .parse(widget.prenotazione["start"]),
        idAppuntamento: widget.prenotazione["id"].toString(),
        nomeAppuntamento: widget.prenotazione["calendario_nome"]);
    _notificheManager.start();
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
              widget.prenotazione['type'] == -2
                  ? Padding(
                      padding: EdgeInsets.only(top: 5, left: 15, right: 15),
                      child: Center(
                        child: Text(
                            'Richiesta cancellazione: ' +
                                Utility.formatStringDatefromString(
                                    "yyyy-MM-dd HH:mm:ss",
                                    "dd/MM/yyyy HH:mm",
                                    widget.prenotazione[
                                        "richiesto_cancellazione"]),
                            style: TextStyle(
                                fontSize: 13,
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ),
                    )
                  : Container(),
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

    /// rappresenta il box riguardante le notifiche che viene visualizzato
    /// è presente sotto forma di lista in quanto la prima riga è sempre presente
    /// poi tutte le righe che compongono la tabella sono presenti solo se ci sono notifiche
    List<Widget> listWidgetNotifiche = [
      Padding(
          padding: EdgeInsets.only(right: 15, left: 15),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text("Notifiche",
                style: TextStyle(
                  fontSize: 20,
                  color: Color(0xB4000000),
                  fontWeight: FontWeight.bold,
                )),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                    primary: Colors.green[900],
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(10)),
                child: Icon(Icons.notification_add),
                onPressed: () {
                  PopupAddNotifica.showMenu(
                      context: context,
                      callToSet: (int difference) {
                        setState(() {
                          _notificheManager.addNotificaDifference(difference);
                        });
                      });
                })
          ]))
    ];

    /// in base alle notifiche presenti nello scheduler vengono aggiunte le righe per visualizzarle ed eliminarle
    _notificheManager.notificheScheduler.forEach((element) {
      listWidgetNotifiche.add(Padding(
          padding: EdgeInsets.only(right: 15, left: 15),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(
                Utility.getDateStringFromDateTime(
                    element.start, "HH:mm dd/MM/yyyy"),
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xB4000000),
                  fontWeight: FontWeight.bold,
                )),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                    primary: Colors.red[900], shape: CircleBorder()),
                child: Icon(Icons.cancel, size: 15),
                onPressed: () {
                  setState(() {
                    _notificheManager.removeNotifica(element.id);
                  });
                })
          ])));
    });

    List<Widget> listWidget = [
      card,
      Container(
        margin: EdgeInsets.only(top: 8, right: 8, left: 8),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(width: 0.1),
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(10)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 3,
              blurRadius: 8,
              offset: Offset(0, 2), // changes position of shadow
            ),
          ],
        ),
        child: Column(children: listWidgetNotifiche),
      )
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
                            child: Text("Ripristina",
                                style: TextStyle(fontSize: 17)),
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
        body: ListView.builder(
            itemCount: listWidget.length,
            itemBuilder: ((context, index) {
              return Container(
                key: Key(_random.nextInt(100000).toString()),
                child: listWidget[index],
              );
            })),
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
