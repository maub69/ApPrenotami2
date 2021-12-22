import 'dart:io' as io;
import 'dart:math';
import 'dart:typed_data';

import 'package:alert/alert.dart';
import 'package:file/src/interface/file.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:mia_prima_app/cache_manager_chat.dart';
import 'package:mia_prima_app/chat/chatLoading.dart';
import 'package:mia_prima_app/chat/risposte/popup_menu_chat.dart';
import 'package:mia_prima_app/chat/risposte/risposta.dart';
import 'package:mia_prima_app/chat/risposte/rispostaFactory.dart';
import 'package:mia_prima_app/chat/risposte/widget/photo.dart';
import 'package:mia_prima_app/main.dart';
import 'package:mia_prima_app/messagetile.dart';
import 'package:mia_prima_app/upload/file_upload.dart';
import 'package:mia_prima_app/upload/media_upload.dart';
import 'package:mia_prima_app/utility/endpoint.dart';
import 'package:mia_prima_app/utility/uploadManager.dart';
import 'package:mia_prima_app/utility/utility.dart';
import 'package:multipart_request/multipart_request.dart';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import "package:images_picker/images_picker.dart";
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:flutter_cache_manager/src/storage/file_system/file_system.dart';
import 'package:file/file.dart' as fl;

class ChatPage extends StatefulWidget {
  final Color appBarColor;
  final int idAppuntamento;
  final int indexPrenotazioni;

  const ChatPage(
      {Key key, this.appBarColor, this.idAppuntamento, this.indexPrenotazioni})
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
    focus.addListener(_focusListener);
    Utility.listaPrenotazioni[widget.indexPrenotazioni]["msg_non_letti"] = 0;
    // qui vengono scaricati i messaggi e inseriti nella _listView per poi essere visualizzati
  }

  @override
  void dispose() {
    // quando si esce si deve riuovere il listener per tutti i progress file, in quanto altrimenti si potrebbero presentare molto errori
    _listProgressFile.forEach((element) {
      element.delListener();
    });

    focus.removeListener(_focusListener);
    super.dispose();
  }

  void updateView() {
    setState(() {});
  }

  // fa due cose: 1) invia il messaggio all'endpoint EndPoint.MESSAGGIO_CHAT; 2) aggiunge il messaggio alla lista dei widget da visualizzare, in questo modo viene inserito al'interno della schermata
  void invioMessaggioTesto(String text) {
    if (!Utility.hasInternet) {
      Alert(message: 'Internet assente, non puoi inviare un messaggio').show();
      return;
    }
    DateTime datetime = new DateTime.now();
    String idMessaggio =
        _cacheManagerChat.idChat(widget.idAppuntamento, _listViewChat.length);
    http.post(Uri.parse(EndPoint.getUrlKey(EndPoint.MESSAGGIO_CHAT)), body: {
      "datetime": datetime.toString(),
      "text": text,
      "id": idMessaggio
    });
    setState(() {
      ResponseRispostaFactory risposta = RispostaFactory.getRisposta(
          "free",
          {
            "datetime": datetime.toString(),
            "id": idMessaggio,
            "body": {"message": text, "isAmministratore": false}
          },
          _context,
          null,
          idAppuntamento);

      _cacheManagerChat.append(risposta.response.getJsonResponse());

      _listViewChat.addAll(risposta.widgets);
    });
    _controller.text = "";
  }

  /*uploadFile(File file) async {
    // open a bytestream
    var stream = new http.ByteStream(file.openRead());
    stream.cast();
    // get file length
    var length = await file.length();

    // string to uri
    var uri = Uri.parse(EndPoint.getUrlKey(EndPoint.SEND_FILES));

    // create multipart request
    var request = new http.MultipartRequest("POST", uri);

    // multipart that takes file
    var multipartFile = new http.MultipartFile('file', stream, length,
        filename: basename(file.path));

    // add file to multipart
    request.files.add(multipartFile);

    // send
    var response = await request.send();
    print(response.statusCode);

    // listen for response
    response.stream.transform(utf8.decoder).listen((value) {
      print(value);
    });
  }*/

  /*uploadFile(File file) async {
    DateTime now = new DateTime.now();

    var request = MultipartRequest();

    request.setUrl(EndPoint.getUrlKey(EndPoint.SEND_FILES) + "&datetime=${now.toString()}");
    request.addFile("file", file.path);

    Response response = request.send();

    response.onError = () {
      print("Error");
    };

    response.onComplete = (response) {
      print(response);
    };

    response.progress.listen((int progress) {
      print("progress from response object " + progress.toString());
    });
  }*/

  // avvia le operazioni di upload del file
  uploadMedia(io.File file, bool isPhoto) async {
    // per farlo deve interpellare uploadManager e poi deve aggiungere il progressFIle alla lista dei progress, in quanto altrimenti non potrebbero essere rimossi i listener quando si esce dalla sezione
    ProgressFile progressFile = Utility.uploadManger.uploadFile(
        file,
        widget.idAppuntamento,
        _cacheManagerChat.idChat(widget.idAppuntamento, _listViewChat.length),
        isPhoto ? 0 : 1);
    _listProgressFile.add(progressFile);
    Future<void> saveMedia;
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

  uploadFile(io.File file) {
    ProgressFile progressFile = Utility.uploadManger.uploadFile(
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

  Future<void> cacheImage(ProgressFile progressFile) async {
    Uint8List bytes = progressFile.file.readAsBytesSync();

    await _cacheManager.putFile(progressFile.getUrl(), bytes,
        fileExtension: progressFile.getExtension(), maxAge: Duration(days: 15));
  }

  Future<void> cachePlaceholderAndVideo(ProgressFile progressFile) async {
    Uint8List bytesVideo = progressFile.file.readAsBytesSync();

    Uint8List bytesFile = await VideoThumbnail.thumbnailData(
      video: progressFile.file.path,
      imageFormat: ImageFormat.JPEG,
    );

    await _cacheManager.putFile(progressFile.getUrl() + ".jpeg", bytesFile,
        fileExtension: "jpeg", maxAge: Duration(days: 15));

    // File fileVideo = await DefaultCacheManager().putFile(
    //    progressFile.getUrl(), bytesVideo,
    //    fileExtension: progressFile.getExtension(), maxAge: Duration(days: 7));
    // print("video-url-1: ${fileVideo.path}");
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

          // all'avvio deve scaricare tutti i progressUpload in corso per questa pagina
          // in quanto se si esce dalla pagina e poi si rientra deve appunto mostrare il fatto che si sta caricando qualche file
          _listProgressFile =
              Utility.uploadManger.getListProgressFile(widget.idAppuntamento);
          _listProgressFile.forEach((element) {
            element.setListener(
                (int progress) => print("progress-file: $progress"));
          });

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
                        floatingLabelBehavior: FloatingLabelBehavior.never,
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
                  RaisedButton(
                    color: Colors.white,
                    elevation: 0.0,
                    child: Column(
                      children: [
                        Icon(Icons.image),
                        Text('Media'),
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
                  RaisedButton(
                    color: Colors.white,
                    elevation: 0.0,
                    child: Column(
                      children: [
                        Icon(Icons.photo_camera),
                        Text('Foto'),
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
