import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:mia_prima_app/chat/risposte/rispostaFactory.dart';
import 'package:mia_prima_app/notificationSender.dart';
import 'package:mia_prima_app/utility/endpoint.dart';
import 'package:mia_prima_app/utility/messagesManager.dart';
import 'package:mia_prima_app/utility/utility.dart';
import 'package:http/http.dart' as http;

class ChatLoading {
  final int idAppuntamento;
  final BuildContext context;
  final Function update;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  List<Widget> listWidget = [];

  ChatLoading(this.idAppuntamento, this.context, this.update);

  /*
    Vengono scaricati i messaggi della chat
  */
  Future<List<Widget>> loadChat() async {
    //TODO se quanto arriva il messaggio con onMessage si è dentro la chat, allora mostra semplicemente il messaggio, altrimenti spara una notifica e cliccandoci sopra apre la chat indisitintamente da dove ti trovi e scarica i messaggi della chat
    // TODO se il messaggio in arrivo conOnMessage non ha lo stesso idChat della chat aperta, allora non deve visualizzare il messaggio, ma deve aprire la chat
    /*
      Qui avviene la gestione del'onMessage, sia della singola chat che globale
    */
    _loadFirebaseChat();

    MessagesManager.removeChat(idAppuntamento);
    Map<String, String> parametri = {};
    // qua semplicemente vengono settati i parametri dell'id utente e dell'appuntamento per poi scaricare i messaggi giusti corrispondenti
    parametri["key"] = Utility.utente.id;
    parametri["appuntamento"] = idAppuntamento.toString();
    Uri request =
        new Uri.https(EndPoint.HOST, "/" + EndPoint.GET_CHAT, parametri);
    http.Response response = await http.get(Uri.parse(request.toString()));
    List<dynamic> chatJson = jsonDecode(response.body);
    // una volta fatto il decode messaggio per messaggio viene agigunto nella lista, pero' prima viene fatto il factory, cioe' per ogni json del messaggio viene creato il/i widget corrispondenti
    chatJson.forEach((element) {
      //la suddivisione sul tipo di messaggio si fa con action, che puo' essere per esempio free o cambio-orario
      listWidget.addAll(RispostaFactory.getRisposta(
          element["action"], element, context, delWidgets));
    });
    _sendMesaggioLetto(chatJson.last["id"]);
    return listWidget;
  }

  void _sendMesaggioLetto(int idMessage) {
    http.get(Uri.parse((EndPoint.getUrlKey("SET_CHAT_LETTA") + "&message=$idMessage")));
  }

  void _loadFirebaseChat() {
    MessagesManager.isNotChat = false;
    _firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
      dynamic bodyMessage = jsonDecode(message["data"]["body"]); // non so perche', ma a quanto pare il body non e' un array, ma viene lasciato sotto forma di stringa, quindi bisogna fare il decode
      if (bodyMessage["id"].toString() == idAppuntamento.toString()) {
        // print("risposta: id corrisponde");
        listWidget.addAll(RispostaFactory.getRisposta(
            bodyMessage["action"], bodyMessage, context, delWidgets));
        _sendMesaggioLetto(bodyMessage["id"]);
        update();
      } else {
        MessagesManager.addChat(jsonDecode(message["data"]["body"])["id"]);
        // print("risposta: non id corrisponde");
        NotificationSender notificationSender = NotificationSender();
        notificationSender.showNotificationWithoutSound(
            message, _loadFirebaseChat);
      }
    });
  }

  /*
    Elimina i widget interessati dalla lista dei widget visualizzati e poi aggiorna l'interfaccia
  */
  void delWidgets(List<Widget> listWidgetToDelete) {
    listWidgetToDelete.forEach((element) {
      listWidget.remove(element);
    });
    // dato che non puo' aggiornare l'interfaccia direttamente in quanto manca lo stato, allora delega la responsabilita' a questa funzione che viene eseguita sul widget che ha inizializzato questa classe
    update();
  }
}
