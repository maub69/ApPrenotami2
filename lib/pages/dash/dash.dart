import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mia_prima_app/pages/dash/lista_prenotazioni/prenotazione/notifiche/notifiche_manager.dart';
import 'calendari/calendario.dart';
import 'calendari/crea_appuntamento/crea_appuntamento.dart';
import '../global/info_app_basso.dart';
import 'impostazioni/settings.dart';
import 'lista_prenotazioni/prenotazione/processo/steps.dart';
import 'lista_prenotazioni/lista_prenotazioni.dart';
import 'package:mia_prima_app/main.dart';
import '../global/model.dart';
import 'package:mia_prima_app/utility/converti_settimana_in_calendario.dart';
import 'package:mia_prima_app/utility/download_json.dart';
import 'package:http/http.dart' as http;
import 'package:mia_prima_app/utility/endpoint.dart';
import 'package:mia_prima_app/utility/utility.dart';
import 'lista_prenotazioni/prenotazione/visualizza_prenotazione.dart';
import 'dart:ui';
import 'package:intl/intl.dart' as intl;

/// Pagina Dashboard che contiene il menu principale
class Dash extends StatefulWidget {
  final String idCalendario;

  Dash({this.idCalendario});

  @override
  State createState() => _StateDash();
}

class _StateDash extends State<Dash> {
  Function onPressedCalendario;
  Function onPressedListaPrenotazioniFuture;
  Function onPressedNotifiche;
  int _numNotifiche = 0;
  List<Widget> _listCalendari = [
    Center(
      child: SizedBox(
        width: 50,
        height: 50,
        child: CircularProgressIndicator(),
      ),
    )
  ];

  /// scarica i calendari che vengono visualizzati a scorrimento orizzontale
  void updateCalendario() {
    DownloadJson downloadJson = new DownloadJson(
        url: EndPoint.GET_CALENDARI_AZIENDA,
        parametri: {"id_azienda": widget.idCalendario},
        letturaTerminata: letturaTerminataCalendarioRichieste);
    downloadJson.start();
  }

  @override
  void initState() {
    super.initState();

    Utility.updateCalendario = updateCalendario;
    updateCalendario();

    DownloadJson downloadJsonListaPrenotazioni = new DownloadJson(
        url: EndPoint.GET_LISTA_PRENOTAZIONI,
        // passo al parametro letturaTerminata la funzione letturaTerminata
        // che verrà eseguita nella classe DownloadJson
        letturaTerminata: letturaTerminataListaPrenotazioni);
    // funzione presente nella classe DownloadJson tramite url lancia la funzione
    downloadJsonListaPrenotazioni.start();

    DownloadJson downloadNotifiche = new DownloadJson(
        url: EndPoint.GET_LISTA_PRENOTAZIONI,
        // passo al parametro letturaTerminata la funzione letturaTerminata
        // che verrà eseguita nella classe DownloadJson
        letturaTerminata: letturaTerminataNotifiche);
    // funzione presente nella classe DownloadJson tramite url lancia la funzione
    downloadNotifiche.start();
  }

  /// legge i dati in risposta dal server, li pulisce e li mette in un json
  /// che verrà utilizzato per vedere la lista delle prenotazioni disponibili nell'app
  letturaTerminataListaPrenotazioni(http.Response data) {
    if (data.statusCode == 200) {
      Utility.listaPrenotazioni = jsonDecode(data.body);

      /// per ogni calendario sono presenti dei messaggi non letti, vengono tutti sommati per essere poi visualizzati sopra il bottone
      /// che ti fa visualizzare la lista delle prenotazioni
      _numNotifiche = 0;
      Utility.listaPrenotazioni.forEach((element) {
        _numNotifiche += element["msg_non_letti"];
      });

      onPressedListaPrenotazioniFuture = () {
        _onPressedListaPrenotazioniFuture();
      };

      /// permette di aprire automaticamente un appuntamento nel caso nel quale sia stata cliccata una notifica ad app chiusa
      if (idAppuntamento != "-1") {
        // se idAppuntamento != "-1", allora cio' significa che e' presente un appuntamento da aprire
        // viene cercato l'appuntamento tra la lista degli appuntamenti e poi viene aperto con VisualizzaPrenotazioneFutura
        // il parametro aggiornaPrenotazioni permette di modificare la listaPrenotazioni con le nuove info sulla prenotazione
        // non e' necessario aprire la schermata della lista delle prenotazioni, in quanto sono già presenti tutte le info per aprire la sezione di dettaglio da questa schermata
        int idAppuntamentoAprire = -1;
        for (int i = 0; i < Utility.listaPrenotazioni.length; i++) {NotificheManager notificheManager = new NotificheManager(
              dataAppuntamento: intl.DateFormat("yyyy-MM-dd HH:mm:ss")
                  .parse(Utility.listaPrenotazioni[i]["start"]),
              idAppuntamento: Utility.listaPrenotazioni[i]["id"].toString(),
              nomeAppuntamento: Utility.listaPrenotazioni[i]
                  ["calendario_nome"]);
          notificheManager.start();
          if (Utility.listaPrenotazioni[i]["id"].toString() == idAppuntamento) {
            idAppuntamentoAprire = i;
          }
        }
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => VisualizzaPrenotazione(
                    prenotazione:
                        Utility.listaPrenotazioni[idAppuntamentoAprire])));
      }
      setState(() {});
    }
  }

  letturaTerminataNotifiche(http.Response data) {
    if (data.statusCode == 200) {
      List<dynamic> listaNotifiche = jsonDecode(data.body);
      onPressedNotifiche = () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => Scaffold(
                  appBar: AppBar(title: Text("Esempio")),
                  body: Steps(
                      json:
                          '{"title": "Processo olive", "started": true, "description": "Le varie fasi per spremere le olive","steps": [{"name": "Fase 1","done": true,"messages": ["prima sotto fase fatta", "seconda sotto fase fatta"]},{"name": "Fase 2", "done": true, "messages": ["prima sotto fase fatta 2","seconda sottofase fatta 2"]}]}')),
            ));
      };
      setState(() {});
    }
  }

  /// funzione usata da updateCalendario per pulire il json dei calendari e visualizzarli a video
  letturaTerminataCalendarioRichieste(http.Response data) {
    if (data.statusCode == 200) {
      Utility.calendari = [];
      List<dynamic> results = jsonDecode(data.body);

      /// per ogni calendario effettua la conversione del suo body in una lista di disponibilità
      /// per poi inserire quelle disponibilità all'interno di un oggetto più grande CalendarioBox
      /// al quale ad ogni gruppo di disponibilità viene associato l'id del calendario e il nome
      /// esistono questi due blocchi separati in quanto all'inizio l'app prevedeva un solo calendario
      /// mentre successivamente si è deciso di averne di più, di conseguenza avendo liste diverse
      /// era diventato necessario creare un oggetto più grande che le identificasse univocamente
      results.forEach((element) {
        ConvertSettimanaInCalendario convertSettimana =
            new ConvertSettimanaInCalendario(results: element["body"]);
        CalendarioBox calendarioBox = CalendarioBox(
            id: element["id"],
            name: element["name"],
            appuntamenti: convertSettimana.getCalendarioDisponibilita());
        Utility.calendari.add(calendarioBox);
      });

      /// a partire dalla lista dei calendari genera una nuova lista di widget per creare poi la lista orizzontale con tutti i calendari
      _listCalendari = [];
      Utility.calendari.forEach((element) {
        _listCalendari.add(
          GestureDetector(
            onTap: () {
              Utility.idCalendarioAperto = element.id;
              _onPressedCal(Utility.calendari
                  .where((e) => e.id == element.id)
                  .first
                  .appuntamenti);
            },
            child: Container(
              margin: EdgeInsets.only(left: 5, right: 5, top: 10, bottom: 10),
              decoration: BoxDecoration(
                color: Color(0xA9000000),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 7,
                    offset: Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
              width: ((Utility.calendari.length < 3)
                  ? (Utility.width - 30) / Utility.calendari.length -
                      ((Utility.calendari.length == 1) ? 0 : 10)
                  : 160),
              child: Center(
                  child: Text(element.name,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 16))),
            ),
          ),
        );

        element.appuntamenti.forEach((element) {
          element.showMessage = _showMessage;
        });
      });
      setState(() {});
    } else {
      print("Erorre: ${data.statusCode}");
    }
  }

  /// quanto viene fatta una richiesta di una nuova prenotazione da un calendario, l'utente viene riportato sulla dash
  /// quando viene riportato sulla dash dal basso cmpare un messaggio nel quaòe viene specificato l'effettivo svolgimento dell'operazione
  /// per fare ciò però è necessario che la classe dell'appuntamento lanci una funzione in questa classe al fine di far visualizzare
  /// la snackBar in questa pagina, questo è il motivo per cui ad ogni appuntamento prenotabile del calendario viene passata
  /// in ingresso questa funzione
  void _showMessage(String title, String body, String messageAdmin, Color color) {
    // per funzionare necessita di utilizzare un context, sul quale poi appunto si applica la funzione showSnackBar
    // il problema pero' e' che non può essere utilizzato lo stesso context dello statefulwidget, percio' contextGlobal non puo essere usato
    // cio' significa che bisogna utilizzare un nuovo context, per fare cio' bisogna crearlo con l'oggetto Builder che si trova piu' sotto
    ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
      content: Column(
          children: [
            Text(title, style: TextStyle(fontSize: 20)),
            Text(body, style: TextStyle(fontSize: 15)),
            Text(messageAdmin, style: TextStyle(fontSize: 10))
          ],
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start),
      backgroundColor: color,
      duration: Duration(seconds: 10),
    ));
  }

  /// questa funzione avvia la pagina che permette di visualizzare il calendario con tutte le disponibilità di appuntamento
  /// a questa funzione viene passata in ingresso solamente la lista delle disponibilità del calendario, perciò si perde
  /// l'informazione di appartenenza al calendario di quelle disponibilità
  /// tuttavia poco prima del lancio di questa funzione viene salvato l'id del calendario
  /// sulla variabile globale Utility.idCalendarioAperto, in questo modo la richiesta di disponibilità
  /// verrà inviata al calendario corretto
  _onPressedCal(List<Disponibilita> meetings) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => Calendario(
            calendario: meetings,
            /// viene specificato in ingresso come ci si deve comportare quand si clicca su un appuntamento
            /// il quale andrà sempre ad aprire una pagina per la richiesta di un appuntamento
            onTapDisponibilita: (Disponibilita appuntamento) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => CreaAppuntamento(
                    disponibilita: appuntamento,
                    idCalendario: widget.idCalendario,
                  ),
                ),
              );
              print("risposta: ${appuntamento.descrizione}");
            }),
      ),
    );
  }

  _onPressedListaPrenotazioniFuture() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => ListaPrenotazioni())).then((_) {
      /// questo then serve per quando la pagina viene chiusa, cioè si torna indietro fino alla home
      /// e perciò deve essere ricalcolato il numero di notifiche per poi essere visualizzato
      setState(() {
        _numNotifiche = 0;
        Utility.listaPrenotazioni.forEach((element) {
          _numNotifiche += element["msg_non_letti"];
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Model.stackContext.push(context);
    // return Text("${widget.utente.username} - ${widget.utente.email}");
    return Model(
      confermaChiusura: true,
      showAppbar: true,
      actions: [
        IconButton(
            icon: const Icon(
              Icons.settings,
              color: Colors.white,
            ),
            tooltip: "Filtra",
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => Settings()));
            })
      ],
      body: new Builder(builder: (BuildContext context) {
        return Column(children: [
          Container(
            height: Utility.height -
                100 -
                MediaQueryData.fromWindow(window).padding.top,
            padding: EdgeInsets.all(10),
            child: Padding(
              padding: EdgeInsets.all(10),
              child: ListView(children: [
                CachedNetworkImage(
                  imageUrl:
                      EndPoint.getUrl(EndPoint.LOGO) + Utility.idApp + ".png",
                  height: 200,
                  fadeInDuration: Duration(seconds: 0),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.arrow_back_rounded,
                          color: Colors.black87,
                          size: 25.0,
                          textDirection: TextDirection.ltr,
                          semanticLabel: 'Icon',
                        ),
                        Flexible(
                          child: Padding(
                              padding: EdgeInsets.only(left: 10, right: 10),
                              child: Text(
                                  "Scorri orizzontalmente l'elenco sottostante per scegliere dove effettuare la prenotazione",
                                  textAlign: TextAlign.center,
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                        ),
                        Icon(Icons.arrow_back_rounded,
                            color: Colors.black87,
                            size: 25.0,
                            textDirection: TextDirection.rtl,
                            semanticLabel: 'Icon'),
                      ]),
                ),
                Container(
                  height: 135,
                  padding: EdgeInsets.only(bottom: 15),
                  margin: EdgeInsets.only(bottom: 20),
                  child: Center(
                    child: ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: _listCalendari.length,
                      itemBuilder: (context, i) {
                        return _listCalendari[i];
                      },
                    ),
                  ),
                ),
                Stack(children: [
                  Container(
                      padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 70),
                              primary: Colors.green[900]),
                          child: Stack(
                            children: <Widget>[
                              // Stroked text as border.
                              Text(
                                'Lista appuntamenti',
                                style: TextStyle(
                                  fontSize: 20,
                                  foreground: Paint()
                                    ..style = PaintingStyle.stroke
                                    ..strokeWidth = 1
                                    ..color = Colors.black,
                                ),
                              ),
                              Text(
                                'Lista appuntamenti',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          onPressed: onPressedListaPrenotazioniFuture)),
                  ((_numNotifiche != 0)
                      ? Utility.getBoxNotification(_numNotifiche)
                      : Container())
                ])
              ]),
            ),
          ),
          InfoAppBasso.getInfoContainer()
        ]);
      }),
    );
  }
}
