import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mia_prima_app/chat/chatLoading.dart';
import 'package:mia_prima_app/messagetile.dart';
import 'package:path/path.dart';

class ChatPage extends StatefulWidget {
  final Color appBarColor;
  final int idAppuntamento;

  const ChatPage({Key key, this.appBarColor, this.idAppuntamento})
      : super(key: key);

  @override
  State createState() => _ChatPage();
}

class _ChatPage extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode focus = FocusNode();
  List<Widget> _listViewChat = [];
  ChatLoading _chatLoading;

  _focusListener() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    focus.addListener(_focusListener());
    // qui vengono scaricati i messaggi e inseriti nella _listView per poi essere visualizzati
  }

  @override
  void dispose() {
    focus.removeListener(_focusListener());
    super.dispose();
  }

  void updateView() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_chatLoading == null) {
      _chatLoading =
          new ChatLoading(widget.idAppuntamento, context, updateView);
      _chatLoading.loadChat().then((value) {
        setState(() {
          _listViewChat = value;
        });
      });
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            (widget.appBarColor == null) ? Colors.green : widget.appBarColor,
        centerTitle: true,
        title: Text('ApPuntamento'),
      ),
      backgroundColor: Colors.white70,
      body: Column(
        children: [
          /*Expanded(
            child: ListView(
              shrinkWrap: true,
              physics: AlwaysScrollableScrollPhysics(),
              children:
                  _listViewChat, //questo punto e' importante in quanto qui viene inserita la lista contenente tutit i messaggi della chat
            ),
          ),*/
          // abbiamo sostituito la listview con listView.builder in quanto era piu elastica. Infatti avevamo necessita che in caso dell'eliminazione di un elemento dalla lista dei widget, esso venisse effettivamente eliminato, cosa che funziona con ListView.Builder e non con l'altro
          Expanded(
              child: ListView.builder(
              itemCount: _listViewChat.length,
              itemBuilder: (BuildContext context, int index) {
                return _listViewChat[index];
              },
          )),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.only(
                    bottom: 10.0,
                    left: 10.0,
                    right: 5.0,
                  ),
                  child: Container(
                    height: 50.0,
                    child: TextField(
                      autofocus: false,
                      controller: _controller,
                      focusNode: focus,
                      keyboardType: TextInputType.text,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.green),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15.0)),
                          borderSide: BorderSide(
                            color: Colors.black,
                            width: 1.0,
                            style: BorderStyle.solid,
                          ),
                        ),
                        focusColor: Colors.green,
                        labelText: 'Scrivi qui...',
                        labelStyle: TextStyle(
                            color:
                                focus.hasFocus ? Colors.black : Colors.green),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 10.0,
                  left: 5.0,
                  right: 10.0,
                ),
                child: Container(
                  width: 50.0,
                  height: 50.0,
                  child: RaisedButton(
                    child: Icon(
                      Icons.send,
                      color: Colors.white,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50.0),
                    ),
                    color: Colors.green,
                    onPressed: () {
                      print('Invia messaggio');
                    },
                  ),
                ),
              ),
            ],
          ),
          Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RaisedButton(
                    color: Colors.white,
                    elevation: 0.0,
                    child: Column(
                      children: [
                        Icon(Icons.file_copy),
                        Text('File'),
                      ],
                    ),
                    onPressed: () async {
                      FilePickerResult result = await FilePicker.platform
                          .pickFiles(allowMultiple: true);

                      if (result != null) {
                        List<File> files =
                            result.paths.map((path) => File(path)).toList();
                        files.forEach((file) {
                          print(file.path);
                        });
                      } else {
                        // User canceled the picker
                      }
                    },
                  ),
                  RaisedButton(
                    color: Colors.white,
                    elevation: 0.0,
                    child: Column(
                      children: [
                        Icon(Icons.image),
                        Text('Immagine'),
                      ],
                    ),
                    onPressed: () async {
                      FilePickerResult result =
                          await FilePicker.platform.pickFiles(
                        allowMultiple: true,
                        type: FileType.custom,
                        allowedExtensions: ['jpg', 'png'],
                      );

                      if (result != null) {
                        List<File> files =
                            result.paths.map((path) => File(path)).toList();
                      } else {
                        // User canceled the picker
                      }
                    },
                  ),
                  RaisedButton(
                    color: Colors.white,
                    elevation: 0.0,
                    child: Column(
                      children: [
                        Icon(Icons.photo_camera),
                        Text('Foto'),
                      ],
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
