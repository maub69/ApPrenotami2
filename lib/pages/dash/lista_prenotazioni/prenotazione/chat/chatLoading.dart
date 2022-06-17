import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:mia_prima_app/pages/dash/lista_prenotazioni/prenotazione/chat/risposte/rispostaFactory.dart';
import 'package:mia_prima_app/utility/request_http.dart';
import 'cache_manager_chat.dart';
import '../../../../../utility/notification_sender.dart';
import 'package:mia_prima_app/utility/endpoint.dart';
import 'package:mia_prima_app/utility/messages_manager.dart';
import 'package:mia_prima_app/utility/utility.dart';

/// Classe che gestisce il flusso di messaggi in entrata nella chat, al fine
/// di farli visualizzare in real time
class ChatLoading {
  final int idAppuntamento;
  final BuildContext context;
  final Function update;
  List<Widget> listWidget = [];
  CacheManagerChat _cacheManagerChat;

  ChatLoading(this.idAppuntamento, this.context, this.update);

  /// vengono scaricati i messaggi dall'api della chat ed inoltre avviati i listener
  /// di firebase per fare in modo che vengano letti i messaggi in real time
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
      RequestHttp.get(Uri.parse(
          (EndPoint.getUrlKey(EndPoint.SET_CHAT_LETTA) + "&message_id=$idMessage")));
    }
  }

  /// qui viene creato il listener collegato poi a firebase che permette di leggere
  /// le notifiche in entrata all'app, però dato che l'app è aperta queste notifiche di base
  /// non vengono visualizzate sulla barra del cellulare. Se la notifica in entrata riguarda
  /// la chat che si ha aperta, allora viene creato il nuovo messaggio visualizzato in chat
  /// altrimenti viene creata forzatamente una notifica che ti reindirizza alla chat del messaggio
  void _loadFirebaseChat() {
      MessagesManager.isNotChat = false;
      Utility.onMessageFirebase = (RemoteMessage message) {
        dynamic bodyMessage = jsonDecode(message.data[
            "body"]); // non so perche', ma a quanto pare il body non e' un array, ma viene lasciato sotto forma di stringa, quindi bisogna fare il decode
        // print("contentuto-data: 1 ${bodyMessage["id_appuntamento"].toString()} - $idAppuntamento");
        if (bodyMessage["id_appuntamento"].toString() == idAppuntamento.toString()) {
          // print("risposta: id corrisponde - ${bodyMessage["action"]}");
          // print("contentuto-data: 1 - ${listWidget.length}");
          ResponseRispostaFactory responseRispostaFactory =
              RispostaFactory.getRisposta(bodyMessage["action"], bodyMessage,
                  context, delWidgets, idAppuntamento.toString());
          _cacheManagerChat
              .append(responseRispostaFactory.response.getJsonResponse());
          listWidget.addAll(responseRispostaFactory.widgets);
          // print("contentuto-data: 2 - ${listWidget.length}");
          _sendMesaggioLetto(bodyMessage["id"]);
          update();
        } else {
          MessagesManager.addChat(
              jsonDecode(message.data["body"])["id_appuntamento"]);
          // print("risposta: non id corrisponde");
          NotificationSender notificationSender = NotificationSender();
          notificationSender.showNotificationWithoutSound(
              message, _loadFirebaseChat);
        }
      };
  }

  /// esistono dei widget nella chat che si possono auto eliminare, per esempio il cambio Orario
  /// per fare questa operazione però è necessario che in ingresso ad un widget venga passata
  /// una funzione che ti permetta di farlo, in quanto è l'unica che può accedere
  /// alle sezioni dove sono presenti la lista dei widget
  void delWidgets(List<Widget> listWidgetToDelete) {
    listWidgetToDelete.forEach((element) {
      listWidget.remove(element);
    });
    /// dato che non puo' aggiornare l'interfaccia direttamente in quanto manca lo stato
    /// allora delega la responsabilita' a questa funzione che viene eseguita sul widget
    /// che ha inizializzato questa classe
    update();
  }
}
