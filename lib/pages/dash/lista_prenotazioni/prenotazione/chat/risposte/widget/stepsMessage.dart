import 'package:flutter/material.dart';
import 'package:mia_prima_app/pages/dash/lista_prenotazioni/prenotazione/chat/risposte/risposta.dart';

/// il widget relativo al box rettangolare arancione che compare a metà nello schermo
/// che da informazioni come se fosse una notifica, ogni qual volta si raggiunge un nuovo
/// step, questo widget viene inviato alla chat
class StepsMessage extends Risposta  {
  StepsMessage(String idChat, Map<String, dynamic> body, DateTime datetime,
      BuildContext context, Function(List<Widget> listWidgets) delWidgets)
      : super(idChat, body, datetime, context, delWidgets);

  @override
  List<Widget> getRisposta() {
    return [getBoxMessage(body["message"], datetime)];
  }

  Widget getBoxMessage(String message, DateTime datetime) {
    return Container(
      margin: EdgeInsets.only(top: 10, left: 20, right: 20),
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Color(0xFFFA7A30),
        border: Border.all(width: 0.0),
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 3,
            blurRadius: 8,
            offset: Offset(0, 2), // changes position of shadow
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
        Text(
            "${datetime.day}/${datetime.month}/${datetime.year} ${datetime.hour}:${(datetime.minute>=10)?datetime.minute:"0" + datetime.minute.toString()}",
            style: TextStyle(fontSize: 14, color: Colors.white)),
        Text(message, style: TextStyle(fontSize: 18, color: Colors.white))
      ]),
    );
  }
  
  @override
  String get type => "steps";
}
