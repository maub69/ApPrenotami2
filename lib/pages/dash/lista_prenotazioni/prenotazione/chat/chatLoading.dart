import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:mia_prima_app/pages/dash/lista_prenotazioni/prenotazione/chat/risposte/rispostaFactory.dart';
import 'cache_manager_chat.dart';
import '../../../../../utility/notification_sender.dart';
import 'package:mia_prima_app/utility/endpoint.dart';
import 'package:mia_prima_app/utility/messages_manager.dart';
import 'package:mia_prima_app/utility/utility.dart';
import 'package:http/http.dart' as http;

class ChatLoading {
  final int idAppuntamento;
  final BuildContext context;
  final Function update;
  List<Widget> listWidget = [];
  CacheManagerChat _cacheManagerChat;

  ChatLoading(this.idAppuntamento, this.context, this.update);

  /*
    Vengono scaricati i messaggi della chat
  */
  Future<List<ResponseRispostaFactory>> loadChat() async {
    List<ResponseRispostaFactory> responseRispostaFactory = [];
    /*
      Qui avviene la gestione del'onMessage, sia della singola chat che globale
    */
    _loadFirebaseChat();
    _cacheManagerChat = CacheManagerChat(idAppuntamento.toString());

    MessagesManager.removeChat(idAppuntamento);
    Map<String, String> parametri = {};
    // qua semplicemente vengono settati i parametri dell'id utente e dell'appuntamento per poi scaricare i messaggi giusti corrispondenti
    parametri["key"] = Utility.utente.id;
    parametri["appuntamento"] = idAppuntamento.toString();
    Uri request =
        new Uri.https(EndPoint.HOST, "/" + EndPoint.GET_CHAT, parametri);

    String response =
        await _cacheManagerChat.getMessages(Uri.parse(request.toString()));

    print("sono qui 25: $response");

    List<dynamic> chatJson = jsonDecode(response);
    // una volta fatto il decode messaggio per messaggio viene agigunto nella lista, pero' prima viene fatto il factory, cioe' per ogni json del messaggio viene creato il/i widget corrispondenti
    chatJson.forEach((element) {
      //la suddivisione sul tipo di messaggio si fa con action, che puo' essere per esempio free o cambio-orario
      ResponseRispostaFactory rrf = RispostaFactory.getRisposta(
          element["action"],
          element,
          context,
          delWidgets,
          idAppuntamento.toString());
      responseRispostaFactory.add(rrf);
      listWidget.addAll(rrf.widgets);
    });
    _sendMesaggioLetto(chatJson.last["id"]);
    return responseRispostaFactory;
  }

  void _sendMesaggioLetto(String idMessage) {
    if (Utility.hasInternet) {
      http.get(Uri.parse(
          (EndPoint.getUrlKey("SET_CHAT_LETTA") + "&message=$idMessage")));
    }
  }

  void _loadFirebaseChat() {
      MessagesManager.isNotChat = false;
      Utility.onMessageFirebase = (RemoteMessage message) {
        dynamic bodyMessage = jsonDecode(message.data[
            "body"]); // non so perche', ma a quanto pare il body non e' un array, ma viene lasciato sotto forma di stringa, quindi bisogna fare il decode
        print("contentuto-data: 1 ${bodyMessage["id_appuntamento"].toString()} - $idAppuntamento");
        if (bodyMessage["id_appuntamento"].toString() == idAppuntamento.toString()) {
          print("risposta: id corrisponde - ${bodyMessage["action"]}");
          print("contentuto-data: 1 - ${listWidget.length}");
          ResponseRispostaFactory responseRispostaFactory =
              RispostaFactory.getRisposta(bodyMessage["action"], bodyMessage,
                  context, delWidgets, idAppuntamento.toString());
          _cacheManagerChat
              .append(responseRispostaFactory.response.getJsonResponse());
          listWidget.addAll(responseRispostaFactory.widgets);
          print("contentuto-data: 2 - ${listWidget.length}");
          _sendMesaggioLetto(bodyMessage["id"]);
          update();
        } else {
          MessagesManager.addChat(
              jsonDecode(message.data["body"])["id_appuntamento"]);
          print("risposta: non id corrisponde");
          NotificationSender notificationSender = NotificationSender();
          notificationSender.showNotificationWithoutSound(
              message, _loadFirebaseChat);
        }
      };
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
