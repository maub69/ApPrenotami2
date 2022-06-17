import 'dart:io' as io;
import 'dart:math';
import 'dart:typed_data';

import 'package:alert/alert.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:mia_prima_app/pages/dash/lista_prenotazioni/prenotazione/chat/risposte/popup_menu_chat.dart';
import 'package:mia_prima_app/pages/dash/lista_prenotazioni/prenotazione/chat/risposte/risposta.dart';
import 'package:mia_prima_app/pages/dash/lista_prenotazioni/prenotazione/chat/risposte/rispostaFactory.dart';
import 'package:mia_prima_app/pages/dash/lista_prenotazioni/prenotazione/chat/upload/file_upload.dart';
import 'package:mia_prima_app/pages/dash/lista_prenotazioni/prenotazione/chat/upload/media_upload.dart';
import 'package:mia_prima_app/utility/request_http.dart';
import 'cache_manager_chat.dart';
import 'chatLoading.dart';
import 'package:mia_prima_app/utility/endpoint.dart';
import 'package:mia_prima_app/utility/upload_manager.dart';
import 'package:mia_prima_app/utility/utility.dart';
import 'package:path/path.dart';
import "package:images_picker/images_picker.dart";
import 'package:video_thumbnail/video_thumbnail.dart';

class ChatPage extends StatefulWidget {
  final Color appBarColor;
  final int idAppuntamento;
  final dynamic prenotazione;

  const ChatPage(
      {Key key, this.appBarColor, this.idAppuntamento, this.prenotazione})
      : super(key: key);

  @override
  State createState() => _ChatPage();
}

class _ChatPage extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode focus = FocusNode();
  List<Widget> _listViewChat = [];
  ChatLoading _chatLoading;
  BuildContext _context;
  List<ProgressFile> _listProgressFile = [];
  var random = Random();
  CacheManager _cacheManager;
  CacheManagerChat _cacheManagerChat;

  _focusListener() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _cacheManagerChat = new CacheManagerChat(widget.idAppuntamento.toString());
    _cacheManager = Utility.getCacheManager(widget.idAppuntamento.toString());
    PopupMenuChat.listWidget = _listViewChat;
    PopupMenuChat.updateView = updateView;
    PopupMenuChat.cacheManagerChat = _cacheManagerChat;

    /// permette di gestire il focus sul campo di inserimento di testo, in particolare
    /// permette che la pagina effettivamente si aggiorni quando si sta scrivendo del testo
    focus.addListener(_focusListener);
    widget.prenotazione["msg_non_letti"] = 0;
    // qui vengono scaricati i messaggi e inseriti nella _listView per poi essere visualizzati
  }

  @override
  void dispose() {
    // quando si esce si deve rimuovere il listener per tutti i progress file, in quanto altrimenti si potrebbero presentare molto errori
    _listProgressFile.forEach((element) {
      element.delListener();
    });

    focus.removeListener(_focusListener);
    super.dispose();
  }

  void updateView() {
    setState(() {});
  }

  /// fa due cose: 1) invia il messaggio all'endpoint EndPoint.MESSAGGIO_CHAT
  /// 2) aggiunge il messaggio alla lista dei widget da visualizzare, in questo modo viene inserito al'interno della schermata
  void invioMessaggioTesto(String text) {
    if (!Utility.hasInternet) {
      Alert(message: 'Internet assente, non puoi inviare un messaggio').show();
      return;
    }
    DateTime datetime = new DateTime.now();
    String idMessaggio =
        _cacheManagerChat.idChat(widget.idAppuntamento, _listViewChat.length);
    RequestHttp.post(Uri.parse(EndPoint.getUrlKey(EndPoint.MESSAGGIO_CHAT)),
        body: {
          "datetime": datetime.toString(),
          "text": text,
          "id": idMessaggio,
          "type": "free"
        });
    setState(() {
      /// quando viene inviato il messaggio, viene anche creato il widget che viene inserito
      /// nella lista dei widget visualizzati, inoltre viene aggiunto alla cache
      /// in basso si può vedere che deve essere specificato in primis il tipo di widget da aggiungere
      /// poi il body che verrà salvato in cache
      /// infine viene passato l'id dell'appuntamento, anche se in realtà in questo specifico caso non serve
      /// infatti è utile solo per i widget interattivi, questo è solo di visualizzazione
      ResponseRispostaFactory risposta = RispostaFactory.getRisposta(
          "free",
          {
            "datetime": datetime.toString(),
            "id": idMessaggio,
            "body": {"message": text, "isAmministratore": false}
          },
          _context,
          null,
          widget.idAppuntamento.toString());

      _cacheManagerChat.append(risposta.response.getJsonResponse());

      _listViewChat.addAll(risposta.widgets);
    });
    _controller.text = "";
  }

  /// avvia le operazioni di upload del file
  /// per farlo deve interpellare uploadManager e poi deve aggiungere
  /// il progressFile alla lista dei progress, in quanto altrimenti non potrebbero
  /// essere rimossi i listener quando si esce dalla pagina, in particolare si intendono
  /// i listener dei widget di attesa, cioè gli indicatori di progresso dello stato
  /// dell'avanzamento dell'upload
  uploadMedia(io.File file, bool isPhoto) async {
    ProgressFile progressFile = Utility.uploadManager.uploadFile(
        file,
        widget.idAppuntamento,
        _cacheManagerChat.idChat(widget.idAppuntamento, _listViewChat.length),
        isPhoto ? 0 : 1);
    _listProgressFile.add(progressFile);
    Future<void> saveMedia;
    /// una volta che viene avviato l'upload, viene immediatamente effettuato il caching
    /// per la foto o il video, dato che però creare una cache è un operazione asincrona
    /// è necessario aspettare che questa termini prima di creare il widget corrispondente
    /// in questo modo non verranno lanciate eccezioni
    if (isPhoto) {
      saveMedia = cacheImage(progressFile);
    } else {
      saveMedia = cachePlaceholderAndVideo(progressFile);
    }
    saveMedia.then((value) {
      setState(() {
        _listViewChat.add(MediaUpload(
            idAppuntamento: widget.idAppuntamento.toString(),
            progressFile: progressFile,
            isPhoto: isPhoto,
            idChat: _cacheManagerChat.idChat(
                widget.idAppuntamento, _listViewChat.length),
            key: Key(random.nextInt(10000).toString())));

        _cacheManagerChat.append(Risposta.getJson(
            _cacheManagerChat.idChat(
                widget.idAppuntamento, _listViewChat.length),
            (progressFile.typeUpload == 0 ? "photo" : "video"),
            DateTime.now(),
            {"isAmministratore": false, "url": progressFile.getUrl()}));
      });
    });
  }


  /// funzione molto simile a quella precedente come funzionamento interno, con la differenza
  /// che effettua l'upload di un file generico
  uploadFile(io.File file) {
    ProgressFile progressFile = Utility.uploadManager.uploadFile(
        file,
        widget.idAppuntamento,
        _cacheManagerChat.idChat(widget.idAppuntamento, _listViewChat.length),
        2);
    _listProgressFile.add(progressFile);
    setState(() {
      var random = Random();
      _listViewChat.add(FileUpload(
          progressFile: progressFile,
          isAmministratore: true,
          idChat: _cacheManagerChat.idChat(
              widget.idAppuntamento, _listViewChat.length),
          key: Key(random.nextInt(10000).toString())));
      _cacheManagerChat.append(Risposta.getJson(
          _cacheManagerChat.idChat(widget.idAppuntamento, _listViewChat.length),
          "file",
          DateTime.now(), {
        "isAmministratore": true,
        "name": progressFile.getNameFile(),
        "url": progressFile.getUrl()
      }));
    });
  }

  /// fa il caching della foto
  Future<void> cacheImage(ProgressFile progressFile) async {
    Uint8List bytes = progressFile.file.readAsBytesSync();

    await _cacheManager.putFile(progressFile.getUrl(), bytes,
        fileExtension: progressFile.getExtension(), maxAge: Duration(days: 15));
  }

  /// fa il caching della foto di copertina del video
  /// in quanto il caching del video si gestisce autonomamente
  Future<void> cachePlaceholderAndVideo(ProgressFile progressFile) async {
    Uint8List bytesVideo = progressFile.file.readAsBytesSync();

    Uint8List bytesFile = await VideoThumbnail.thumbnailData(
      video: progressFile.file.path,
      imageFormat: ImageFormat.JPEG,
    );

    await _cacheManager.putFile(progressFile.getUrl() + ".jpeg", bytesFile,
        fileExtension: "jpeg", maxAge: Duration(days: 15));
  }

  @override
  Widget build(BuildContext context) {
    _context = context;
    if (_chatLoading == null) {
      _chatLoading =
          new ChatLoading(widget.idAppuntamento, context, updateView);
      _chatLoading.loadChat().then((value) {
        setState(() {
          List<ResponseRispostaFactory> responseRispostaFactory = value;

          /// all'avvio deve scaricare tutti i progressUpload in corso per questa pagina
          /// in quanto se si esce dalla pagina e poi si rientra deve appunto mostrare il fatto
          /// che si sta caricando qualche file
          _listProgressFile =
              Utility.uploadManager.getListProgressFile(widget.idAppuntamento);
          _listProgressFile.forEach((element) {
            element.setListener(
                (int progress) {});
          });

          /// dato che si può uscire ed entrare in una chat anche mentre un'upload
          /// è in corso, è necessario che i widget vengano inseriti nella chat, in quanto
          /// in quanto altrimenti questi non sarebbero presenti, dato che si trovano
          /// in uno stato in cui non sono ancora presenti nella chat, di conseguenza
          /// non verrebbero scaricati dal server
          _listProgressFile.forEach((element) {
            if (element.typeUpload == 0 || element.typeUpload == 1) {
              responseRispostaFactory
                  .add(ResponseRispostaFactory(null, element.dateTime, [
                MediaUpload(
                    idAppuntamento: widget.idAppuntamento.toString(),
                    progressFile: element,
                    isPhoto: element.typeUpload == 0,
                    idChat: element.idChat,
                    key: Key(random.nextInt(10000).toString()))
              ]));
            } else if (element.typeUpload == 2) {
              responseRispostaFactory.add(ResponseRispostaFactory(
                  null, element.dateTime, [
                FileUpload(
                    progressFile: element,
                    key: Key(random.nextInt(10000).toString()))
              ]));
            }
          });

          /// qui vengono riordinati i widget in base alla data di creazione e poi
          /// inseriti insieme a tutti gli altri widget della pagina
          responseRispostaFactory
              .sort((a, b) => a.dateTime.compareTo(b.dateTime));

          responseRispostaFactory.forEach((element) {
            _listViewChat.addAll(element.widgets);
          });
          _chatLoading.listWidget = _listViewChat;
        });
      });
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: (widget.appBarColor == null)
            ? Colors.green[900]
            : widget.appBarColor,
        centerTitle: true,
        title: Text('ApPuntamento'),
      ),
      backgroundColor: Colors.white70,
      body: Column(
        children: [
          Expanded(
              child: ListView.builder(
            reverse: true,
            shrinkWrap: true,
            itemCount: _listViewChat.length,
            itemBuilder: (BuildContext context, int index) {
              return _listViewChat[_listViewChat.length - index - 1];
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
                  child: new ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: 300.0,
                    ),
                    child: TextField(
                      // textInputAction: TextInputAction.go,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      onSubmitted: (value) {
                        invioMessaggioTesto(value.trim());
                      },
                      autofocus: false,
                      controller: _controller,
                      focusNode: focus,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black38),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15.0)),
                          borderSide: BorderSide(
                            color: Colors.black87,
                            width: 1.0,
                            style: BorderStyle.solid,
                          ),
                        ),
                        focusColor: Colors.green[900],
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        labelText: 'Scrivi qui...',
                        labelStyle: TextStyle(
                            color:
                                focus.hasFocus ? Colors.black : Colors.black87),
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
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50.0),
                      ),
                      primary: Colors.green[900],
                    ),
                    child: Icon(
                      Icons.send,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      invioMessaggioTesto(_controller.text.trim());
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
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        primary: Colors.white, elevation: 0.0),
                    child: Column(
                      children: [
                        Icon(Icons.file_copy, color: Colors.black),
                        Text('File', style: TextStyle(color: Colors.black)),
                      ],
                    ),
                    onPressed: () async {
                      FilePickerResult result = await FilePicker.platform
                          .pickFiles(allowMultiple: true);

                      if (result != null) {
                        List<io.File> files =
                            result.paths.map((path) => io.File(path)).toList();
                        files.forEach((file) {
                          uploadFile(file);
                        });
                      } else {
                        // User canceled the picker
                      }
                    },
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        primary: Colors.white, elevation: 0.0),
                    child: Column(
                      children: [
                        Icon(Icons.image, color: Colors.black),
                        Text('Media', style: TextStyle(color: Colors.black)),
                      ],
                    ),
                    onPressed: () async {
                      FilePickerResult result =
                          await FilePicker.platform.pickFiles(
                        allowMultiple: true,
                        type: FileType.custom,
                        allowedExtensions: [
                          'jpg',
                          'png',
                          'mp4'
                        ], // TODO aggiungere altre estensioni, in particolare dei video
                      );

                      if (result != null) {
                        List<io.File> files =
                            result.paths.map((path) => io.File(path)).toList();
                        files.forEach((element) {
                          print("file-trovato: $element");
                          uploadMedia(element,
                              extension(element.path).substring(1) != "mp4");
                        });
                      } else {
                        // User canceled the picker
                      }
                    },
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        primary: Colors.white, elevation: 0.0),
                    child: Column(
                      children: [
                        Icon(Icons.photo_camera, color: Colors.black),
                        Text('Foto', style: TextStyle(color: Colors.black)),
                      ],
                    ),
                    onPressed: () {
                      ImagesPicker.openCamera(
                        pickType: PickType.image,
                      ).then((value) {
                        if (value != null && value.isNotEmpty) {
                          uploadMedia(io.File(value.first.path), true);
                        }
                      });
                    },
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
