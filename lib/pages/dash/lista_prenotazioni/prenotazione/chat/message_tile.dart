import 'package:flutter/material.dart';
import 'package:mia_prima_app/pages/dash/lista_prenotazioni/prenotazione/chat/risposte/popup_menu_chat.dart';
import '../../../../global/model.dart';

class MessageTile extends StatelessWidget {
  final String messageText;
  final bool isLeft;
  final DateTime datetime;
  final String idChat;

  const MessageTile({Key key, this.messageText, this.isLeft, this.datetime, this.idChat})
      : super(key: key);

  String _getStringFromDateTime(DateTime datetime) {
    return "${datetime.day}/${datetime.month}/${datetime.year} ${datetime.hour}:${(datetime.minute >= 10) ? datetime.minute : "0" + datetime.minute.toString()}";
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onLongPress: () {
          PopupMenuChat.showMenu(
            context: Model.getContext(),
            isAmministratore: !isLeft,
            isChat: true,
            text: messageText,
            idChat: idChat,
            widget: this
          );
        },
        child: Container(
          alignment: isLeft ? Alignment.centerLeft : Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 15.0,
              horizontal: 20.0,
            ),
            child: isLeft
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Flexible(
                        flex: 3,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.all(Radius.circular(20.0)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 5.0),
                                      child: Text(
                                        _getStringFromDateTime(datetime),
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  messageText,
                                  style: TextStyle(fontSize: 20.0),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: Container(),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Flexible(
                        flex: 1,
                        child: Container(),
                      ),
                      Flexible(
                        flex: 3,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.green[200],
                            borderRadius:
                                BorderRadius.all(Radius.circular(20.0)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 5.0),
                                      child: Text(
                                        _getStringFromDateTime(datetime),
                                        style: TextStyle(fontSize: 12),
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  messageText,
                                  style: TextStyle(fontSize: 20.0),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ));
  }
}
