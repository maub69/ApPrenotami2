import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
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

  void updateCalendario() {
    DownloadJson downloadJson = new DownloadJson(
        url: EndPoint.GET_CALENDARI_AZIENDA,
        parametri: {
          "id_azienda": widget.idCalendario
        },
        // passo al parametro letturaTerminata la funzione letturaTerminata
        // che verrà eseguita nella classe DownloadJson
        letturaTerminata: letturaTerminataCalendarioRichieste);
    // funzione presente nella classe DownloadJson tramite url lancia la funzione
    downloadJson.start();
  }

  @override
  void initState() {
    super.initState();
    //questa classe serve a gestire le richieste get per scasricare i json. Necessita dell'url e della funzione da avviare una volta finito di scaricare il json.
    //la funzione letturaTerminata viene eseguita una votla che il json viene scaricato
    //si tratta di una classe generica e' puo' essere usata in qualsiasi contesto serva scaricare un json e poi eseguire una funzione su di esso, NON solo strettamente per il calendario

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

  int impostaGiorno(int giornoJson) {
    var currDt = DateTime.now();
    int oggi = currDt.weekday;
    int giornoGiusto = oggi - giornoJson;
    int giornoPartenza = currDt.day - giornoGiusto;
    if (giornoPartenza < currDt.day) {
      giornoPartenza += 7;
    }
    return giornoPartenza;
  }

  letturaTerminataListaPrenotazioni(http.Response data) {
    if (data.statusCode == 200) {
      Utility.listaPrenotazioni = jsonDecode(data.body);

      _numNotifiche = 0;
      Utility.listaPrenotazioni.forEach((element) {
        _numNotifiche += element["msg_non_letti"];
      });

      onPressedListaPrenotazioniFuture = () {
        _onPressedListaPrenotazioniFuture();
      };

      if (idAppuntamento != "-1") {
        // se idAppuntamento != "-1", allora cio' significa che e' presente un appuntamento da aprire
        // viene cercato l'appuntamento tra la lista degli appuntamenti e poi viene aperto con VisualizzaPrenotazioneFutura
        // il parametro aggiornaPrenotazioni permette di modificare la listaPrenotazioni con le nuove info sulla prenotazione
        // non e' necessario aprire la schermata della lista delle prenotazioni, in quanto sono già presenti tutte le info per aprire la sezione di dettaglio da questa schermata
        int idAppuntamentoAprire = -1;
        for (int i = 0; i < Utility.listaPrenotazioni.length; i++) {
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

  //questa funzione viene eseguita una volta che viene scaricato il json contenente gli appuntamenti prenotabili e non del calendario
  //funzione usata SOLO per la sezione "Calendario richieste"
  letturaTerminataCalendarioRichieste(http.Response data) {
    if (data.statusCode == 200) {
      // print(data.body);
      // prende i dati da data e li decodifica mettendoli in result
      /*Map<String, dynamic> results = jsonDecode(data.body);
      // creo una lista dove ogni elemento e' un oggetto di tipo Meeting
      List<Meeting> meetings = List<Meeting>();
      String xx = results["base"]["base"];
      List listaJs = jsonDecode(xx);
      List orari;
      listaJs.forEach((ele) {
        List<dynamic> orario = ele["orari"];
        orario.forEach((eleOra) {
          List <String> soloOrainizio = eleOra["start"].split(":");
          List <String> soloOraFine = eleOra["end"].split(":");
        });
      });*/

      Utility.calendari = [];
      List<dynamic> results = jsonDecode(data.body);

      results.forEach((element) {
        ConvertSettimanaInCalendario convertSettimana =
            new ConvertSettimanaInCalendario(results: element["body"]);
        CalendarioBox calendarioBox = CalendarioBox(
            id: element["id"],
            name: element["name"],
            appuntamenti: convertSettimana.getCalendarioDisponibilita());
        Utility.calendari.add(calendarioBox);
      });

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

      /*var dayOfWeek = 1;
      DateTime date = DateTime.now();
      var lastMonday = date
          .subtract(Duration(days: date.weekday - dayOfWeek)).to;
      print(lastMonday);*/

      // print(listaJs[0].toString());

      // listaJs.forEach((dato){
      //   meetings.add(Meeting(
      //     descrizione: )
      //  )
      // });

      /* prende i Meeting da result e li aggiunge a meetings tramite un ciclo
      results.forEach((element) {
        meetings.add(Meeting(
            descrizione: element["disponibilita"],
            from: DateTime.parse(element["inizio"]),
            to: DateTime.parse(element["fine"]),
            prenotato: element["prenotato"]));
      });
      */
      // onPressedCalendario e' la funzione che viene avviata quando si clicca calendarioRichieste, di base eì nulla
      setState(() {});
    } else {
      print("Erorre: ${data.statusCode}");
    }
  }

  void _showMessage(
      String title, String body, String messageAdmin, Color color) {
    //per funzionare necessita di utilizzare un context, sul quale poi appunto si applica la funzione showSnackBar
    //il problema pero' e' che non può essere utilizzato lo stesso context dello statefulwidget, percio' contextGlobal non puo essere usato
    //cio' significa che bisgona utilizzare un nuovo context, per fare cio' bisogna crearlo con l'oggetto Builder che si trova piu' sotto
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

  // avvia la pagina contenenete il calendario, e' fondamentale passargli in ingresso gli appuntamenti, dovrebbe essere generica per tutti i calendari
  _onPressedCal(List<Disponibilita> meetings) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => Calendario(
            calendario: meetings,
            onTapDisponibilita: (Disponibilita appuntamento) {
              //sequenza avvia la pagina che permette di richiedere un appuntamento
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
                builder: (BuildContext context) => ListaPrenotazioni()))
        .then((_) {
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
                                  "Scorri orizontalmente l'elenco sottostante per scegliere dove effettuare la prenotazione",
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
