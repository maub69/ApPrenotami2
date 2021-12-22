import 'dart:io' as io;

import 'package:alert/alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_cache_manager/file.dart';
import 'package:mia_prima_app/chat/risposte/popup_menu_chat.dart';
import 'package:mia_prima_app/model.dart';
import 'package:mia_prima_app/utility/uploadManager.dart';
import 'package:mia_prima_app/utility/utility.dart';
import 'package:path/path.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

class FileUpload extends StatefulWidget {
  final ProgressFile progressFile;
  final String url;
  final DateTime datetime;
  final bool isAmministratore;
  final String name;
  final String idChat;
  final String idAppuntamento;

  FileUpload(
      {Key key,
      this.idAppuntamento,
      this.progressFile,
      this.url,
      this.datetime,
      this.isAmministratore = false,
      this.name,
      this.idChat})
      : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _FileUploadState();
  }
}

class _FileUploadState extends State<FileUpload>
    with AutomaticKeepAliveClientMixin {
  double _progress = 0;
  String _name;
  bool _isDownloaded = false;

  List<String> _extentionsMoveToTemp = [
    ".pdf",
    ".doc",
    ".docx",
    ".ppt",
    ".pptx",
    ".xls",
    ".xlsx"
  ];
  bool _inDownloading = false;
  DateTime _datetime;

  @override
  void initState() {
    super.initState();

    if (widget.progressFile == null) {
      _checkIfIsDownloaded().then((value) {
        setState(() {
          _isDownloaded = value;
        });
      });
    } else {
      _isDownloaded = true;
    }

    if (widget.progressFile == null) {
      _name = widget.name;
      _datetime = widget.datetime;
    } else {
      _name = basename(widget.progressFile.file.path);
      _datetime = widget.progressFile.dateTime;
    }

    if (widget.progressFile == null || widget.progressFile.progress == 100) {
      _progress = 1;
    } else {
      _progress = 0;
    }

    widget.progressFile?.setListener((progress) {
      setState(() {
        print("progress-file: $progress");
        _progress = progress.toDouble() / 100;
      });
    });
  }

  void _downloadFile() async {
    final response =
    await http.head(Uri.parse(widget.url));

    if (response.statusCode == 200) {
      if (!_inDownloading) {
        _inDownloading = true;

        /*DownloaderUtils downloaderUtils = DownloaderUtils(
          progressCallback: (current, total) {
            setState(() {
              _progress = current / total;
            });
          },
          file: io.File(_getPathFileDownloaded()),
          progress: ProgressImplementation(),
          onDone: () {
            setState(() {
              _inDownloading = false;
              _isDownloaded = true;
            });
          },
          deleteOnCancel: true,
        );
        await Flowder.download(widget.url, downloaderUtils);*/

        // https://medium.com/flutter-community/how-to-show-download-progress-in-a-flutter-app-8810e294acbd
        // abbiamo sostituito il plugin precedende per il download utilizzando direttamente le funzionalita' della libreria http
        // seguendo le istruzioni del link sopra

        http.Request request = http.Request('GET', Uri.parse(widget.url));
        http.StreamedResponse response = await http.Client().send(request);
        int contentLength = response.contentLength;
        io.File file = await io.File(_getPathFileDownloaded());
        await file.create(recursive: true);
        List<int> bytes = [];

        response.stream.listen((List<int> newBytes) {
            bytes.addAll(newBytes);
            setState(() {
              _progress = bytes.length / contentLength;
            });
          },
          onDone: () async {
            await file.writeAsBytes(bytes);
            setState(() {
              _inDownloading = false;
              _isDownloaded = true;
            });
          },
          onError: (e) {
            print(e);
          },
          cancelOnError: true,
        );

      }
    } else {
      Alert(message: "Il file non è più disponbile per il download", shortDuration: false).show();
    }
  }

  // ricordati di usare questo link per la questione della cache: https://stackoverflow.com/questions/66488125/how-to-store-image-to-cachednetwrok-image-in-flutter
  // fare in modo che alla fine dell'upload venga rimosso il widget del caricamento
  // rendere cliccabile l'immagine al fine di farla vedere a schermo pieno
  // gestire gli altri caricamenti in attesa, magari mettendo una scritta tipo "in attesa di caricamento"
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onLongPress: () {
          PopupMenuChat.showMenu(
            context: Model.getContext(),
            isAmministratore: widget.isAmministratore,
            isChat: false,
            idChat: widget.idChat,
            widget: widget
          );
        },
        onTap: () async {
          if (widget.progressFile == null) {
            //redis
            if (_isDownloaded) {
              try {
                OpenFile.open(_getPathFileDownloaded());
              } catch (e) {
                print(e);
              }
            } else {
              if (Utility.hasInternet) {
                _downloadFile();
              } else {
                Alert(message: 'Internet assente, non puoi scaricare il file').show();
              }
            }
          } else {
            OpenFile.open(widget.progressFile.file.path);
            print("message-open-upload: ${widget.progressFile.file.path}");
          }
        },
        child: Container(
            margin: const EdgeInsets.symmetric(
              vertical: 15.0,
              horizontal: 20.0,
            ),
            alignment: Alignment.centerRight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                      color: Colors.green[200],
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(10),
                      ),
                      border: Border.all(
                        color: Colors.green[200],
                        width: 2,
                      )),
                  padding: EdgeInsets.all(5),
                  alignment: Alignment.center,
                  child: Text(_getStringFromDateTime(_datetime),
                      style: TextStyle(fontSize: 12)),
                  width: 300,
                ),
                Container(
                  decoration: BoxDecoration(
                      color: Colors.green[200],
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(10),
                      ),
                      border: Border.all(
                        color: Colors.green[200],
                        width: 2,
                      )),
                  padding:
                      EdgeInsets.only(top: 0, bottom: 20, right: 15, left: 15),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 220,
                        child: Text(_name),
                      ),
                      Stack(alignment: Alignment.center, children: <Widget>[
                        Visibility(
                          child: CircularProgressIndicator(
                              value: (widget.progressFile == null ||
                                      widget.progressFile.progress == 100)
                                  ? 0
                                  : _progress,
                              semanticsLabel: 'Linear progress indicator'),
                          visible: _isDownloaded &&
                              widget.progressFile != null &&
                              widget.progressFile.progress != 100,
                        ),
                        Visibility(
                          child: CircularProgressIndicator(
                              value: _progress,
                              semanticsLabel: 'Linear progress indicator'),
                          visible: _inDownloading,
                        ),
                        Visibility(
                          child: Image(
                              image: AssetImage('images/file.png'), height: 45),
                          visible: _isDownloaded &&
                              (widget.progressFile == null ||
                                  widget.progressFile.progress == 100),
                        ),
                        Visibility(
                          child: Image(
                              image: AssetImage('images/download.png'),
                              height: 35),
                          visible: !_inDownloading &&
                              !_isDownloaded &&
                              (widget.progressFile == null ||
                                  widget.progressFile.progress == 100),
                        ),
                      ])
                    ],
                  ),
                  width: 300,
                )
              ],
            )));
  }

  @override
  bool get wantKeepAlive => true;

  Future<bool> _checkIfIsDownloaded() async {
    print("percorso-file: ${_getPathFileDownloaded()}");
    io.File file = new io.File(_getPathFileDownloaded());
    return await file.exists();
  }

  String _getPathFileDownloaded() {
    return Utility.pathDownload +
        "/files/" +
        widget.idAppuntamento +
        "/" +
        Utility.getDateInCorrectFormat(widget.datetime) +
        "_" +
        widget.name;
  }

  Future<String> toRemove() async {
    /*await [
        Permission.storage,
      ].request().then((value) {
        if (value[Permission.storage].isGranted) {
          print("permesso: attivo");
        } else {
          print("permesso: non attivo");
        }
      });*/

    /*if (await Permission.storage.request().isGranted) {
        print("permesso-1: attivo");
      } else {
        print("permesso-1: non attivo");
      }*/

    if (await Permission.storage.isGranted) {
      print("permesso-2: attivo");
    } else {
      print("permesso-2: non attivo");
    }
  }

  String _getStringFromDateTime(DateTime datetime) {
    return "${datetime.day}/${datetime.month}/${datetime.year} ${datetime.hour}:${(datetime.minute >= 10) ? datetime.minute : "0" + datetime.minute.toString()}";
  }
}


/*

*/