import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:timelines/timelines.dart';

/*
  {
    "title": "Processo olive",
    "description": "Le varie fasi per spremere le olive",
    "started": true,
    "steps": [
        {
          "name": "Fase 1",
          "done": true,
          "messages": [
            "prima sotto fase fatta",
            "seconda sottofase fatta"
          ]
        },
        {
          "name": "Fase 2",
          "done": false,
          "messages": [
            "prima sotto fase fatta 2",
            "seconda sottofase fatta 2"
          ]
        }
    ]
  }
*/


/*
  Gli viene dato in ingresso un json come quello mostrato sopra e genera una timeline dei vari step
*/
class Steps extends StatelessWidget {
  final String json;

  const Steps({Key key, this.json}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    _Info info = _decodeJson(json);

    return Container(
      margin: EdgeInsets.all(8),
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
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(info.title,
            style: TextStyle(
                fontSize: 22.0,
                fontWeight: FontWeight.bold,
                color: Color(0xB4000000))),
        Padding(
            padding: EdgeInsets.only(top: 10, bottom: 10 ),
            child: Text(info.description,
                style: TextStyle(fontSize: 16.0, color: Color(0xB4000000)))),
        Divider(color: Colors.black87,height: 2.0),
        _Steps(processes: info.steps),
      ]),
    );
  }
}

/*
  Questa classe rappresenta i messaggi interni per ognuno degli step,
  in particolare qui si possono regolare tutte i parametri grafici riguardati
  i messaggi interni
*/
class _InnerTimeline extends StatelessWidget {
  const _InnerTimeline({
    this.messages,
  });

  final List<String> messages;

  @override
  Widget build(BuildContext context) {
    bool isEdgeIndex(int index) {
      return index == 0 || index == messages.length + 1;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: FixedTimeline.tileBuilder(
        theme: TimelineTheme.of(context).copyWith(
          nodePosition: 0,
          connectorTheme: TimelineTheme.of(context).connectorTheme.copyWith(
                thickness: 1.0,
              ),
          indicatorTheme: TimelineTheme.of(context).indicatorTheme.copyWith(
                size: 10.0,
                position: 0.5,
              ),
        ),
        builder: TimelineTileBuilder(
          indicatorBuilder: (_, index) =>
              !isEdgeIndex(index) ? Indicator.outlined(borderWidth: 1.0) : null,
          startConnectorBuilder: (_, index) => Connector.solidLine(),
          endConnectorBuilder: (_, index) => Connector.solidLine(),
          contentsBuilder: (_, index) {
            if (isEdgeIndex(index)) {
              return null;
            }

            return Padding(
              padding: EdgeInsets.only(left: 8.0),
              child: Text(messages[index - 1].toString()),
            );
          },
          itemExtentBuilder: (_, index) => isEdgeIndex(index) ? 10.0 : 30.0,
          nodeItemOverlapBuilder: (_, index) =>
              isEdgeIndex(index) ? true : null,
          itemCount: messages.length + 2,
        ),
      ),
    );
  }
}

/*
  Questo e' il widget che effettivamente rappresenta cio' che viene
  visualizzato, o meglio rappresenza il widget della lista dei vari step
*/
class _Steps extends StatelessWidget {
  const _Steps({Key key, this.processes}) : super(key: key);

  final List<_Step> processes;
  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: TextStyle(
        color: Color(0xff9b9b9b),
        fontSize: 12.5,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: FixedTimeline.tileBuilder(
          theme: TimelineThemeData(
            nodePosition: 0,
            color: Color(0xff989898),
            indicatorTheme: IndicatorThemeData(
              position: 0,
              size: 20.0, // dimensione pallino
            ),
            connectorTheme: ConnectorThemeData(
              thickness: 4.5, // dimensiona la larghezza della riga step
            ),
          ),
          builder: TimelineTileBuilder.connected(
            connectionDirection: ConnectionDirection.before,
            itemCount: processes.length,
            contentsBuilder: (_, index) {
              // questo permette di non visualizzare le linee oltre l'ultimo puntino, senza questo if verrebbero visualizzate
              Widget label = Text(
                processes[index].name,
                style: DefaultTextStyle.of(context).style.copyWith(
                    fontSize: 18.0, // grandezza testo principale
                    color: processes[index].done
                        ? Colors.black87
                        : Colors.black26),
              );
              if (processes.length == (index + 1)) {
                return Padding(
                    padding: EdgeInsets.only(left: 8.0), child: label);
              } else {
                return Padding(
                  padding: EdgeInsets.only(
                      left:
                          8.0), // distanza tra la riga dello step principale e quella dello step secondario interno
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment
                        .start, // posizione testo principale dello step (destra, sinista, centro)
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      label,
                      _InnerTimeline(messages: processes[index].messages),
                    ],
                  ),
                );
              }
            },
            indicatorBuilder: (_, index) {
              if (processes[index].done) {
                return DotIndicator(
                  color: Color(0xff66c97f),
                  child: Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 12.0,
                  ),
                );
              } else {
                return OutlinedDotIndicator(
                  borderWidth: 2.5,
                );
              }
            },
            connectorBuilder: (_, index, ___) => SolidLineConnector(
              color: processes[index].done ? Color(0xff66c97f) : null,
            ),
          ),
        ),
      ),
    );
  }
}

/*
  Decodifica il json in ingresso e lo trasforma in una lista di step con anche
  le info sul titolo e la descrizione
*/
_Info _decodeJson(String json) {
  List<_Step> steps = [];
  Map<String, dynamic> infoJson = jsonDecode(json);
  List<dynamic> stepsJson = infoJson["steps"];

  // qua viene riempito l'array degli step con name e messaggi interni
  stepsJson.forEach((element) {
    List<String> messages = [];
    List<dynamic> messagesJson = element["messages"];
    messagesJson.forEach((element) {
      messages.add(element);
    });

    steps.add(_Step(element["name"], messages: messages));
  });

  // in questa riga e quelle successive sostanzialmente viene settato il pallino in modo tale che sia verde o meno
  // pero' deve essere fatto guardando al pallino successivo, percio' come si puo' vedere dal for si considera
  // lo step nella posizione i+1
  steps.first.done = infoJson["started"];

  for (int i = 0; i < (stepsJson.length - 1); i++) {
    steps[i + 1].done = stepsJson[i]["done"];
  }

  steps.add(_Step("Concluso", messages: []));
  steps.last.done = stepsJson.last["done"];

  return new _Info(infoJson["title"], infoJson["description"], steps);
}

class _Info {
  final String title;
  final String description;
  final List<_Step> steps;

  _Info(this.title, this.description, this.steps);
}

class _Step {
  _Step(
    this.name, {
    this.messages = const [],
  });

  final String name;
  final List<String> messages;
  bool done;
}
